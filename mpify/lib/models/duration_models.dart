import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/audio_ultis.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:window_manager/window_manager.dart';

//Handle Duration
bool _isWindowActive = true;

class DurationModels extends ChangeNotifier {
  final SongModels songModels;
  final AudioPlayer _audioPlayer = AudioUtils.player;
  Timer? intervalTimer;
  Duration latestDuration = Duration.zero;
  Duration latestProgress = Duration.zero;

  DurationModels({required this.songModels}) {
    AudioUtils.player.onPlayerComplete.listen((event) {
      songModels.playNextSong();
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      latestDuration = duration;
    });
    _audioPlayer.onPositionChanged.listen((position) {
      latestProgress = position;
    });

    Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if ((latestDuration != _songDuration ||
              latestProgress != _songProgress) &&
          _isWindowActive) {
        final isMinimized = await windowManager.isMinimized();
        if (!isMinimized) {
          _songDuration = latestDuration;
          _songProgress = latestProgress;
          notifyListeners();
        }
      }
    });
  }
  Duration _songDuration = Duration.zero;
  Duration _songProgress = Duration.zero;

  Duration get songDuration => _songDuration;
  Duration get songProgress => _songProgress;

  void setSongDurationZero() {
    _songDuration = Duration.zero;
    _songProgress = Duration.zero;
  }

  void seek(Duration position) {
    if (songDuration.inSeconds <= 0) return;
    try {
      _audioPlayer.seek(position);
      _songProgress = position;
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Seek To $position.');
    }
    notifyListeners();
  }
}
