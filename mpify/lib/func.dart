import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mpify/widget.dart';
import 'package:path/path.dart' as p;

class FolderUtils {
  static Future<void> createPlaylistFolder(folderName) async {
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'playlist'));
    if(!await target.exists()){
      await target.create(recursive: true);
    }
    final filePath = p.join(target.path, '$folderName.txt');
    final file = File(filePath);
    await file.writeAsString('');
  }
  
}