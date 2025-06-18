import 'dart:convert';

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
  final String artist;
  final String duration;
  final String link;
  final DateTime dateAdded;
  final String? imagePath;
  Song({
    required this.name,
    required this.link,
    required this.duration,
    required this.artist,
    required this.dateAdded,
    required this.imagePath,
  });
}

class SongModels extends ChangeNotifier {
  List<Song> _songsActive = []; //change when click on playlist
  List<Song> _songsBackground = []; //unchange till click on a song in a another playlist

  List<Song> get songsActive => _songsActive;
  List<Song> get songsBackground => _songsBackground;

  int _currentSongIndex = 0;
  int get currentSongIndex => _currentSongIndex;

  Future<void> getSongIndex(songName) async {
    final index = _songsBackground.indexWhere((song) => song.name == songName);
    if (index == -1) {
      debugPrint('$songName does not exit in the list');
      return;
    }
    _currentSongIndex = index;
    notifyListeners();
    debugPrint('$index');
  }

  Future<void> loadSong(String playlist) async {
    final playlistDir = await FolderUtils.checkPlaylistFolderExist();
    final playlistFile = File(p.join(playlistDir.path, '$playlist.json'));

    if (!await playlistFile.exists()) {
      debugPrint('playlist does not exit');
      _songsActive = [];
      notifyListeners();
      return;
    }
    _songsActive = [];
    await parsePlaylistJSON(playlistFile);
    notifyListeners();
  }

  Future<void> loadActivePlaylistSong() async { // start when click on a song of active playlist
    _songsBackground = _songsActive.map((song) =>
     Song(name: song.name,
      artist: song.artist,
      duration: song.duration,
      link: song.link,
      dateAdded: song.dateAdded,
      imagePath: song.imagePath
     )).toList();
  }

  Future<void> parsePlaylistJSON(file) async {
    final contents = await file.readAsString();
    try {
      if (contents.trim().isEmpty) {
      debugPrint('file playlist.json empty');
      return;
    }
    final List<dynamic> songs = jsonDecode(contents);
    for (var song in songs) {
      final name = song['name'];
      final duration = song['duration'];
      final link = song['link'];
      final artist = song['artist'];
      final dateAdded = DateTime.parse(song['dateAdded']);
      final imagePath = song['ImagePath'];
      _songsActive.add(
        Song(
          name: name,
          duration: duration,
          link: link,
          artist: artist,
          dateAdded: dateAdded,
          imagePath: imagePath,
        ),
      );
    }
    }
    catch (e) {
      debugPrint('$e');
    }
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
    if (_currentSongIndex + 1 < _songsBackground.length) {
      _currentSongIndex++;
      notifyListeners();
    } else {
      _currentSongIndex = 0;
      notifyListeners();
    }
    await AudioUtils.playSong(_songsBackground[_currentSongIndex].name);
  }

  Future<void> playPreviousSong() async {
    if (_currentSongIndex - 1 >= 0) {
      _currentSongIndex--;
      notifyListeners();
    } else {
      _currentSongIndex = _songsBackground.length - 1;
      notifyListeners();
    }
    await AudioUtils.playSong(_songsBackground[_currentSongIndex].name);
  }

  void shuffleSongs() {
    _songsBackground.shuffle();
    notifyListeners();
  }

  void sortSongsByName() {
    _songsBackground.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Duration _songDuration = Duration.zero;
  Duration _songProgress = Duration.zero;

  Duration get songDuration => _songDuration;
  Duration get songProgress => _songProgress;

  final _audioPlayer = AudioUtils.player;

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
