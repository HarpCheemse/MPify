import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/screen/home_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PlaylistModels()),
              ChangeNotifierProvider(create: (_) => SongModels()),
            ],
            child: MPify(),
          ),
        );
      } catch (e, stack) {
        debugPrint('error: $e');
        debugPrint('$stack');
      }
    },
    (e, stack) {
      debugPrint('error: $e');
      debugPrint('$stack');
    },
  );
}

class MPify extends StatelessWidget {
  const MPify({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
