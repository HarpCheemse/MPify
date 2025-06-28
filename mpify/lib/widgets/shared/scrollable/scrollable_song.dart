import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:provider/provider.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/edit_song_form.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mpify/models/playlist_models.dart';

import 'package:mpify/utils/audio_ultis.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/confirmation.dart';
import 'package:mpify/utils/playlist_ultis.dart';

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.color,
      child: RawScrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        thumbColor: const Color.fromARGB(116, 255, 255, 255),
        radius: Radius.circular(5),
        thickness: 10,
        trackVisibility: true,
        child: Consumer<SongModels>(
          builder: (context, songModels, child) {
            final songs = songModels.songsActive;
            return ListView.builder(
              controller: _scrollController,
              itemCount: songs.length,
              itemBuilder: (BuildContext content, int index) {
                final song = songs[index];
                return Song(
                  songName: song.name,
                  artist: song.artist,
                  duration: song.duration,
                  identifier: song.identifier,
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
  final String songName;
  final String duration;
  final String artist;
  final String identifier;
  final int index;
  const Song({
    super.key,
    required this.songName,
    required this.duration,
    required this.artist,
    required this.index,
    required this.identifier,
  });

  @override
  Widget build(BuildContext context) {
    final coverPath = p.join(Directory.current.path, '..', 'cover', '$identifier.png');
    final imageExist = File(coverPath).existsSync();
    return HoverButton(
      baseColor: Colors.transparent,
      hoverColor: const Color.fromRGBO(113, 113, 113, 0.412),
      textStyle: montserratStyle(),
      borderRadius: 5,
      width: 320,
      height: 70,
      onPressed: () async {
        final songModels = context.read<SongModels>();
        await songModels
            .loadActivePlaylistSong(); //copy activeSong to background song
        final songsBackground = songModels.songsBackground;

        songModels.getSongIndex(identifier);
        songModels.setIsPlaying(true);
        try {
          AudioUtils.playSong(
            songsBackground[songModels.currentSongIndex].identifier,
          );
        } catch (e) {
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
              child: imageExist
                  ? Image.file(
                      File(coverPath),
                      key: UniqueKey(), //Important to clear image cached
                      fit: BoxFit.cover,
                    )
                  : Image.asset('assets/placeholder.png', fit: BoxFit.contain),
            ),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 330,
            height: 20,
            child: Text(
              songName,
              style: montserratStyle(),
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          const SizedBox(width: 10),
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
          const SizedBox(width: 20),
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
            icon: Icon(Icons.more_horiz, color: Colors.grey),
            color: const Color.fromARGB(255, 53, 53, 53),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                onTap: () {
                  OverlayController.show(
                    context,
                    EditSongForm(
                      playlist: context.read<PlaylistModels>().selectedPlaylist,
                      identifier: identifier,
                      name: songName,
                      artist: artist,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.white,),
                    SizedBox(width: 10,),
                    Text(
                  'edit',
                  style: montserratStyle(color: Colors.white),
                ),
                  ],
                )
              ),
              PopupMenuItem<String>(
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.redAccent,),
                    SizedBox(width: 10,),
                    Text(
                  'Delete From Playlist',
                  style: montserratStyle(color: Colors.white),
                ),
                  ],
                ),
                onTap: () {
                  final selectedPlaylist = context
                      .read<PlaylistModels>()
                      .selectedPlaylist;
                  Future.delayed(Duration.zero, () {
                    if (!context.mounted) return;
                    OverlayController.show(
                      context,
                      Confirmation(
                        headerText: 'Delete Song',
                        warningText:
                            'This action is pernament are you sure you want to delete this song?',
                        function: () => PlaylistUltis.deleteSongFromPlaylist(
                          identifier,
                          selectedPlaylist,
                        ),
                      ),
                    );
                  });
                },
              ),
              PopupMenuItem<String>(
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.redAccent,),
                    SizedBox(width: 10,),
                    Text(
                  'Delete From Device',
                  style: montserratStyle(color: Colors.white),
                ),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    if (!context.mounted) return;
                    OverlayController.show(
                      context,
                      Confirmation(
                        headerText: 'Delete Song',
                        warningText:
                            'This action is pernament are you sure you want to delete this song pernamently from your device?',
                        function: () =>
                            PlaylistUltis.deleteSongFromDevice(identifier),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
