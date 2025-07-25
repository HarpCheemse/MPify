import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mpify/models/duration_models.dart';
import 'package:mpify/models/playback_models.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/settings_models.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/screen/home_screen.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/misc_utils.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

double maxScreenWidth = 1920;
double maxScreenHeight = 1080;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final PlaylistModels playlistModels = PlaylistModels();
  final PlaybackModels playbackModels = PlaybackModels();
  final SongModels songModels = SongModels(playbackModels: playbackModels);
  final SettingsModels settingsModels = SettingsModels(
    songModels: songModels,
    playbackModels: playbackModels,
  );
  final DurationModels durationModels = DurationModels(songModels: songModels);
  playbackModels.songModels = songModels;

  runZonedGuarded(
    () async {
      await FolderUtils.clearLog();
      if (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows) {
        await windowManager.ensureInitialized();

        await windowManager.waitUntilReadyToShow();
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
        await windowManager.maximize();

        windowManager.setMinimumSize(const Size(720, 720));
        maxScreenWidth = await MiscUtils.getPhysicalScreenWidth();
        maxScreenHeight = await MiscUtils.getPhysicalScreenHeight();
      }

      try {
        runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: playbackModels),
              ChangeNotifierProvider.value(value: playlistModels),
              ChangeNotifierProvider.value(value: settingsModels),
              ChangeNotifierProvider.value(value: songModels),
              ChangeNotifierProvider.value(value: durationModels),
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
    final themeProvider = Provider.of<SettingsModels>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          surface: Colors.white,
          primary: Colors.lightBlueAccent,
          onSurface: Colors.black,
          surfaceContainer: const Color.fromARGB(255, 221, 221, 221),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          surface: Colors.black,
          primary: Colors.teal,
          onSurface: Colors.white,
          surfaceContainer: const Color.fromARGB(255, 24, 24, 24),
        ),
      ),
      themeMode: themeProvider.themeMode,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: const HomeScreen(),
    );
  }
}
