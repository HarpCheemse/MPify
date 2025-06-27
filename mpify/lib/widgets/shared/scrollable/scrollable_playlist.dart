import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/utils/playlist_ultis.dart';
import 'package:mpify/utils/watcher_ultis.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:provider/provider.dart';

import 'package:mpify/models/playlist_models.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/confirmation.dart';

class ScrollableListPlaylist extends StatefulWidget {
  final double width;
  final double height;
  final Color? color;
  const ScrollableListPlaylist({
    super.key,
    required this.width,
    required this.height,
    this.color = Colors.white,
  });

  @override
  State<ScrollableListPlaylist> createState() => _ScrollableListBoxState();
}

class _ScrollableListBoxState extends State<ScrollableListPlaylist> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    Watcher.playlistWatcher(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: widget.color,
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: Consumer<PlaylistModels>(
          builder: (context, playlist, child) {
            final length = playlist.playlists.length;
            return ListView.builder(
              controller: _scrollController,
              itemCount: length,
              itemBuilder: (BuildContext content, int index) {
                final playlistName = playlist.playlists[index];
                return PlaylistFolder(playlistName: playlistName);
              },
            );
          },
        ),
      ),
    );
  }
}

class PlaylistFolder extends StatelessWidget {
  final String playlistName;
  const PlaylistFolder({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    return HoverButton(
      baseColor: Colors.transparent,
      hoverColor: const Color.fromRGBO(113, 113, 113, 0.412),
      textStyle: montserratStyle(),
      borderRadius: 5,
      width: 320,
      height: 70,
      onPressed: () {
        context.read<PlaylistModels>().setSelectedPlaylist(playlistName);
        context.read<SongModels>().loadSong(playlistName);
        Watcher.playlistSongWatcher(context, playlistName);
      },
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Image.asset('assets/folder.png', fit: BoxFit.contain),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 200,
            child: Text(
              playlistName,
              style: montserratStyle(),
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {},
            icon: Icon(Icons.more_horiz, color: Colors.grey),
            color: const Color.fromARGB(255, 53, 53, 53),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                child: Row(
                  children: [
                    Icon(Icons.file_open_outlined, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Open File Location', style: montserratStyle()),
                  ],
                ),
                onTap: () {
                  FolderUtils.openFolderInExplorer();
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.backup_outlined, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Create A Back Up File', style: montserratStyle()),
                  ],
                ),
                onTap: () {
                  FolderUtils.createBackupFile(playlistName);
                },
              ),
              PopupMenuItem(
                onTap: () async {
                  await FolderUtils.importBackupFile(playlistName);
                },
                child: Row(
                  children: [
                    Icon(Icons.upload_file_outlined, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Import Backup File', style: montserratStyle()),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Delete Playlist', style: montserratStyle()),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    if (!context.mounted) return;
                    OverlayController.show(
                      context,
                      Confirmation(
                        headerText: 'Delete Playlist',
                        warningText:
                            'This action is pernament are you sure you want to delete this playlist?',
                        function: () =>
                            PlaylistUltis.deletePlaylist(playlistName),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
