import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mpify/models/playback_models.dart';
import 'package:mpify/utils/playlist_ultis.dart';
import 'package:mpify/utils/string_ultis.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/audio_ultis.dart';

import 'package:shared_preferences/shared_preferences.dart';

//Handle Song Related

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
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      name: json['name'],
      link: json['link'],
      duration: json['duration'],
      artist: json['artist'],
      dateAdded: DateTime.parse(json['dateAdded']),
      identifier: json['identifier'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'link': link,
      'duration': duration,
      'artist': artist,
      'dateAdded': dateAdded.toIso8601String(),
      'identifier': identifier,
    };
  }
}

enum SortOption {
  newest,
  lastest,
  nameAZ,
  nameZA,
  artistAZ,
  artistZA,
  durationLongest,
  durationShortest,
}

class SongModels extends ChangeNotifier {
  final PlaybackModels playbackModels;
  SongModels({required this.playbackModels});
  void refresh() {
    notifyListeners();
  }

  List<String> _artistList = [];
  List<String> get artistList => _artistList;

  void loadArtistList() {
    _artistList = _songsActive.map((song) => song.artist).toSet().toList();
    _artistList.sort((a, b) => a.compareTo(b));
    notifyListeners();
  }

  SortOption _sortOption = SortOption.newest;
  SortOption get sortOption => _sortOption;

