import 'package:flutter/material.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/input_bar/input_bar.dart';
import 'package:mpify/widgets/shared/text/positioned_header.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';

import 'package:mpify/func.dart';

class CreateSongForm extends StatefulWidget {
  const CreateSongForm({super.key});

  @override
  State<CreateSongForm> createState() => _CreateSongFormState();
}

class _CreateSongFormState extends State<CreateSongForm> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final TextEditingController name = TextEditingController();
    final TextEditingController link = TextEditingController();
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: const Color.fromARGB(255, 43, 43, 43),
      child: Container(
        width: 600,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 43, 43, 43),
        ),
        child: Stack(
          children: [
            positionedHeader(30, 250, 'Create Song', 18, 600, Colors.white),
            Positioned(
              left: 45,
              top: 120,
              child: SizedBox(
                width: 500,
                height: 50,
                child: CustomInputBar(
                  onChanged: (query) {},
                  controller: name,
                  hintText: 'Song Name',
                  fontColor: const Color.fromARGB(255, 255, 255, 255),
                  hintColor: const Color.fromARGB(255, 140, 140, 140),
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: const Color.fromARGB(255, 140, 140, 140),
                  icon: Icons.add,
                ),
              ),
            ),
            Positioned(
              left: 45,
              top: 200,
              child: SizedBox(
                width: 500,
                height: 50,
                child: CustomInputBar(
                  onChanged: (query) {},
                  controller: link,
                  hintText: 'Song Link',
                  fontColor: const Color.fromARGB(255, 255, 255, 255),
                  hintColor: const Color.fromARGB(255, 140, 140, 140),
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: const Color.fromARGB(255, 140, 140, 140),
                  icon: Icons.add,
                ),
              ),
            ),
            Positioned(
              top: 340,
              left: 400,
              child: HoverButton(
                baseColor: Colors.transparent,
                borderRadius: 0,
                onPressed: () {
                  OverlayController.hideOverlay();
                },
                width: 80,
                hoverColor: Colors.transparent,
                height: 40,
                child: Transform.translate(
                  offset: Offset(10, 10),
                  child: Text('Cancel', style: montserratStyle()),
                ),
              ),
            ),
            Positioned(
              top: 340,
              left: 500,
              child: HoverButton(
                baseColor: Colors.transparent,
                hoverColor: Colors.transparent,
                borderRadius: 0,
                onPressed: () {
                  final songName = name.text;
                  final songLink = link.text;
                  FolderUtils.downloadMP3(context, songName, songLink);
                  OverlayController.hideOverlay();
                },
                width: 80,
                height: 40,
                child: Transform.translate(
                  offset: Offset(10, 10),
                  child: Text('Create', style: montserratStyle()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}