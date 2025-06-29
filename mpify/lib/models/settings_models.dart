import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/song_models.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingsCategory { general, audio, backup, troubleshooter, about }

class SettingsModels extends ChangeNotifier {
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
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkmode', isDark);
    notifyListeners();
  }

  Future<void> loadAllPrefs(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedPlaylist =
        prefs.getString('selectedPlaylist') ?? 'Playlist Name';
    if (!context.mounted) return;
    context.read<PlaylistModels>().setSelectedPlaylist(selectedPlaylist);
    final isDark = prefs.getBool('isDarkmode') ?? true;
    toogleTheme(isDark);

    final isShuffle = prefs.getBool('isShuffle') ?? true;
    context.read<SongModels>().setIsShuffe(isShuffle);

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
        context.read<SongModels>().setSongsActive(activeSong);
      });
    }
    final backgroundSongJson = prefs.getString('backgroundSong');
    if (backgroundSongJson != null) {
      final List<dynamic> songs = jsonDecode(backgroundSongJson);
      final backgroundSong = songs.map((song) => Song.fromJson(song)).toList();
      context.read<SongModels>().setSongBackGround(backgroundSong);
    }


    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SongModels>().applySort(sortOption);
    });
  }
}
