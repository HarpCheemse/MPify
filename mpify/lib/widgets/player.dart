import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 80),
      child: Container(
        height: 600,
        width: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: const Color.fromARGB(255, 24, 24, 24),
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
                final name = (songs.isEmpty) ? 'Song Name' : songs[index].name;
                return SizedBox(
                  width: 300,
                  child: Text(
                    name,
                    style: montserratStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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
                          baseColor: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: 50,
                          onPressed: () {
                            model.isPlaying
                                ? AudioUtils.pauseSong()
                                : AudioUtils.resumeSong();
                            model.flipIsPlaying();
                          },
                          width: 45,
                          height: 45,
                          hoverColor: const Color.fromARGB(255, 150, 150, 150),
                          child: Transform.translate(
                            offset: Offset(0, 0),
                            child: Icon(
                              model.isPlaying ? Icons.pause : Icons.play_arrow,
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
      ),
    );
  }
}