  void updateSortOption(SortOption option) async {
    _sortOption = option;
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('sortOption', option.name);
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Saved Sort Option Prefs');
    }
    applySortActivePlaylist(option);
    applySortBackgroundPlaylist(option);
  }

  List<Song> _songsActive = []; //change when click on playlist
  void setSongsActive(List<Song> songs) {
    _songsActive = songs;
    notifyListeners();
  }

  List<Song> _songsBackground =
      []; //unchange till click on a song in a another playlist

  List<Song> get songsActive {
    if (_searchQuery.isEmpty) {
      return _songsActive;
    } else {
      final q = _searchQuery.toLowerCase();
      return _songsActive
          .where(
            (song) =>
                song.name.toLowerCase().contains(q) ||
                song.artist.toLowerCase().contains(q),
          )
          .toList();
    }
  }

  List<Song> get songsBackground => _songsBackground;

  //find the song idex from list after choose a random song by hand

  Future<void> loadSong(String playlist) async {
    final playlistDir = await FolderUtils.checkPlaylistFolderExist();
    final playlistFile = File(p.join(playlistDir.path, '$playlist.json'));

    if (!await playlistFile.exists()) {
      _songsActive = [];
      notifyListeners();
      return;
    }
    _songsActive = List<Song>.from(
      await PlaylistUltis.parsePlaylistJSON(playlistFile),
    );
    applySortActivePlaylist(_sortOption);
    applySortBackgroundPlaylist(_sortOption);
    if (playbackModels.isShuffle) {
      shuffleSongs(playbackModels.currentSongIndex);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
        'activeSong',
        jsonEncode(_songsActive.map((song) => song.toJson()).toList()),
      );
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Save Active Playlist Prefs');
      return;
    }
    notifyListeners();
  }

  Future<void> loadActivePlaylistSong() async {
    if (_songsActive.isEmpty) _songsBackground = [];
    // start when click on a song of active playlist
    _songsBackground = _songsActive
        .map(
          (song) => Song(
            name: song.name,
            artist: song.artist,
            duration: song.duration,
            link: song.link,
            dateAdded: song.dateAdded,
            identifier: song.identifier,
          ),
        )
        .toList();
    //shufle background except the current index
    if (playbackModels.isShuffle) {
      shuffleSongs(playbackModels.currentSongIndex);
    }
  }

  void setSongBackGround(List<Song> songs) async {
    _songsBackground = songs;
    notifyListeners();
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void updateSongSearchQuery(query) {
    _searchQuery = query;
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
    if (_songsBackground.isEmpty) return;
    final index = playbackModels.currentSongIndex;
    setIsPlaying(true);
    if (index < 0 || index > _songsBackground.length) {
      return;
    }
    if (index + 1 < _songsBackground.length) {
      playbackModels.setSongIndex(index + 1);
    } else {
      playbackModels.setSongIndex(0);
    }
    notifyListeners();
    await AudioUtils.playSong(
      _songsBackground[playbackModels.currentSongIndex].identifier,
    );
  }

  Future<void> playPreviousSong() async {
    if (_songsBackground.isEmpty) return;
    final index = playbackModels.currentSongIndex;
    if (index < 0 || index > _songsBackground.length) {
      return;
    }
    if (index - 1 >= 0) {
      playbackModels.setSongIndex(index - 1);
    } else {
      playbackModels.setSongIndex(_songsBackground.length - 1);
    }
    notifyListeners();
    await AudioUtils.playSong(
      _songsBackground[playbackModels.currentSongIndex].identifier,
    );
  }

  void applySortBackgroundPlaylist(SortOption option) async {
    if (_songsBackground.isEmpty) return;
    String prevSongIdentifier =
        _songsBackground[playbackModels.currentSongIndex].identifier;
    //To Trigger Selector
    List<Song> tempSongList = [..._songsBackground];
    switch (option) {
      case SortOption.nameAZ:
        tempSongList.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case SortOption.nameZA:
        tempSongList.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.artistAZ:
        tempSongList.sort(
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
        break;
      case SortOption.artistZA:
        tempSongList.sort(
          (a, b) => b.artist.toLowerCase().compareTo(a.artist.toLowerCase()),
        );
        break;
      case SortOption.lastest:
        tempSongList.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        break;
      case SortOption.newest:
        tempSongList.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case SortOption.durationLongest:
        tempSongList.sort(
          (a, b) => StringUltis.getDurationFromString(
            b.duration,
          ).compareTo(StringUltis.getDurationFromString(a.duration)),
        );
        break;
      case SortOption.durationShortest:
        tempSongList.sort(
          (a, b) => StringUltis.getDurationFromString(
            a.duration,
          ).compareTo(StringUltis.getDurationFromString(b.duration)),
        );
        break;
    }
    for (int i = 0; i < _songsBackground.length; i++) {
      if (tempSongList[i].identifier == prevSongIdentifier) {
        playbackModels.setSongIndex(i);
        break;
      }
    }
    _songsBackground = tempSongList;
    notifyListeners();
  }

  void applySortActivePlaylist(SortOption option) async {
    if (_songsActive.isEmpty) return;
    //To Trigger Selector
    List<Song> tempSongList = [..._songsActive];
    switch (option) {
      case SortOption.nameAZ:
        tempSongList.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case SortOption.nameZA:
        tempSongList.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
      case SortOption.artistAZ:
        tempSongList.sort(
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
        break;
      case SortOption.artistZA:
        tempSongList.sort(
          (a, b) => b.artist.toLowerCase().compareTo(a.artist.toLowerCase()),
        );
        break;
      case SortOption.lastest:
        tempSongList.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        break;
      case SortOption.newest:
        tempSongList.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case SortOption.durationLongest:
        tempSongList.sort(
          (a, b) => StringUltis.getDurationFromString(
            b.duration,
          ).compareTo(StringUltis.getDurationFromString(a.duration)),
        );
        break;
      case SortOption.durationShortest:
        tempSongList.sort(
          (a, b) => StringUltis.getDurationFromString(
            a.duration,
          ).compareTo(StringUltis.getDurationFromString(b.duration)),
        );
        break;
    }
    _songsActive = tempSongList;
    notifyListeners();
  }

  void unshuffleSongs() async {
    if (_songsBackground.isEmpty) return;
    String prevSongIdentifier =
        _songsBackground[playbackModels.currentSongIndex].identifier;
    applySortBackgroundPlaylist(_sortOption);
    for (int i = 0; i < _songsBackground.length; i++) {
      if (_songsBackground[i].identifier == prevSongIdentifier) {
        playbackModels.setSongIndex(i);
        break;
      }
    }
    notifyListeners();
  }

  void shuffleSongs(int fixedIndex) {
    if (fixedIndex < 0 && fixedIndex > songsBackground.length) return;
    final rand = Random();
    for (int i = 0; i < _songsBackground.length; i++) {
      if (i == fixedIndex) continue;
      int j;
      do {
        j = rand.nextInt(i + 1);
      } while (j == fixedIndex);
      final temp = songsBackground[i];
      _songsBackground[i] = _songsBackground[j];
      _songsBackground[j] = temp;
    }
    notifyListeners();
  }
}
