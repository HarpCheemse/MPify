import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';

import 'package:mpify/func.dart';
import 'package:provider/provider.dart';

import 'package:mpify/models/playlist_models.dart';
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
    FolderUtils.playlistWatcher();
    
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
        child: ValueListenableBuilder<List<String>>(
          valueListenable: playlistNotifer,
          builder: (context, playlist, _) {
            return ListView.builder(
            controller: _scrollController,
            itemCount: playlist.length,
            itemBuilder: (BuildContext content, int index) {
              final name = playlist[index];
              return PlaylistFolder(name: name);
            },
          );
          },
        ),
      ),
    );
  }
}

class PlaylistFolder extends StatelessWidget {
  final String name;
  const PlaylistFolder({
    super.key,
    required this.name
  });

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
        context.read<PlaylistModels>().setSelectedPlaylist(name);
        context.read<SongModels>().loadSong(name);
        PlaylistUltis.playlistSongWatcher(context, name );
      },
      child: Stack(
        children: [
          Positioned(
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image.asset('assets/folder.png', fit: BoxFit.contain),
            ),
          ),
          Positioned(
            left: 80,
            top: 20,
            child: Text(name, style: montserratStyle()),
          ),
        ],
      ),
    );
  }
}
