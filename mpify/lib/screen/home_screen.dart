import 'package:flutter/material.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/widgets/lyric.dart';

import 'package:mpify/widgets/playlist.dart';
import 'package:mpify/widgets/song.dart';
import 'package:mpify/widgets/player.dart';
import 'package:mpify/widgets/song_details.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Row(
              children: [
                Playlist(),
                Songs(),
                Consumer<PlaylistModels>(builder: (context, value, child) {
                  return value.isPlayerOpen ? Player() : Lyric();
                }),
              ],
            ),
            SongDetails(),
          ],
        ),
      ),
    );
  }
}
