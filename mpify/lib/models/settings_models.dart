import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mpify/models/playback_models.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Handle Setting Related

enum SettingsCategory { general, audio, backup, troubleshooter, about }

class SettingsModels extends ChangeNotifier {
  final SongModels songModels;
  final PlaybackModels playbackModels;
  final PlaylistModels playlistModels;
  SettingsModels({
    required this.songModels,
    required this.playbackModels,
    required this.playlistModels,
  });

  bool _isOpenSettings = false;
  bool get isOpenSettings => _isOpenSettings;
  void flipIsOpenSetting() {
    _isOpenSettings = !_isOpenSettings;
    notifyListeners();
  }

  SettingsCategory _selectedCategory = SettingsCategory.general;
  SettingsCategory get selectedCategory => _selectedCategory;

  void setSettingCategory(SettingsCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toogleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isDarkmode', isDark);
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Saved Dark Mode Prefs');
    }

    notifyListeners();
  }

  Future<void> loadAllPrefs() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable to Load Prefs');
      return;
    }
    final selectedPlaylist =
        prefs.getString('selectedPlaylist') ?? 'Playlist Name';
    playlistModels.setSelectedPlaylist(selectedPlaylist);
    final isDark = prefs.getBool('isDarkmode') ?? true;
    toogleTheme(isDark);

    final isShuffle = prefs.getBool('isShuffle') ?? true;
    playbackModels.setIsShuffe(isShuffle);

    final sortOptioStr = prefs.getString('sortOption');
    final sortOption = SortOption.values.firstWhere(
      (e) => e.name == sortOptioStr,
      orElse: () => SortOption.newest,
    );

    final activeSongJson = prefs.getString('activeSong');
    if (activeSongJson != null) {
      final List<dynamic> songs = jsonDecode(activeSongJson);
      final activeSong = songs.map((song) => Song.fromJson(song)).toList();
      //wait for ui to build first
      WidgetsBinding.instance.addPostFrameCallback((_) {
        songModels.setSongsActive(activeSong);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      songModels.applySortActivePlaylist(sortOption);
    });
    notifyListeners();
  }

  bool _showArtist = true;
  bool get showArtist => _showArtist;
  void setShowArtist(bool value) {
    if (_showArtist == value) return;
    _showArtist = value;
    notifyListeners();
  }

  bool _showDuration = true;
  bool get showDuration => _showDuration;
  void setShowDuration(bool value) {
    if (_showDuration == value) return;
    _showDuration = value;
    notifyListeners();
  }
}
