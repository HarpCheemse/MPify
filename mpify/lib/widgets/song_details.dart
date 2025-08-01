import 'package:flutter/material.dart';
import 'package:mpify/main.dart';
import 'package:mpify/models/duration_models.dart';
import 'package:mpify/models/playback_models.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/string_ultis.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/shared/scrollable/scrollable_song.dart';
import 'package:mpify/widgets/shared/slider.dart/duration.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:provider/provider.dart';
import 'package:mpify/widgets/shared/slider.dart/volume.dart';

import 'package:mpify/utils/audio_ultis.dart';

class SongDetails extends StatefulWidget {
  const SongDetails({super.key});

  @override
  State<SongDetails> createState() => _SongDetailsState();
}

class _SongDetailsState extends State<SongDetails> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: Row(
          children: [
            const MiniSongDetails(),
            const DurationBar(),
            const Expanded(child: SizedBox()),
            const SongDetailsOptions(),
          ],
        ),
      ),
    );
  }
}

class SongDetailsOptions extends StatelessWidget {
  const SongDetailsOptions({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        final width = MediaQuery.of(context).size.width;
        final infoWidth = (width / maxScreenWidth) * 330;
        final sliderWidth = (width / maxScreenWidth) * 650;
        final showSongDetailsOptions = 400 + infoWidth + sliderWidth < width;
        if (showSongDetailsOptions) {
          return Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.music_note_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  context.read<PlaylistModels>().tooglePlayer();
                },
              ),
              const Icon(Icons.volume_up_outlined, color: Colors.white, size: 20),
              VolumeSlider(
                width: 150,
                height: 1,
                value: 100,
                baseColor: const Color.fromARGB(255, 150, 150, 150),
                progressColor: Colors.white,
                hoverColor: Colors.green,
                thumbSize: 6,
                thumbColor: Colors.green,
                onChanged: (double value) {},
              ),
            ],
          );
        } else {
          return Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.music_note_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  context.read<PlaylistModels>().tooglePlayer();
                },
              ),
              const SizedBox(width: 10),
            ],
          );
        }
      },
    );
  }
}

class DurationBar extends StatelessWidget {
  final double? width;
  const DurationBar({super.key, this.width});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () {
                    final songModels = context.read<SongModels>();
                    songModels.playPreviousSong();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: IconButton(
                  icon: const Icon(Icons.fast_rewind, color: Colors.white),
                  onPressed: () {
                    AudioUtils.skipBackward(context);
                  },
                ),
              ),
              Center(
                child: Selector<SongModels, bool>(
                  selector: (_, models) => models.isPlaying,
                  builder: (_, isPlaying, _) {
                    return HoverButton(
                      baseColor: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: 50,
                      onPressed: () {
                        isPlaying
                            ? AudioUtils.pauseSong()
                            : AudioUtils.resumeSong();
                        context.read<SongModels>().flipIsPlaying();
                      },
                      width: 40,
                      height: 40,
                      hoverColor: const Color.fromARGB(255, 150, 150, 150),
                      child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                        ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: IconButton(
                  icon: Icon(Icons.fast_forward),
                  color: Colors.white,
                  onPressed: () {
                    AudioUtils.skipForward(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () {
                    final songModels = context.read<SongModels>();
                    songModels.playNextSong();
                  },
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Consumer<DurationModels>(
              builder: (context, value, child) {
                final String songProgress = StringUltis.formatDuration(
                  value.songProgress,
                );
                return SizedBox(
                  width: 45,
                  child: Text(
                    songProgress,
                    style: montserratStyle(
                      context: context,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                );
              },
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = MediaQuery.of(context).size.width;
                final double percentage = width / maxScreenWidth;
                final double availWidth = 650 * percentage;

                return DurationSlider(
                  width: this.width ?? availWidth,
                  height: 1,
                  value: 0,
                  baseColor: const Color.fromARGB(255, 150, 150, 150),
                  progressColor: Colors.white,
                  hoverColor: Colors.green,
                  thumbSize: 5,
                  thumbColor: Colors.green,
                  onChanged: (double value) {},
                );
              },
            ),
            const SizedBox(width: 10),
            Consumer<DurationModels>(
              builder: (context, value, child) {
                final String songDuration = StringUltis.formatDuration(
                  value.songDuration,
                );

                return SizedBox(
                  width: 45,
                  child: Text(
                    songDuration,
                    style: montserratStyle(
                      context: context,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class MiniSongDetails extends StatelessWidget {
  const MiniSongDetails({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Selector<PlaybackModels, String?>(
              selector: (_, models) => models.getCurrentIdentifier(),
              builder: (_, identifier, _) {
                return SizedBox(
                  width: 60,
                  height: 60,
                  child: CoverImage(identifier: identifier),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Selector<PlaybackModels, String>(
              selector: (_, models) {
                final String? songName = models.getCurrentSongName();
                return (songName == null) ? 'Song Name' : songName;
              },
              builder: (_, songName, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = MediaQuery.of(context).size.width;
                    final double percentage = width / maxScreenWidth;
                    final double availWidth = 330 * percentage;

                    return SizedBox(
                      width: availWidth,
                      child: Text(
                        songName,
                        style: montserratStyle(
                          context: context,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 5),
            Selector<PlaybackModels, String>(
              selector: (_, models) {
                final String? artisit = models.getCurrentArtist();
                return (artisit == null) ? 'Unknown' : artisit;
              },
              builder: (_, artist, _) {
                return SizedBox(
                  width: 160,
                  child: Text(
                    artist,
                    style: montserratStyle(
                      context: context,
                      color: const Color.fromARGB(255, 111, 111, 111),
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
          ],
        ),
      ],
    );
  }
}
