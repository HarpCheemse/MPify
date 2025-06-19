import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:mpify/models/song_models.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/models/playlist_models.dart';

class Watcher {
  static Timer? _debounceTimer;
  static bool _isLoading = false;

  static Future<void> playlistSongWatcher(
    BuildContext context,
    String playlist,
  ) async {
    final songModels = context.read<SongModels>();
    _debounceTimer?.cancel();

    final currentDir = Directory.current;
    final targetDir = Directory(p.join(currentDir.path, '..', 'playlist'));
    final playlistFile = File(p.join(targetDir.path, '$playlist.json'));

    if (!await playlistFile.exists()) {
      debugPrint('playlist does not exist');
      return;
    }
    if (!context.mounted) return;

    targetDir.watch(events: FileSystemEvent.modify).listen((event) {
      if (event.path.endsWith('$playlist.json')) {
        _debounceTimer?.cancel();

        _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
          if(_isLoading) return;
          _isLoading = true;
          try {
            await songModels.loadSong(playlist);
          } catch (e) {
            debugPrint('Failed to load playlist: $e');
          }
          finally {
            _isLoading = false;
          }
        });
      }
    });
  }
  static Future<void> playlistWatcher(BuildContext context) async {
    final playlistModels = context.read<PlaylistModels>();
    final target = await FolderUtils.checkPlaylistFolderExist();
    List<String> listOfPlaylist = playlistModels.playlists;

    //get all .json when init
     listOfPlaylist = await target
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .map((entity) => entity.uri.pathSegments.last.replaceAll('.json', ''))
        .toList();
      playlistModels.updateListOfPlaylist(listOfPlaylist);

    //update .json
    target.watch().listen((event) async {
      if (event.path.endsWith('json')) {
        debugPrint('updated');
          listOfPlaylist = await target
            .list()
            .where((entity) => entity is File && entity.path.endsWith('.json'))
            .map(
              (entity) => entity.uri.pathSegments.last.replaceAll('.json', ''),
            )
            .toList();
            playlistModels.updateListOfPlaylist(listOfPlaylist);
      }
    });
  }
}