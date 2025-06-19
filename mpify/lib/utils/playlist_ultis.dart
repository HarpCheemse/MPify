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
      ['-x', '--audio-format', 'mp3', '-o', '$identifier.%(ext)s', trimmedLink],
      workingDirectory: target.path,
      runInShell: true,
    );

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
      debugPrint('Error Writing File. Download canceled');
      return;
    }
  }
  static Future<bool> writeSongToPlaylist(
    String playlist,
    String name,
    String link,
    String identifier, {
    String artist = 'Unknown',
    String? imagePath,
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
      'imagePath': imagePath,
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
      final imagePath = song['imagePath'];
      final identifier = song['identifier'];
      parsedSongs.add(
        Song(
          name: name,
          identifier: identifier,
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
    return parsedSongs;
  }
}