import 'package:flutter/material.dart';
import 'package:mpify/utils/playlist_ultis.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/audio_ultis.dart';


class Song {
  final String name;
  final String artist;
  final String duration;
  final String link;
  final DateTime dateAdded;
  final String identifier;
  Song({
    required this.name,
    required this.link,
    required this.duration,
    required this.artist,
    required this.dateAdded,
    required this.identifier,
  });
}

class SongModels extends ChangeNotifier {
  List<Song> _songsActive = []; //change when click on playlist
  List<Song> _songsBackground = []; //unchange till click on a song in a another playlist

  List<Song> get songsActive => _songsActive;
  List<Song> get songsBackground => _songsBackground;

  int _currentSongIndex = 0;
  int get currentSongIndex => _currentSongIndex;

  Future<void> getSongIndex(songIdentifier) async {
    final index = _songsBackground.indexWhere((song) => song.identifier == songIdentifier);
    if (index == -1) {
      debugPrint('$songIdentifier does not exit in the list');
      return;
    }
    _currentSongIndex = index;
    notifyListeners();
  }
  Future<void> getSongIdentifier() async {

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
    _songsActive = await PlaylistUltis.parsePlaylistJSON(playlistFile);
    notifyListeners();
  }

  Future<void> loadActivePlaylistSong() async { // start when click on a song of active playlist
    _songsBackground = _songsActive.map((song) =>
     Song(name: song.name,
      artist: song.artist,
      duration: song.duration,
      link: song.link,
      dateAdded: song.dateAdded,
      identifier: song.identifier,
     )).toList();
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
    setIsPlaying(true);
    if (_currentSongIndex + 1 < _songsBackground.length) {
      _currentSongIndex++;
      notifyListeners();
    } else {
      _currentSongIndex = 0;
      notifyListeners();
    }
    await AudioUtils.playSong(_songsBackground[_currentSongIndex].identifier);
    debugPrint('$_currentSongIndex');
  }

  Future<void> playPreviousSong() async {
    if (_currentSongIndex - 1 >= 0) {
      _currentSongIndex--;
      notifyListeners();
    } else {
      _currentSongIndex = _songsBackground.length - 1;
      notifyListeners();
    }
    await AudioUtils.playSong(_songsBackground[_currentSongIndex].identifier);
    debugPrint('$_currentSongIndex');
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
