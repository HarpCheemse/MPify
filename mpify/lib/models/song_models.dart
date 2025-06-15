import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class Song {
  final String name;
  final String link;
  final String duration;

  Song({required this.name, required this.link, required this.duration});
}

class SongModels extends ChangeNotifier {
  List<Song> _songs = [];
  List<Song> get songs => _songs;

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
}
