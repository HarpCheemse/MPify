import 'package:flutter/material.dart';
import 'package:mpify/main.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/settings_models.dart';
import 'package:mpify/widgets/homebar.dart';
import 'package:mpify/widgets/lyric.dart';

import 'package:mpify/widgets/playlist.dart';
import 'package:mpify/widgets/settings.dart';
import 'package:mpify/widgets/song.dart';
import 'package:mpify/widgets/player.dart';
import 'package:mpify/widgets/song_details.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isOpenSettings = context.select<SettingsModels, bool>(
      (settings) => settings.isOpenSettings,
    );
    final colorSchemeSurface = Theme.of(context).colorScheme.surface;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colorSchemeSurface,
        body: (isOpenSettings)
            ? const Settings()
            : Column(
                children: [
                  Homebar(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final showPlaylist = width > maxScreenWidth - 350;
                        final showPlayerOrLyric = width> maxScreenWidth - 700;
                        return Row(
                          children: [
                            if (showPlaylist) const Playlist(),
                            Expanded(child: const Songs()),
                            if (showPlayerOrLyric) const PlayerOrLyric(),
                            const SizedBox(width: 10,)
                          ],
                        );
                      },
                    ),
                  ),
                  SongDetails(),
                ],
              ),
      ),
    );
  }
}

class PlayerOrLyric extends StatelessWidget {
  const PlayerOrLyric({super.key});
  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistModels, bool>(
      selector: (context, model) => model.isPlayerOpen,
      builder: (context, isPlayerOpen, child) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: isPlayerOpen
              ? const Player(key: ValueKey('player'))
              : const Lyric(key: ValueKey('lyric')),
        );
      },
    );
  }
}
