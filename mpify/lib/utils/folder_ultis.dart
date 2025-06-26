import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

class FolderUtils {
  static Future<void> createPlaylistFolder(folderName) async {
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'playlist'));
    if (!await target.exists()) {
      await target.create(recursive: true);
    }
    final filePath = p.join(target.path, '$folderName.json');
    final file = File(filePath);
    await file.writeAsString('');
  }

  static Future<Directory> checkPlaylistFolderExist() async {
    final currentDir = Directory.current;
    final playlistDir = Directory(p.join(currentDir.path, '..', 'playlist'));
    if (!await playlistDir.exists()) {
      debugPrint('Folder playlist missing');
      await playlistDir.create(recursive: true);
    }
    return playlistDir;
  }

  static Future<Directory> checkMP3FolderExist() async {
    final curretDir = Directory.current;
    final mp3Dir = Directory(p.join(curretDir.path, '..', 'mp3'));
    if (!await mp3Dir.exists()) {
      debugPrint('Folder mp3 missing. Creating new one ...');
      await mp3Dir.create(recursive: true);
    }
    return mp3Dir;
  }

  static Future<Directory> checkCoverFolderExist() async {
    final currentDir = Directory.current;
    final coverDir = Directory(p.join(currentDir.path, '..', 'cover'));
    if (!await coverDir.exists()) {
      debugPrint('Folder mp3 missing. Creating new one ...');
      await coverDir.create(recursive: true);
    }
    return coverDir;
  }

  static Future<Directory> checkLyricFolderExist() async {
    final currentDir = Directory.current;
    final lyricDir = Directory(p.join(currentDir.path, '..', 'lyric'));
    if (!await lyricDir.exists()) {
      debugPrint('Folder lyric missing. Creating new one ...');
      await lyricDir.create(recursive: true);
    }
    return lyricDir;
  }

  static void openFolderInExplorer() async {
    final path = await FolderUtils.checkPlaylistFolderExist();
    if (Platform.isWindows) {
      Process.run('explorer', [path.path]);
    } else if (Platform.isMacOS) {
      Process.run('open', [path.path]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [path.path]);
    }
  }
  static void writeLyricToFolder(text,identifier) async {
    final lyricDir = await checkLyricFolderExist();
    final lyricFile = File(p.join(lyricDir.path, '$identifier.txt'));
    if(!await lyricFile.exists()) {
      lyricFile.create(recursive: true);
    }
    await lyricFile.writeAsString(text);
    debugPrint('$text');
  }
  static Future<String?> getSongLyric(String identifier) async {
    final lyricDir = await checkLyricFolderExist();
    final lyricFile = File(p.join(lyricDir.path, '$identifier.txt'));
    if(!await lyricFile.exists()) return null;
    final text = await lyricFile.readAsString();
    return text;
  }
}
