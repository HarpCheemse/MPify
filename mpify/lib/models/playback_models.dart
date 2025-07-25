import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Handle Play Functionality Related

class PlaybackModels extends ChangeNotifier {
  late final SongModels songModels;
  PlaybackModels();

  bool _isShuffle = true;
  bool get isShuffle => _isShuffle;

  int _currentSongIndex = 0;
  int get currentSongIndex => _currentSongIndex;

  String? getCurrentIdentifier() {
    if (songModels.songsBackground.isEmpty) return null;
    if (_currentSongIndex < 0 || _currentSongIndex >= songModels.songsBackground.length) return null;
    return songModels.songsBackground[_currentSongIndex].identifier;
  }

  Future<void> getSongIndex(songIdentifier) async {
    final index = songModels.songsBackground.indexWhere(
      (song) => song.identifier == songIdentifier,
    );
    if (index == -1) {
      debugPrint('$songIdentifier does not exit in the list');
      return;
    }
    _currentSongIndex = index;
    notifyListeners();
  }

  void setSongIndex(int index) {
    _currentSongIndex = index;
  }

  void flipIsShuffle() async {
    _isShuffle = !_isShuffle;
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isShuffle', _isShuffle);
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Saved Shuffle Prefs');
    }
    notifyListeners();
  }

  void setIsShuffe(isShuffle) {
    _isShuffle = isShuffle;
    notifyListeners();
  }
}
