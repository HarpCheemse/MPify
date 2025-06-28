import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/settings_models.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/screen/home_screen.dart';
import 'package:mpify/widgets/settings.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await windowManager.ensureInitialized();
      windowManager.waitUntilReadyToShow().then((_) async {
        await windowManager.maximize();
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      });
      try {
        runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PlaylistModels()),
              ChangeNotifierProvider(create: (_) => SongModels()),
              ChangeNotifierProvider(create: (_) => SettingsModels())
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
      theme: ThemeData(
      ),
      home: const HomeScreen(),
    );
  }
}
