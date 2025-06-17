import 'package:flutter/material.dart';
import 'package:mpify/func.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/widgets/shared/text/positioned_header.dart';
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
            final songs = songModels.songs;
            return ListView.builder(
            controller: _scrollController,
            itemCount: songs.length,
            itemBuilder: (BuildContext content, int index) {
              final song = songs[index];
              return Song(name: song.name, artist:song.artist, duration: song.duration, index: index,);
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
    required this.index
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
      onPressed: () {
        final songs = context.read<SongModels>().songs;
        context.read<SongModels>().setIsPlaying(true);
        context.read<SongModels>().getSongIndex(name);
        AudioUtils.playSong(songs[context.read<SongModels>().currentSongIndex].name);
      },
      child: Stack(
        children: [
          positionedHeader(15, 12, '${index + 1}', 16, 500, Colors.white),
          Positioned(
            top: 10,
            left: 80,
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset('assets/placeholder.png', fit: BoxFit.contain),
            ),
          ),
          Positioned(
            left: 150,
            top: 20,
            child: Text(name, style: montserratStyle()),
          ),
          positionedHeader(20, 360, artist , 12, 600, Colors.grey),
          positionedHeader(20, 670, duration , 12, 600, Colors.grey),
          
        ],
      ),
    );
  }
}
