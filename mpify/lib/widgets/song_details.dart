import 'package:flutter/material.dart';
import 'package:mpify/func.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/widgets/shared/text/positioned_header.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/shared/slider.dart/duration.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:provider/provider.dart';
import 'package:mpify/widgets/shared/slider.dart/volume.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class SongDetails extends StatefulWidget {
  const SongDetails({super.key});

  @override
  State<SongDetails> createState() => _SongDetailsState();
}

class _SongDetailsState extends State<SongDetails> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 10),
      child: Container(
        width: 1520,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.transparent,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Consumer<SongModels>(
                  builder: (context, value, child) {
                    final songs = value.songsBackground;
                    final index = value.currentSongIndex;
                    final imagePath = (songs.isEmpty)
                        ? null
                        : songs[index].imagePath;
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: (imagePath != null)
                          ? Image.file(
                              File(
                                p.join(
                                  Directory.current.path,
                                  '..',
                                  'cover',
                                  imagePath,
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
            ),
            Consumer<SongModels>(
              builder: (context, value, child) {
                final index = value.currentSongIndex;
                final songs = value.songsBackground;
                final name = (songs.isEmpty) ? 'Song Name' : songs[index].name;
                return Padding(
                  padding: const EdgeInsets.only(top: 30, left: 70),
                  child: SizedBox(
                    width: 330,
                    child: Text(
                      '$name',
                      style: montserratStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                );
              },
            ),
            Consumer<SongModels>(
              builder: (context, value, child) {
                final songs = value.songsBackground;
                final index = value.currentSongIndex;
                final artist = (songs.isEmpty) ? 'Artist' : songs[index].artist;
                return Padding(
                  padding: const EdgeInsets.only(top: 50, left: 70),
                  child: SizedBox(
                    width: 160,
                    child: Text(
                      '$artist',
                      style: montserratStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer<SongModels>(
                    builder: (context, value, child) {
                      final songProgress = formatDuration(value.songProgress);
                      return Text(
                        songProgress,
                        style: montserratStyle(fontWeight: FontWeight.w300),
                      );
                    },
                  ),
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

                  Consumer<SongModels>(
                    builder: (context, value, child) {
                      final songDuration = formatDuration(value.songDuration);
                      return Text(
                        songDuration,
                        style: montserratStyle(fontWeight: FontWeight.w300),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              left: 1370,
              child: Icon(
                Icons.volume_up_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            Positioned(
              top: 40,
              left: 1330,
              child: Icon(
                Icons.music_note_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            Positioned(
              top: 25,
              left: 1380,
              child: VolumeSlider(
                width: 150,
                height: 2,
                value: 100,
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
