import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mpify/models/song_models.dart';
import 'package:path/path.dart' as p;

import 'package:provider/provider.dart';
import 'package:mpify/models/playlist_models.dart';

//Global Var
ValueNotifier<List<String>> playlistNotifer = ValueNotifier([]);

class FolderUtils {
  static Future<void> createPlaylistFolder(folderName) async {
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'playlist'));
    if (!await target.exists()) {
      await target.create(recursive: true);
    }
    final filePath = p.join(target.path, '$folderName.txt');
    final file = File(filePath);
    await file.writeAsString('');
  }

  static Future<void> downloadMP3(BuildContext context, name, link) async {
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'mp3'));

    final trimmedLink = link.split('&')[0];
    final cleanName = name.replaceAll(RegExp(r'[^\w\-]'), '_');

    if (PlaylistUltis.writeSongToPlaylist(context, cleanName, trimmedLink) ==
        0) {
      debugPrint('Error Writing File. Download canceled');
      return;
    }
    final process = await Process.start(
      'yt-dlp',
      ['-x', '--audio-format', 'mp3', '-o', '$cleanName.%(ext)s', trimmedLink],
      workingDirectory: target.path,
      runInShell: true,
    );
    process.stdout.transform(SystemEncoding().decoder).listen((data) {
      debugPrint('[stdout] $data');
    });
    process.stderr.transform(SystemEncoding().decoder).listen((data) {
      debugPrint('[stderr] $data');
    });
  }

  static Future<void> playlistWatcher() async {
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'playlist'));
    if (!await target.exists()) {
      debugPrint('folder playlist missing!');
      return;
    }

    //get all .txt when init
    playlistNotifer.value = await target
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.txt'))
        .map((entity) => entity.uri.pathSegments.last.replaceAll('.txt', ''))
        .toList();

    //update .txt
    target.watch().listen((event) async {
      if (event.path.endsWith('txt')) {
        playlistNotifer.value = await target
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.txt'))
            .map(
              (entity) => entity.uri.pathSegments.last.replaceAll('.txt', ''),
            )
            .toList();
      }
    });
  }
}

class PlaylistUltis {
  static Future<int> writeSongToPlaylist(
    BuildContext context,
    name,
    link,
  ) async {
    final playlist = context.read<PlaylistModels>().selectedPlaylist;
    final currentDir = Directory.current;
    final targetDir = Directory(p.join(currentDir.path, '..', 'playlist'));
    final playlistFile = File(p.join(targetDir.path, '$playlist.txt'));
    if (!await targetDir.exists()) {
      debugPrint('folder playlist missing');
      await targetDir.create(recursive: true);
    }
    if (!await playlistFile.exists()) {
      debugPrint('$playlistFile missing');
      return 0;
    }
    final songData = '$name: $link\n';
    try {
      await playlistFile.writeAsString(songData, mode: FileMode.append);
    } catch (e) {
      debugPrint('Error writing file');
      return 0;
    }
    return 1;
  }

  static Future<void> playlistSongWatcher(
    BuildContext context,
    String playlist,
  ) async {
    final currentDir = Directory.current;
    final targetDir = Directory(p.join(currentDir.path, '..', 'playlist'));
    final playlistFile = File(p.join(targetDir.path, '$playlist.txt'));

    if (!await playlistFile.exists()) {
      debugPrint('playlist does not exit');
      return;
    }

    targetDir.watch(events: FileSystemEvent.modify).listen((event) {
      debugPrint(event.path);
      debugPrint(playlistFile.path);
      if (event.path == playlistFile.path) {
        context.read<SongModels>().loadSong(playlist);
      }
    });
  }
}
