import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/string_ultis.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:mpify/widgets/shared/slider.dart/duration.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';

import 'package:mpify/utils/audio_ultis.dart';

class Player extends StatefulWidget {
  const Player({super.key});
  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final List<Color> colorList = [
    Color.fromARGB(100, 255, 82, 82), // Red
    Color.fromARGB(100, 255, 214, 64), // Yellow
    Color.fromARGB(100, 24, 255, 255), // Cyan
    Color.fromARGB(100, 68, 137, 255), // Blue
    Color.fromARGB(100, 76, 175, 79), // Green
    Color.fromARGB(100, 255, 153, 0), // Orange
    Color.fromARGB(100, 0, 187, 212), // Teal
    Color.fromARGB(100, 156, 39, 176), // Purple
    Color.fromARGB(100, 233, 30, 99), // Pink
    Color.fromARGB(100, 158, 158, 158), // Grey
    Color.fromARGB(100, 63, 81, 181), // Indigo
    Color.fromARGB(100, 139, 195, 74), // Lime green
    Color.fromARGB(100, 255, 87, 34), // Deep orange
    Color.fromARGB(100, 3, 169, 244), // Light blue
    Color.fromARGB(100, 0, 150, 136), // Teal dark
    Color.fromARGB(100, 255, 193, 7), // Amber
    Color.fromARGB(100, 103, 58, 183), // Deep Purple
    Color.fromARGB(100, 244, 67, 54), // Strong Red
    Color.fromARGB(100, 205, 220, 57), // Lime
    Color.fromARGB(100, 0, 188, 212), // Cyan moderate
    Color.fromARGB(100, 96, 125, 139), // Blue Grey
    Color.fromARGB(100, 255, 235, 59), // Bright Yellow
    Color.fromARGB(100, 124, 77, 255), // Violet Accent
    Color.fromARGB(100, 255, 138, 128), // Soft Coral
    Color.fromARGB(100, 255, 87, 125), // Raspberry pink
    Color.fromARGB(100, 0, 200, 83), // Emerald green
    Color.fromARGB(100, 186, 104, 200), // Lavender purple
    Color.fromARGB(100, 255, 171, 64), // Soft orange
    Color.fromARGB(100, 77, 182, 172), // Aqua green
    Color.fromARGB(100, 229, 57, 53), // Crimson red
    Color.fromARGB(100, 66, 165, 245), // Sky blue
    Color.fromARGB(100, 174, 234, 0), // Neon lime
    Color.fromARGB(100, 255, 202, 40), // Golden yellow
    Color.fromARGB(100, 240, 98, 146), // Rose pink
    Color.fromARGB(100, 0, 121, 107), // Dark Teal
    Color.fromARGB(100, 244, 81, 30), // Pumpkin Orange
    Color.fromARGB(100, 121, 134, 203), // Soft Indigo
    Color.fromARGB(100, 38, 198, 218), // Bright Cyan
    Color.fromARGB(100, 156, 204, 101), // Light Green
    Color.fromARGB(100, 255, 112, 67), // Coral Orange
    Color.fromARGB(100, 100, 181, 246), // Light Sky Blue
    Color.fromARGB(100, 213, 0, 249), // Neon Purple
    Color.fromARGB(100, 255, 241, 118), // Soft Yellow
    Color.fromARGB(100, 0, 229, 255), // Electric Blue
  ];
  @override

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 20),
      child: Selector<SongModels, String?>(
        selector: (_, model) {
          final songs = model.songsBackground;
          if (songs.isEmpty) {
            return null;
          } else {
            return songs[model.currentSongIndex].identifier;
          }
        },
        builder: (context, identifier, child) {
          final colorIndex = (identifier == null)
              ? 0
              : StringUltis.getStringValue(identifier) % colorList.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            height: 600,
            width: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: (identifier == null) ? const Color.fromARGB(255, 24, 24, 24) : colorList[colorIndex],
            ),
            child: Column(
              children: [
                SizedBox(height: 50),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Consumer<SongModels>(
                    builder: (context, value, child) {
                      final songs = value.songsBackground;
                      final index = value.currentSongIndex;
                      final identifier = (songs.isEmpty)
                          ? null
                          : songs[index].identifier;
                      final coverPath = p.join(
                        Directory.current.path,
                        '..',
                        'cover',
                        '$identifier.png',
                      );
                      final imageExist = File(coverPath).existsSync();

                      return SizedBox(
                        width: 300,
                        height: 300,
                        child: imageExist
                            ? Image.file(
                                File(
                                  p.join(
                                    Directory.current.path,
                                    '..',
                                    'cover',
                                    '$identifier.png',
                                  ),
                                ),
                              )
                            : Image.asset(
                                'assets/placeholder.png',
                                fit: BoxFit.contain,
                              ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Consumer<SongModels>(
                  builder: (context, value, child) {
                    final songs = value.songsBackground;
                    final index = value.currentSongIndex;
                    final name = (songs.isEmpty)
                        ? 'Song Name'
                        : songs[index].name;
                    return SizedBox(
                      width: 300,
                      child: Text(
                        name,
                        style: montserratStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                Consumer<SongModels>(
                  builder: (context, value, child) {
                    final songs = value.songsBackground;
                    final index = value.currentSongIndex;
                    final artist = (songs.isEmpty)
                        ? 'Unknown'
                        : songs[index].artist;
                    return SizedBox(
                      width: 300,
                      child: Text(
                        artist,
                        style: montserratStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    );
                  },
                ),
                SizedBox(height: 50),
                SizedBox(
                  width: 330,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 30),
                        child: IconButton(
                          icon: Icon(Icons.skip_previous, color: Colors.white),
                          onPressed: () {
                            final songModels = context.read<SongModels>();
                            songModels.playPreviousSong();
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 30),
                        child: IconButton(
                          icon: Icon(Icons.fast_rewind, color: Colors.white),
                          onPressed: () {
                            AudioUtils.skipBackward();
                          },
                        ),
                      ),
                      Center(
                        child: Consumer<SongModels>(
                          builder: (context, model, child) {
                            return HoverButton(
                              baseColor: const Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ),
                              borderRadius: 50,
                              onPressed: () {
                                model.isPlaying
                                    ? AudioUtils.pauseSong()
                                    : AudioUtils.resumeSong();
                                model.flipIsPlaying();
                              },
                              width: 45,
                              height: 45,
                              hoverColor: const Color.fromARGB(
                                255,
                                150,
                                150,
                                150,
                              ),
                              child: Transform.translate(
                                offset: Offset(0, 0),
                                child: Icon(
                                  model.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: IconButton(
                          icon: Icon(Icons.fast_forward),
                          color: Colors.white,
                          onPressed: () {
                            AudioUtils.skipForward();
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: IconButton(
                          icon: Icon(Icons.skip_next, color: Colors.white),
                          onPressed: () {
                            final songModels = context.read<SongModels>();
                            songModels.playNextSong();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: DurationSlider(
                    width: 650,
                    height: 2,
                    value: 0,
                    baseColor: const Color.fromARGB(255, 150, 150, 150),
                    progressColor: Colors.white,
                    hoverColor: Colors.green,
                    thumbSize: 6,
                    thumbColor: Colors.green,
                    onChanged: (double value) {},
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
