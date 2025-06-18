import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mpify/models/song_models.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:mpify/models/playlist_models.dart';
import 'package:audioplayers/audioplayers.dart';

//Global Var
ValueNotifier<List<String>> playlistNotifer = ValueNotifier([]);

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

  static Future<void> downloadMP3(BuildContext context, name, link) async {
    final playlist = context.read<PlaylistModels>().selectedPlaylist;
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'mp3'));

    final trimmedLink = link.split('&')[0];
    final cleanName = name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (!await target.exists()) {
      debugPrint('Folder $target does not exit');
      target.create(recursive: true);
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

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      debugPrint('Error downloading mp3');
      return;
    }
    if (await PlaylistUltis.writeSongToPlaylist(
          playlist,
          cleanName,
          trimmedLink,
        ) ==
        0) {
      debugPrint('Error Writing File. Download canceled');
      return;
    }
  }

  static Future<void> playlistWatcher() async {
    final target = await checkPlaylistFolderExist();

    //get all .json when init
    playlistNotifer.value = await target
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .map((entity) => entity.uri.pathSegments.last.replaceAll('.json', ''))
        .toList();

    //update .json
    target.watch().listen((event) async {
      if (event.path.endsWith('json')) {
        playlistNotifer.value = await target
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.json'))
            .map(
              (entity) => entity.uri.pathSegments.last.replaceAll('.json', ''),
            )
            .toList();
      }
    });
  }

  static Future<Directory> checkPlaylistFolderExist() async {
    final currentDir = Directory.current;
    final targetDir = Directory(p.join(currentDir.path, '..', 'playlist'));
    if (!await targetDir.exists()) {
      debugPrint('folder playlist missing');
      await targetDir.create(recursive: true);
    }
    return targetDir;
  }

  static Future<Directory> checkMP3FolderExist() async {
    final playlistDir = await checkPlaylistFolderExist();
    final mp3Dir = Directory(p.join(playlistDir.path, '..', 'mp3'));
    if (!await mp3Dir.exists()) {
      debugPrint('folder mp3 missing');
      await mp3Dir.create(recursive: true);
    }
    return mp3Dir;
  }
}

class PlaylistUltis {
  static Future<int> writeSongToPlaylist(
    String playlist,
    String name,
    String link, {
    String artist = 'Unknown',
    String imagePath = '',
  }) async {
    final targetDir = await FolderUtils.checkPlaylistFolderExist();
    final playlistFile = File(p.join(targetDir.path, '$playlist.json'));

    if (!await playlistFile.exists()) {
      debugPrint('$playlistFile missing');
      return 0;
    }

    final duration = await AudioUtils.getSongDuration(name);
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

    final songModels = context.read<SongModels>();

    if (!await playlistFile.exists()) {
      debugPrint('playlist does not exit');
      return;
    }

    targetDir.watch(events: FileSystemEvent.modify).listen((event) {
      debugPrint(event.path);
      debugPrint(playlistFile.path);
      if (event.path == playlistFile.path) {
        songModels.loadSong(playlist);
      }
    });
  }
}

class AudioUtils {
  static final AudioPlayer player = AudioPlayer();

  static Future<Duration> getSongDuration(String name) async {
    final target = await FolderUtils.checkMP3FolderExist();
    final mp3FilePath = p.join(target.path, '$name.mp3');

    final mp3File = File(mp3FilePath);
    if (!await mp3File.exists()) {
      debugPrint('ERROR: MP3 file "$mp3FilePath" does NOT exist!');
      return Duration.zero;
    } else {
      debugPrint('SUCCESS: MP3 file "$mp3FilePath" EXISTS.');
    }

    try {
      final String ffprobeExecutable = 'C:\\Github\\MPify\\ffprobe.exe'; // <-- CHANGE THIS!
      final process = await Process.start(
        ffprobeExecutable,
        [
          '-i',
          mp3FilePath,
          '-v',
          'quiet',
          '-show_entries',
          'format=duration',
          '-hide_banner',
          '-of',
          'default=noprint_wrappers=1:nokey=1',
        ],
        runInShell: false,
      );

      final List<String> stdoutLines = [];
      final List<String> stderrLines = [];

      process.stdout
          .transform(systemEncoding.decoder)
          .listen((String data) {
            stdoutLines.add(data.trim());
            debugPrint('FFPROBE STDOUT CHUNK: "${data.trim()}"');
          });

      process.stderr
          .transform(systemEncoding.decoder)
          .listen((String data) {
            stderrLines.add(data.trim());
            debugPrint('FFPROBE STDERR CHUNK: "${data.trim()}"');
          });

      final exitCode = await process.exitCode;

      debugPrint('FFPROBE process finished with exit code: $exitCode');
      debugPrint('Collected STDOUT (full): "${stdoutLines.join('').trim()}"');
      debugPrint('Collected STDERR (full): "${stderrLines.join('\n').trim()}"');

      if (exitCode != 0) {
        debugPrint('ffprobe command failed with exit code: $exitCode');
        debugPrint('Full STDERR from ffprobe: ${stderrLines.join('\n')}');
        return Duration.zero;
      }

      final rawOutput = stdoutLines.join('').trim();
      final seconds = double.tryParse(rawOutput);

      if (seconds == null) {
        debugPrint('Could not parse duration from output: "$rawOutput"');
        return Duration.zero;
      }

      debugPrint('Successfully parsed duration: $seconds seconds');
      return Duration(microseconds: (seconds * 1000000).toInt());
    } catch (e) {
      debugPrint('ERROR: Exception during ffprobe execution: $e');
      if (e is ProcessException) {
         debugPrint('ProcessException message: ${e.message}');
         if (e.message.contains('No such file or directory') || e.errorCode == 2) { // Error code 2 typically means file not found
            debugPrint('This usually means the ffprobe.exe path is incorrect or ffprobe.exe does not exist at that location.');
         }
      }
      return Duration.zero;
    }
  }
  static Future<void> playSong(song) async {
    final target = await FolderUtils.checkMP3FolderExist();
    final songFile = File(p.join(target.path, '$song.mp3'));
    if (!await songFile.exists()) {
      debugPrint('$song not found');
      return;
    }
    player.stop();
    await player.play(DeviceFileSource(songFile.path));
  }

  static Future<void> pauseSong() async {
    await player.pause();
  }

  static Future<void> resumeSong() async {
    await player.resume();
  }

  static Future<void> skipForward() async {
    final posiotion = await player.getCurrentPosition();
    if (posiotion != null) {
      await player.seek(posiotion + const Duration(seconds: 5));
    }
  }

  static Future<void> skipBackward() async {
    final position = await player.getCurrentPosition();
    if (position != null) {
      final newPosition = position - const Duration(seconds: 5);
      await player.seek(
        newPosition > Duration.zero ? newPosition : Duration.zero,
      );
    }
  }

  static Future<void> setVolume(value) async {
    await player.setVolume(value);
  }
  static Future<void> stopSong() async {
    player.stop();
  }
}
