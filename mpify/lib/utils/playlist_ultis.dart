import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mpify/utils/misc_utils.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';

import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/audio_ultis.dart';
import 'package:mpify/utils/string_ultis.dart';

import 'package:provider/provider.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/song_models.dart';

class PlaylistUltis {
  static Future<void> downloadMP3(BuildContext context, name, link) async {
    MiscUtils.showNotification('Attemping To Download $name');
    final playlist = context.read<PlaylistModels>().selectedPlaylist;
    final mp3Dir = await FolderUtils.checkMP3FolderExist();

    final trimmedLink = link.split('&')[0];
    final cleanName = name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final identifier = StringUltis.hashYoutubeLink(link);
    try {
      final process = await Process.start(
        'yt-dlp',
        [
          '-x',
          '--audio-format',
          'mp3',
          '--no-continue',
          '-o',
          '$identifier.%(ext)s',
          trimmedLink,
        ],
        workingDirectory: mp3Dir.path,
        runInShell: true,
      );
      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        FolderUtils.writeLog('[stdout] $data');
      });
      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        FolderUtils.writeLog('[stderr] $data');
      });

      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        MiscUtils.showError('Error: Unable To Download $name');
        FolderUtils.writeLog('Error: Unable To Download $name');
        return;
      }
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Run yt-dlp.exe');
      MiscUtils.showError('Error: Unable To Run yt-dlp.exe');
    }
    if (await PlaylistUltis.writeSongToPlaylist(
      playlist,
      cleanName,
      trimmedLink,
      identifier,
    )) {
      MiscUtils.showSuccess('Download $name Successfully');
    } else {
      MiscUtils.showError('Error Writing $name To File. Proccess Canceled');
    }
  }

  static Future<bool> writeSongToPlaylist(
    String playlist,
    String name,
    String link,
    String identifier, {
    String artist = 'Unknown',
  }) async {
    final targetDir = await FolderUtils.checkPlaylistFolderExist();
    final playlistFile = File(p.join(targetDir.path, '$playlist.json'));

    if (!await playlistFile.exists()) {
      FolderUtils.writeLog(
        'Error: Unable To Write Song. $playlist.json Missing',
      );
      return false;
    }

    final duration = await AudioUtils.getSongDuration(identifier);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final formartedDuration = '$minutes:$seconds';
    final newSong = {
      'name': name,
      'duration': formartedDuration,
      'link': link,
      'artist': artist,
      'dateAdded': DateTime.now().toIso8601String(),
      'identifier': identifier,
    };
    try {
      final contents = await playlistFile.readAsString();
      List<dynamic> songs = [];
      if (contents.isNotEmpty) {
        songs = jsonDecode(contents);
      }
      songs.add(newSong);
      await playlistFile.writeAsString(jsonEncode(songs), mode: FileMode.write);
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Write Song To $playlist.json');
      return false;
    }
    return true;
  }

  static Future<List<Song>> parsePlaylistJSON(file) async {
    List<Song> parsedSongs = [];
    String contents;
    List<dynamic> songs;
    try {
      contents = await file.readAsString();
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Error Reading $file');
      return parsedSongs;
    }
    if (contents.trim().isEmpty) {
      FolderUtils.writeLog('$file is empty');
      return parsedSongs;
    }

    try {
      songs = jsonDecode(contents);
    } catch (e) {
      FolderUtils.writeLog('Error: $e. Unable To Decode Json $file');
      return parsedSongs;
    }
    int errorCount = 0;
    for (var song in songs) {
      try {
        final String name = song['name'];
      final String duration = song['duration'];
      final String link = song['link'];
      final String artist = song['artist'];
      final DateTime dateAdded = DateTime.parse(song['dateAdded']);
      final String identifier = song['identifier'];
      parsedSongs.add(
        Song(
          name: name,
          identifier: identifier,
          duration: duration,
          link: link,
          artist: artist,
          dateAdded: dateAdded,
        ),
      );
      }
      catch (e) {
        errorCount++;
        FolderUtils.writeLog('Error: $e. Unable To Parse Song $song');
      }
    }
    if (errorCount > 0) {
      MiscUtils.showError('Error: Unable To Parse $errorCount song(s). Check log.txt For More Details');
    }
    return parsedSongs;
  }

  static Future<void> deletePlaylist(String playlist) async {
    final playlistDir = await FolderUtils.checkPlaylistFolderExist();
    final playlistFile = File(p.join(playlistDir.path, '$playlist.json'));
    if (!await playlistFile.exists()) {
      debugPrint('$playlist.json does not exit');
      return;
    }
    await playlistFile.delete();
  }

  static Future<void> deleteSongFromPlaylist(
    identifier,
    selectedPlaylist,
  ) async {
    final playlistDir = await FolderUtils.checkPlaylistFolderExist();
    final playlistFile = File(
      p.join(playlistDir.path, '$selectedPlaylist.json'),
    );
    if (!await playlistFile.exists()) {
      debugPrint("$selectedPlaylist does not exist");
      return;
    }
    try {
      final contents = await playlistFile.readAsString();
      List<dynamic> songs = contents.isNotEmpty ? jsonDecode(contents) : [];
      final updatedList = songs.where((song) {
        return song['identifier'] != identifier;
      }).toList();
      await playlistFile.writeAsString(
        jsonEncode(updatedList),
        mode: FileMode.write,
      );
    } catch (e) {
      debugPrint('$e');
    }
  }

  static Future<void> deleteSongFromDevice(identifier) async {
    final playlistDir = await FolderUtils.checkPlaylistFolderExist();
    final playlists = playlistDir
        .listSync()
        .where((file) => file.path.endsWith('.json'))
        .toList();
    debugPrint('Deleting $identifier from device');
    for (final playlist in playlists) {
      try {
        //delete song from playlist.json
        final file = File(playlist.path);
        final contents = await file.readAsString();
        List<dynamic> songs = contents.isNotEmpty ? jsonDecode(contents) : [];
        final updatedList = songs.where((song) {
          return song['identifier'] != identifier;
        }).toList();
        await file.writeAsString(jsonEncode(updatedList), mode: FileMode.write);
      } catch (e) {
        debugPrint('$e');
      }
    }
    //delete song.mp3 from mp3 folder
    final mp3Dir = await FolderUtils.checkMP3FolderExist();
    final mp3File = File(p.join(mp3Dir.path, '$identifier.mp3'));
    try {
      if (await mp3File.exists()) {
        mp3File.delete();
      } else {
        debugPrint('$mp3File does not exist');
      }
    } catch (e) {
      debugPrint('$e');
    }
    //delete song cover from cover fodler
    final coverDir = await FolderUtils.checkCoverFolderExist();
    final coverFile = File(p.join(coverDir.path, '$identifier.png'));
    try {
      if (await coverFile.exists()) {
        coverFile.delete();
      } else {
        debugPrint('$coverFile does not exist');
      }
    } catch (e) {
      debugPrint('$e');
    }
    //delete song lyric
    final lyricDir = await FolderUtils.checkLyricFolderExist();
    final lyricFile = File(p.join(lyricDir.path, '$identifier.txt'));
    try {
      if (await lyricFile.exists()) {
        lyricFile.delete();
      } else {
        debugPrint('$lyricFile does not exist');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }
}
