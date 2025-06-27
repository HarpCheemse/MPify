import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
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
  bool _isShuffle = true;
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 80),
      child: Container(
        height: 600,
        width: 800,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: const Color.fromARGB(255, 24, 24, 24),
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
                    Color.fromARGB(255, 24, 24, 24),
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
                        Text('Playlist', style: montserratStyle(fontSize: 10)),
                        SizedBox(height: 5, width: 10),
                        Text(
                          context.watch<PlaylistModels>().selectedPlaylist,
                          style: montserratStyle(fontSize: 24),
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
                builder: (context, value, child) {
                  final songs = context.read<SongModels>();
                  return HoverButton(
                    baseColor: Colors.green,
                    borderRadius: 50,
                    onPressed: () {
                      songs.isPlaying
                          ? AudioUtils.pauseSong()
                          : AudioUtils.resumeSong();
                      songs.flipIsPlaying();
                    },
                    width: 60,
                    height: 60,
                    hoverColor: const Color.fromARGB(255, 134, 212, 137),
                    child: Icon(
                      songs.isPlaying ? Icons.pause : Icons.play_arrow,
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
                  fontColor: Colors.white,
                  hintColor: const Color.fromARGB(255, 140, 140, 140),
                  iconColor: const Color.fromARGB(255, 140, 140, 140),
                  icon: Icons.search,
                ),
              ),
            ),
            Positioned(
              top: 130,
              left: 680,
              child: Consumer<SongModels>(
                builder: (context, value, child) {
                  return HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    key: sortByMenuKey,
                    hoverFontColor: const Color.fromARGB(255, 144, 4, 4),
                    text: 'Sorted by :=',
                    textStyle: montserratStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                    borderRadius: 0,
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
                        color: Colors.black,
                        items: [
                          PopupMenuItem(
                            value: SortOption.newest,
                            child: Text(
                              'Newest Added',
                              style: montserratStyle(),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.lastest,
                            child: Text(
                              'Lastest Added',
                              style: montserratStyle(),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.nameAZ,
                            child: Text('Name (A-Z)', style: montserratStyle()),
                          ),
                          PopupMenuItem(
                            value: SortOption.nameZA,
                            child: Text('Name (Z-A)', style: montserratStyle()),
                          ),
                          PopupMenuItem(
                            value: SortOption.artistAZ,
                            child: Text(
                              'Artist (A-Z)',
                              style: montserratStyle(),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.artistZA,
                            child: Text(
                              'Artist (Z-A)',
                              style: montserratStyle(),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.durationLongest,
                            child: Text(
                              'Duration Longest',
                              style: montserratStyle(),
                            ),
                          ),
                          PopupMenuItem(
                            value: SortOption.durationShortest,
                            child: Text(
                              'Duration Shortest',
                              style: montserratStyle(),
                            ),
                          ),
                        ],
                      );
                      if (selected != null) {
                        context.read<SongModels>().updateSortOption(selected);
                      }
                    },
                    width: 120,
                    height: 30,
                  );
                },
              ),
            ),
            positionedHeader(
              180,
              35,
              '#',
              16,
              500,
              const Color.fromARGB(255, 157, 157, 157),
            ),
            positionedHeader(
              180,
              150,
              'Name',
              14,
              500,
              const Color.fromARGB(255, 157, 157, 157),
            ),
            positionedHeader(
              180,
              490,
              'Artist',
              14,
              500,
              const Color.fromARGB(255, 157, 157, 157),
            ),
            positionedHeader(
              180,
              660,
              'Duration',
              14,
              500,
              const Color.fromARGB(255, 157, 157, 157),
            ),
            Positioned(
              top: 110,
              left: 100,
              child: IconButton(
                icon: Icon(Icons.shuffle_rounded),
                color: _isShuffle ? Colors.green : Colors.grey,
                iconSize: 30,
                onPressed: () {
                  _isShuffle
                      ? context.read<SongModels>().unshuffleSongs()
                      : context.read<SongModels>().shuffleSongs(
                          context.read<SongModels>().currentSongIndex,
                        );
                  setState(() {
                    _isShuffle = !_isShuffle;
                  });
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
              child: Container(height: 1, color: Colors.grey),
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
