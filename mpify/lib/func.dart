import 'dart:io';

class FolderUtils {
  static Future<void> createPlaylistFolder(String path) async {
    final dir = Directory(path);

    if (!(await dir.exists())) {
      await dir.create(recursive: true);
      print('Folder created at $path');
    } else {
      print('Folder already exists at $path');
    }
  }

  static Future<void> createForm() async {
    
  }
}
