import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mpify/func.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class Song {
  final String name;
  final String link;
  final String duration;

  Song({required this.name, required this.link, required this.duration});
}

class SongModels extends ChangeNotifier {
  List<Song> _songs = [];
  List<Song> get songs => _songs;

  int _currentSongIndex = 0;
  int get currentSongIndex => _currentSongIndex;
  Future<void> getSongIndex(songName) async {
    final index = _songs.indexWhere((song) => song.name == songName);
    if (index == -1) {
      debugPrint('$songName does not exit in the list');
      return;
    }
    _currentSongIndex = index;
    notifyListeners();
    debugPrint('$index');
  }

  Future<void> loadSong(String playlist) async {
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'playlist'));
    final filePlaylist = File(p.join(target.path, '$playlist.txt'));

    if (!await filePlaylist.exists()) {
      debugPrint('playlist does not exit');
      _songs = [];
      notifyListeners();
      return;
    }

    final lines = await filePlaylist.readAsLines();
    _songs = lines
        .map((lines) {
          final parts = lines.split(':');
          if (parts.length < 2) return null;
          return Song(name: parts[0].trim(), link: parts[1], duration: '0:00');
        })
        .whereType<Song>()
        .toList();
    notifyListeners();
  }

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  void flipIsPlaying() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void setIsPlaying(boolean) {
    _isPlaying = boolean;
  }

  Future<void> playNextSong() async {
    if (_currentSongIndex + 1 < _songs.length) {
      _currentSongIndex++;
      notifyListeners();
    } else {
      _currentSongIndex = 0;
      notifyListeners();
    }
    await AudioUtils.playSong(_songs[_currentSongIndex].name);
  }

  Future<void> playPreviousSong() async {
    if (_currentSongIndex - 1 >= 0) {
      _currentSongIndex--;
      notifyListeners();
    } else {
      _currentSongIndex = _songs.length - 1;
      notifyListeners();
    }
    await AudioUtils.playSong(_songs[_currentSongIndex].name);
  }

  void shuffleSongs() {
    _songs.shuffle();
    notifyListeners();
  }

  void sortSongsByName() {
  _songs.sort((a, b) => a.name.compareTo(b.name));
  notifyListeners();
}

  Duration _songDuration = Duration.zero;
  Duration _songProgress = Duration.zero;

  Duration get songDuration => _songDuration;
  Duration get songProgress => _songProgress;

  final AudioPlayer _audioPlayer = AudioUtils.player;

  SongModels() {
    AudioUtils.player.onPlayerComplete.listen((event) {
      playNextSong();
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      _songDuration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _songProgress = position;
      notifyListeners();
    });
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
    _songProgress = position;
    notifyListeners();
  }
}
