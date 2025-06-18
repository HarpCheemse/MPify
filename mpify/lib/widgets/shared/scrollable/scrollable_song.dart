import 'package:flutter/material.dart';
import 'package:mpify/func.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:provider/provider.dart';

import 'package:mpify/models/playlist_models.dart';

class ScrollableListSong extends StatefulWidget {
  final double width;
  final double height;
  final Color? color;
  const ScrollableListSong({
    super.key,
    required this.width,
    required this.height,
    this.color = Colors.white,
  });

  @override
  State<ScrollableListSong> createState() => _ScrollableListSongState();
}

class _ScrollableListSongState extends State<ScrollableListSong> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    final playlist = context.read<PlaylistModels>().selectedPlaylist;
    context.read<SongModels>().loadSong(playlist);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.color,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: Consumer<SongModels>(
          builder: (context, songModels, child) {
            final songs = songModels.songsActive;
            return ListView.builder(
              controller: _scrollController,
              itemCount: songs.length,
              itemBuilder: (BuildContext content, int index) {
                final song = songs[index];
                return Song(
                  name: song.name,
                  artist: song.artist,
                  duration: song.duration,
                  index: index,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class Song extends StatelessWidget {
  final String name;
  final String duration;
  final String artist;
  final int index;
  const Song({
    super.key,
    required this.name,
    required this.duration,
    required this.artist,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      baseColor: Colors.transparent,
      hoverColor: const Color.fromRGBO(113, 113, 113, 0.412),
      textStyle: montserratStyle(),
      borderRadius: 5,
      width: 320,
      height: 70,
      onPressed: () async {
        final songModels = context.read<SongModels>();
        await songModels.loadActivePlaylistSong(); //copy activeSong to background song
        final songsBackground = songModels.songsBackground;

        songModels.getSongIndex(name);
        songModels.setIsPlaying(true);
        try {
          AudioUtils.playSong(
          songsBackground[songModels.currentSongIndex].name,
        );
        }
        catch (e) {
          debugPrint('error playing audio: $e');
        }
      },
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Center(
              child: Text(
                '${index + 1}',
                style: montserratStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset('assets/placeholder.png', fit: BoxFit.contain),
            ),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 330,
            height: 20,
            child: Text(name, style: montserratStyle()),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 170,
            height: 20,
            child: Text(
              artist,
              style: montserratStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 50,
            height: 20,
            child: Text(
              duration,
              style: montserratStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {},
            icon: Icon(Icons.more_horiz, color: Colors.grey,),
            color: const Color.fromARGB(255, 53, 53, 53),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(value: 'edit', child: Text('edit', style: montserratStyle(color: Colors.white),)),
              PopupMenuItem<String>(value: 'delete', child: Text('Delete', style: montserratStyle(color: Colors.white),)),
            ],
          ),
        ],
      ),
    );
  }
}
