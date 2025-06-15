import 'package:flutter/material.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/shared/input_bar/input_bar.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/text/positioned_header.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/create_song_form.dart';
import 'package:mpify/widgets/shared/scrollable/scrollable_song.dart';

import 'package:provider/provider.dart';
import 'package:mpify/models/playlist_models.dart';


class Songs extends StatelessWidget {
  const Songs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 80),
      child: Container(
        height: 600,
        width: 800,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: const Color.fromARGB(255, 24, 24, 24),
        ),
        child: Stack(
          children: [
            Container(
              //header
              height: 200,
              width: 800,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 4, 88, 156),
                    Color.fromARGB(255, 24, 24, 24),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/folder.png',
                      fit: BoxFit.contain,
                      width: 80,
                      height: 80,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Playlist', style: montserratStyle(fontSize: 10)),
                        SizedBox(height: 5, width: 10),
                        Text(
                          context.watch<PlaylistModels>().selectedPlaylist,
                          style: montserratStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 100,
              left: 10,
              child: HoverButton(
                baseColor: Colors.green,
                borderRadius: 50,
                onPressed: () {},
                width: 60,
                height: 60,
                hoverColor: const Color.fromARGB(255, 134, 212, 137),
                child: Transform.translate(
                  offset: Offset(20, 15),
                  child: Text(
                    '| |',
                    style: montserratStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 480,
              child: SizedBox(
                width: 200,
                height: 40,
                child: CustomInputBar(
                  controller: TextEditingController(),
                  onChanged: (query) {},
                  hintText: 'Search Name',
                  searchColor: Colors.transparent,
                  fontColor: Colors.white,
                  hintColor: const Color.fromARGB(255, 140, 140, 140),
                  iconColor: const Color.fromARGB(255, 140, 140, 140),
                  icon: Icons.search,
                ),
              ),
            ),
            Positioned(
              top: 125,
              left: 680,
              child: HoverButton(
                baseColor: Colors.transparent,
                hoverColor: Colors.transparent,
                hoverFontColor: const Color.fromARGB(255, 144, 4, 4),
                borderRadius: 0,
                onPressed: () {},
                width: 120,
                height: 30,
                childBuilder: (hovering) => Transform.translate(
                  offset: Offset(5, 5),
                  child: Text(
                    'Date Added ≡⋮',
                    style: montserratStyle(
                      fontSize: 13,
                      color: hovering
                          ? Colors.white
                          : const Color.fromARGB(255, 150, 150, 150),
                    ),
                  ),
                ),
              ),
            ),
            positionedHeader(
              180,
              30,
              '#',
              16,
              500,
              const Color.fromARGB(255, 157, 157, 157),
            ),
            positionedHeader(
              180,
              100,
              'Name',
              14,
              500,
              const Color.fromARGB(255, 157, 157, 157),
            ),
            positionedHeader(
              180,
              380,
              'Artist',
              14,
              500,
              const Color.fromARGB(255, 157, 157, 157),
            ),
            positionedHeader(
              180,
              680,
              'Duration',
              14,
              500,
              const Color.fromARGB(255, 157, 157, 157),
            ),
            Positioned(
              top: 120,
              left: 100,
              child: Icon(Icons.shuffle_rounded, color: Colors.white, size: 30),
            ),
            Positioned(
              top: 110,
              left: 150,
              child: IconButton(
                icon: Icon(
                  Icons.add_circle_sharp,
                  size: 30,
                  color: Colors.white,
                ),
                onPressed: () {
                  OverlayController.show(context, CreateSongForm());
                },
              ),
            ),
            Positioned(
              top: 210,
              left: 20,
              right: 20,
              child: Container(
                height: 1,
                color: Colors.grey,
              )
            ),
            Positioned(
              top: 220,
              left: 20,
              child: ScrollableListSong(
                width: 760,
                height: 370,
                color: Colors.transparent,
              ),
            )
          ],
        ),
      ),
    );
  }
}