import 'dart:convert';
import 'package:crypto/crypto.dart';

class StringUltis {
  static String hashYoutubeLink(String link) {
    final bytes = utf8.encode(link);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
