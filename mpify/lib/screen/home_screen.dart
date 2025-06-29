import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: (context.watch<SettingsModels>().isOpenSettings)
          ? const Settings()
          : Column(
              children: [
                Homebar(),
                Row(
                  children: [
                    Playlist(),
                    Songs(),
                    Consumer<PlaylistModels>(
                      builder: (context, value, child) {
                        return value.isPlayerOpen ? Player() : Lyric();
                      },
                    ),
                  ],
                ),
                SongDetails(),
              ],
            ),
    );
  }
}
