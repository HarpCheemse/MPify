import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/misc_utils.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/shared/input_bar/input_bar.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/text/positioned_header.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/create_song_form.dart';
import 'package:mpify/widgets/shared/scrollable/scrollable_song.dart';

import 'package:provider/provider.dart';
import 'package:mpify/models/playlist_models.dart';

import 'package:mpify/utils/audio_ultis.dart';

final GlobalKey sortByMenuKey = GlobalKey();

class Songs extends StatefulWidget {
  const Songs({super.key});

  @override
  State<Songs> createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 20),
      child: Container(
        height: 600,
        width: 800,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: Stack(
          children: [
            Container(
              //header
              height: 200,
              width: 800,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 4, 88, 156),
                    Theme.of(context).colorScheme.surfaceContainer,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/folder.png',
                      fit: BoxFit.contain,
                      width: 80,
                      height: 80,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Playlist',
                          style: montserratStyle(
                            context: context,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(height: 5, width: 10),
                        Text(
                          context.watch<PlaylistModels>().selectedPlaylist,
                          style: montserratStyle(
                            context: context,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 100,
              left: 10,
              child: Consumer<SongModels>(
                builder: (context, songs, child) {
                  return HoverButton(
                    baseColor: Colors.white,
                    borderRadius: 50,
                    onPressed: () async {
                      if (context.read<PlaylistModels>().selectedPlaylist ==
                          context.read<PlaylistModels>().playingPlaylist) {
                        songs.isPlaying
                            ? AudioUtils.pauseSong()
                            : AudioUtils.resumeSong();
                        songs.flipIsPlaying();
                      } else {
                        context.read<PlaylistModels>().setPlayingPlaylist();
                        final songModels = context.read<SongModels>();
                        await songModels
                            .loadActivePlaylistSong(); //copy activeSong to background song

                        final songsBackground = songModels.songsBackground;
                        if (songsBackground.isEmpty) {
                          await AudioUtils.stopSong();
                          return;
                        }
                        final randomIndex = Random().nextInt(
                          songsBackground.length,
                        );
                        final identifier =
                            songsBackground[randomIndex].identifier;
                        songModels.getSongIndex(identifier);
                        songModels.setIsPlaying(true);
                        try {
                          AudioUtils.playSong(
                            songsBackground[songModels.currentSongIndex]
                                .identifier,
                          );
                        } catch (e) {
                          MiscUtils.showError('Error: Unable To Play Audio');
                          FolderUtils.writeLog(
                            'Error: $e. Unable To Play Audio',
                          );
                        }
                      }
                    },
                    width: 60,
                    height: 60,
                    hoverColor: const Color.fromARGB(255, 206, 206, 206),
                    child: Consumer<PlaylistModels>(
                      builder: (context, playlist, child) {
                        return Icon(
                          (playlist.selectedPlaylist ==
                                  playlist.playingPlaylist)
                              ? (songs.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow)
                              : Icons.play_arrow,
                          color: Colors.black,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 120,
              left: 480,
              child: SizedBox(
                width: 200,
                height: 40,
                child: CustomInputBar(
                  controller: controller,
                  onChanged: (query) {
                    context.read<SongModels>().updateSongSearchQuery(query);
                  },
                  hintText: 'Search Name',
                  searchColor: Colors.transparent,
                  fontColor: Theme.of(context).colorScheme.onSurface,
                  hintColor: Theme.of(context).colorScheme.onSurface,
                  iconColor: Theme.of(context).colorScheme.onSurface,
                  icon: Icons.search,
                ),
              ),
            ),
            Positioned(
              top: 125,
              left: 680,
              child: Consumer<SongModels>(
                builder: (context, value, child) {
                  return HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    key: sortByMenuKey,
                    borderRadius: 10,
                    // ignore: sort_child_properties_last
                    child: Center(
                      child: Text(
                        'Sorted by :=',
                        style: montserratStyle(
                          context: context,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final RenderBox button =
                          sortByMenuKey.currentContext!.findRenderObject()
                              as RenderBox;
                      final overlay =
                          Overlay.of(context).context.findRenderObject()
                              as RenderBox;
                      final topLeft = button.localToGlobal(
                        Offset(0, 50),
                        ancestor: overlay,
                      );
                      final bottomRight = button.localToGlobal(
                        button.size.bottomRight(Offset(0, 50)),
                        ancestor: overlay,
                      );
                      final position = RelativeRect.fromRect(
                        Rect.fromPoints(topLeft, bottomRight),
                        Offset.zero & overlay.size,
                      );
                      final selected = await showMenu(
                        context: context,
                        position: position,
                        color: Theme.of(context).colorScheme.surface,
                        items: [
                          PopupMenuItem(
                            value: SortOption.newest,
                            child: Text(
                              'Newest Added',
                              style: montserratStyle(context: context),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.lastest,
                            child: Text(
                              'Lastest Added',
                              style: montserratStyle(context: context),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.nameAZ,
                            child: Text(
                              'Name (A-Z)',
                              style: montserratStyle(context: context),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.nameZA,
                            child: Text(
                              'Name (Z-A)',
                              style: montserratStyle(context: context),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.artistAZ,
                            child: Text(
                              'Artist (A-Z)',
                              style: montserratStyle(context: context),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.artistZA,
                            child: Text(
                              'Artist (Z-A)',
                              style: montserratStyle(context: context),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.durationLongest,
                            child: Text(
                              'Duration Longest',
                              style: montserratStyle(context: context),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.durationShortest,
                            child: Text(
                              'Duration Shortest',
                              style: montserratStyle(context: context),
                            ),
                          ),
                        ],
                      );
                      if (selected != null) {
                        if (!context.mounted) return;
                        context.read<SongModels>().updateSortOption(selected);
                      }
                    },
                    width: 120,
                    height: 30,
                  );
                },
              ),
            ),
            positionedHeader(context, 180, 35, '#', 16, 500, null),
            positionedHeader(context, 180, 150, 'Name', 14, 500, null),
            positionedHeader(context, 180, 490, 'Artist', 14, 500, null),
            positionedHeader(context, 180, 660, 'Duration', 14, 500, null),
            Positioned(
              top: 110,
              left: 100,
              child: IconButton(
                icon: Icon(Icons.shuffle_rounded),
                color: context.watch<SongModels>().isShuffle
                    ? const Color.fromARGB(255, 44, 124, 47)
                    : Colors.white,
                iconSize: 30,
                onPressed: () {
                  context.read<SongModels>().isShuffle
                      ? context.read<SongModels>().unshuffleSongs()
                      : context.read<SongModels>().shuffleSongs(
                          context.read<SongModels>().currentSongIndex,
                        );
                  context.read<SongModels>().flipIsShuffle();
                },
              ),
            ),
            Positioned(
              top: 110,
              left: 170,
              child: IconButton(
                icon: Icon(
                  Icons.add_circle_sharp,
                  size: 30,
                  color: Colors.white,
                ),
                onPressed: () {
                  OverlayController.show(context, CreateSongForm());
                },
              ),
            ),
            Positioned(
              top: 210,
              left: 20,
              right: 20,
              child: Container(
                height: 1,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Positioned(
              top: 220,
              left: 20,
              child: ScrollableListSong(
                width: 760,
                height: 370,
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
