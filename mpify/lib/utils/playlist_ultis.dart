import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';

import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/audio_ultis.dart';
import 'package:mpify/utils/string_ultis.dart';

import 'package:provider/provider.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/models/song_models.dart';

//Functions that manipulate playlist related stuff

class PlaylistUltis {
  static Future<void> downloadMP3(BuildContext context, name, link) async {
    final playlist = context.read<PlaylistModels>().selectedPlaylist;
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'mp3'));

    final trimmedLink = link.split('&')[0];
    final cleanName = name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final identifier = StringUltis.hashYoutubeLink(link);
    if (!await target.exists()) {
      debugPrint('Folder $target does not exit');
      target.create(recursive: true);
      return;
    }
    final process = await Process.start(
      'yt-dlp',
      ['-x', '--audio-format', 'mp3', '--no-continue', '-o', '$identifier.%(ext)s', trimmedLink],
      workingDirectory: target.path,
      runInShell: true,
    );
    process.stdout.transform(SystemEncoding().decoder).listen((data) {
      debugPrint('[stdout] $data');
    });
    process.stderr.transform(SystemEncoding().decoder).listen((data) {
      debugPrint('[stderr] $data');
    });

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      debugPrint('Error downloading mp3');
      return;
    }
    if (await PlaylistUltis.writeSongToPlaylist(
      playlist,
      cleanName,
      trimmedLink,
      identifier,
    )) {
      debugPrint('Download successed');
    }
    else {
      debugPrint('Error. Download Canceled');
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
      debugPrint('$playlistFile missing');
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
      debugPrint('Error writing file json $e');
      return false;
    }
    return true;
  }

  static Future<List<Song>> parsePlaylistJSON(file) async {
    final List<Song> parsedSongs = [];
    final contents = await file.readAsString();
    try {
      if (contents.trim().isEmpty) {
        debugPrint('file playlist.json empty');
        return parsedSongs;
      }

      final List<dynamic> songs = jsonDecode(contents);
      for (var song in songs) {
        final name = song['name'];
        final duration = song['duration'];
        final link = song['link'];
        final artist = song['artist'];
        final dateAdded = DateTime.parse(song['dateAdded']);
        final identifier = song['identifier'];
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
    } catch (e) {
      debugPrint('$e');
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
