import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';

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

  static Future<Directory> checkBackupFolderExist() async {
    final currentDir = Directory.current;
    final backupDir = Directory(p.join(currentDir.path, '..', 'backup'));
    if (!await backupDir.exists()) {
      debugPrint('Folder backup missing. Creating new one ...');
      await backupDir.create(recursive: true);
    }
    return backupDir;
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

  static void writeLyricToFolder(text, identifier) async {
    final lyricDir = await checkLyricFolderExist();
    final lyricFile = File(p.join(lyricDir.path, '$identifier.txt'));
    if (!await lyricFile.exists()) {
      lyricFile.create(recursive: true);
    }
    await lyricFile.writeAsString(text);
    debugPrint('$text');
  }

  static Future<String?> getSongLyric(String identifier) async {
    final lyricDir = await checkLyricFolderExist();
    final lyricFile = File(p.join(lyricDir.path, '$identifier.txt'));
    if (!await lyricFile.exists()) return null;
    final text = await lyricFile.readAsString();
    return text;
  }

  static Future<bool> createBackupFile(String playlist) async {
    final timeStamp = DateTime.now();
    final backupDir = await FolderUtils.checkBackupFolderExist();
    final playlistDir = await FolderUtils.checkPlaylistFolderExist();
    final backupName =
        '${timeStamp.year}_${timeStamp.month}_${timeStamp.day}_${timeStamp.hour}_${timeStamp.minute}_${timeStamp.second}_backup';
    final backupFolder = Directory(p.join(backupDir.path, backupName));
    await backupFolder.create(recursive: true);
    final playlistJson = File(p.join(playlistDir.path, '$playlist.json'));
    if (!await playlistJson.exists()) {
      return false;
    }

    //copy metaData
    await File(p.join(backupFolder.path, 'metadata.json')).create(recursive: true);
    List<dynamic> songs = [];
    final contents = await playlistJson.readAsString();
    if (contents.isNotEmpty) {
      songs = jsonDecode(contents);
    }
    await File(
      p.join(backupFolder.path, 'metadata.json'),
    ).writeAsString(jsonEncode(songs), mode: FileMode.write);
    //copy cover
    try {
      final backupCoverDir = Directory(p.join(backupFolder.path, 'cover'));
      await backupCoverDir.create(recursive: true);
      final coverDir = await checkCoverFolderExist();
      for (int i = 0; i < songs.length; i++) {
        final identifier = songs[i]['identifier'];
        final coverFile = File(p.join(coverDir.path, '$identifier.png'));
        if (!await coverFile.exists()) continue;
        await File(
          coverFile.path,
        ).copy(p.join(backupCoverDir.path, '$identifier.png'));
      }
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
    //copy lyric
    try {
      final backupLyricDir = Directory(p.join(backupFolder.path, 'lyric'));
      await backupLyricDir.create(recursive: true);
      final lyricDir = await checkLyricFolderExist();
      for (int i = 0; i < songs.length; i++) {
        final identifier = songs[i]['identifier'];
        final lyricFile = File(p.join(lyricDir.path, '$identifier.txt'));
        if (!await lyricFile.exists()) continue;
        await File(
          lyricFile.path,
        ).copy(p.join(backupLyricDir.path, '$identifier.txt'));
      }
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
    //copy mp3
    try {
      final backupMP3Dir = Directory(p.join(backupFolder.path, 'mp3'));
      await backupMP3Dir.create(recursive: true);
      final mp3Dir = await checkMP3FolderExist();
      for (int i = 0; i < songs.length; i++) {
        final identifier = songs[i]['identifier'];
        final mp3File = File(p.join(mp3Dir.path, '$identifier.mp3'));
        if (!await mp3File.exists()) continue;
        await File(
          mp3File.path,
        ).copy(p.join(backupMP3Dir.path, '$identifier.mp3'));
      }
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
    //zip file
    await Future.delayed(Duration(milliseconds: 500));
    try {
      final zipPath = backupFolder.path + '.zip';
      final zipFile = File(zipPath);
      await zipFolder(backupFolder, zipFile);
    }
    catch (e) {
      debugPrint('Error: $e');
      return false;
    }
    //delete the Dir
    try {
      await backupFolder.delete(recursive: true);
    }
    catch (e) {
      debugPrint('Error: $e');
      return false;
    }
    return true;
  }
  static Future<void> zipFolder(Directory inputDir, File outputFile) async {
    final ZipFileEncoder zipEncoder = ZipFileEncoder();
    zipEncoder.create(outputFile.path);
    await zipEncoder.addDirectory(inputDir);
    zipEncoder.close();
  }
}
