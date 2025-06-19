import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

import 'package:audioplayers/audioplayers.dart';

import 'package:mpify/utils/folder_ultis.dart';

class AudioUtils {
  static final AudioPlayer player = AudioPlayer();

  static Future<Duration> getSongDuration(String identifier) async {
    final target = await FolderUtils.checkMP3FolderExist();
    final mp3FilePath = p.join(target.path, '$identifier.mp3');

    final mp3File = File(mp3FilePath);
    if (!await mp3File.exists()) {
      debugPrint('ERROR: MP3 file "$mp3FilePath" does NOT exist!');
      return Duration.zero;
    } else {
      debugPrint('SUCCESS: MP3 file "$mp3FilePath" EXISTS.');
    }

    try {
      final String ffprobeExecutable = 'C:\\Github\\MPify\\ffprobe.exe';
      final process = await Process.start(ffprobeExecutable, [
        '-i',
        mp3FilePath,
        '-v',
        'quiet',
        '-show_entries',
        'format=duration',
        '-hide_banner',
        '-of',
        'default=noprint_wrappers=1:nokey=1',
      ], runInShell: false);

      final List<String> stdoutLines = [];
      final List<String> stderrLines = [];

      process.stdout.transform(systemEncoding.decoder).listen((String data) {
        stdoutLines.add(data.trim());
        debugPrint('FFPROBE STDOUT CHUNK: "${data.trim()}"');
      });

      process.stderr.transform(systemEncoding.decoder).listen((String data) {
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
        if (e.message.contains('No such file or directory') ||
            e.errorCode == 2) {
          debugPrint(
            'This usually means the ffprobe.exe path is incorrect or ffprobe.exe does not exist at that location.',
          );
        }
      }
      return Duration.zero;
    }
  }

  static Future<void> playSong(identifier) async {
    final target = await FolderUtils.checkMP3FolderExist();
    final songFile = File(p.join(target.path, '$identifier.mp3'));
    if (!await songFile.exists()) {
      debugPrint('$identifier not found');
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
