import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

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

  static Future<void> downloadMP3(name, link) async {
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'mp3'));

    final trimmedLink = link.split('&')[0];
    final cleanName = name.replaceAll(RegExp(r'[^\w\-]'), '_');
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
      if(event.path.endsWith('txt')) {
        playlistNotifer.value = await target
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.txt'))
        .map((entity) => entity.uri.pathSegments.last.replaceAll('.txt', ''))
        .toList();
        playlistNotifer.value.forEach((name) =>
        debugPrint('$name'));
      }
    });
  }
}
