import 'package:flutter/material.dart';
import 'package:mpify/func.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/widgets/shared/text/positioned_header.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/shared/slider.dart/duration.dart';
import 'package:provider/provider.dart';
import 'package:mpify/widgets/shared/slider.dart/volume.dart';

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
                child: Image.asset(
                  'assets/placeholder.png',
                  fit: BoxFit.cover,
                  height: 50,
                  width: 50,
                ),
              ),
            ),
            Consumer<SongModels>(
              builder: (context, value, child) {
                final index = value.currentSongIndex;
                final songs = value.songs;
                final name = songs[index].name;
                return positionedHeader(20, 70, name, 14, 600, Colors.white);
              },
            ),
            positionedHeader(
              40,
              70,
              'Artist',
              14,
              500,
              const Color.fromARGB(255, 150, 150, 150),
            ),
            Positioned(
              top: 10,
              left: 730,
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
            Positioned(
              top: 10,
              left: 830,
              child: IconButton(
                icon: Icon(Icons.fast_forward),
                color: Colors.white,
                onPressed: () {
                  AudioUtils.skipForward();
                },
              ),
            ),
            Positioned(
              top: 10,
              left: 635,
              child: IconButton(
                icon: Icon(Icons.fast_rewind, color: Colors.white),
                onPressed: () {
                  AudioUtils.skipBackward();
                },
              ),
            ),

            Positioned(
              top: 20,
              left: 550,
              child: IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () {
                  final songModels = context.read<SongModels>();
                  songModels.playPreviousSong();
                },
              ),
            ),
            Positioned(
              top: 20,
              left: 950,
              child: IconButton(
                icon: Icon(Icons.skip_next, color: Colors.white),
                onPressed: () {
                  final songModels = context.read<SongModels>();
                  songModels.playNextSong();
                },
              ),
            ),
            positionedHeader(10, 840, '5', 8, 500, Colors.white),
            positionedHeader(10, 660, '5', 8, 500, Colors.white),
            Positioned(
              top: 50,
              left: 420,
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
            Consumer<SongModels>(
              builder: (context, value, child) {
                final songDuration = formatDuration(value.songDuration);
                final songProgress = formatDuration(value.songProgress);
                return Stack(
                  children: [
                    positionedHeader(
                      60,
                      390,
                      songProgress,
                      14,
                      200,
                      Colors.white,
                    ),
                    positionedHeader(
                      60,
                      1070,
                      songDuration,
                      14,
                      200,
                      Colors.white,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
