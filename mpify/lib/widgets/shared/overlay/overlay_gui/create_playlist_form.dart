import 'package:flutter/material.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/input_bar/input_bar.dart';
import 'package:mpify/widgets/shared/text/positioned_header.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';

import 'package:mpify/utils/folder_ultis.dart';


class CreatePlaylistForm extends StatefulWidget {
  const CreatePlaylistForm({super.key});

  @override
  State<CreatePlaylistForm> createState() => _CreatePlaylistFormState();
}

class _CreatePlaylistFormState extends State<CreatePlaylistForm> {
  final TextEditingController controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Container(
        width: 600,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: Stack(
          children: [
            positionedHeader(
              context,
              30,
              220,
              'New Playlist Folder',
              18,
              600,
              null
            ),
            Positioned(
              top: 120,
              left: 45,
              child: SizedBox(
                width: 500,
                height: 50,
                child: CustomInputBar(
                  onChanged: (query) {},
                  controller: controller,
                  hintText: 'Playlist Name',
                  fontColor: Theme.of(context).colorScheme.onSurface,
                  hintColor: Theme.of(context).colorScheme.onSurface,
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: Theme.of(context).colorScheme.onSurface,
                  icon: Icons.add,
                ),
              ),
            ),
            Positioned(
              top: 340,
              left: 400,
              child: HoverButton(
                baseColor: Colors.transparent,
                borderRadius: 10,
                onPressed: () {
                  OverlayController.hideOverlay();
                },
                width: 80,
                hoverColor: Colors.transparent,
                height: 40,
                child: Transform.translate(
                  offset: Offset(10, 10),
                  child: Text('Cancel', style: montserratStyle(context: context)),
                ),
              ),
            ),
            Positioned(
              top: 340,
              left: 500,
              child: HoverButton(
                baseColor: Colors.transparent,
                hoverColor: Colors.transparent,
                borderRadius: 10,
                onPressed: () {
                  final folderName = controller.text;
                  FolderUtils.createPlaylistFolder(folderName);
                  OverlayController.hideOverlay();
                },
                width: 80,
                height: 40,
                child: Transform.translate(
                  offset: Offset(10, 10),
                  child: Text('Create', style: montserratStyle(context: context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}