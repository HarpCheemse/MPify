import 'package:flutter/material.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/shared/input_bar/input_bar.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/create_playlist_form.dart';
import 'package:mpify/widgets/shared/scrollable/scrollable_playlist.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  TextEditingController controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 80),
      child: Container(
        height: 600,
        width: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: const Color.fromARGB(255, 24, 24, 24),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                'Your Playlists',
                style: montserratStyle(fontSize: 16),
              ),
            ),
            Positioned(
              top: 60,
              left: 20,
              child: SizedBox(
                width: 320,
                child: CustomInputBar(
                  controller: controller,
                  onChanged: (query) {},
                  hintText: 'Search Playlist',
                  fontColor: const Color.fromARGB(255, 140, 140, 140),
                  hintColor: const Color.fromARGB(255, 140, 140, 140),
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: const Color.fromARGB(255, 140, 140, 140),
                  icon: Icons.search,
                ),
              ),
            ),
            Positioned(
              top: 130,
              left: 20,
              child: HoverButton(
                baseColor: Colors.transparent,
                hoverColor: const Color.fromARGB(105, 113, 113, 113),
                textStyle: montserratStyle(),
                borderRadius: 5,
                width: 320,
                height: 70,
                onPressed: () {
                  OverlayController.show(context, CreatePlaylistForm());
                },
                child: Stack(
                  children: [
                    Transform.translate(
                      offset: Offset(65, 25),
                      child: Text('New Playlist', style: montserratStyle()),
                    ),
                    Image.asset(
                      'assets/empty_folder.png',
                      fit: BoxFit.contain,
                      width: 60,
                      height: 60,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 210,
              left: 20,
              child: ScrollableListPlaylist(
                width: 320,
                height: 380,
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
