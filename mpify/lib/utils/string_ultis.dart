import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter/widgets.dart';

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
  static int getStringValue(String string) {
    final num = string.codeUnits.fold(0, (sum, code) => sum + code);
    debugPrint('$num');
    return num;
  }
  static int getDurationFromString(String durationString) {
    int duration = 0;
    final part = durationString.split(':');
    if (part.length == 2) {
      final minutes = int.tryParse(part[0]) ?? 0;
      final seconds = int.tryParse(part[1]) ?? 0;
      duration = minutes * 60 + seconds;
    }
    return duration;
  }
}
