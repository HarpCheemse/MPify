import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/input_bar/input_bar.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:mpify/utils/folder_ultis.dart';

class EditSongForm extends StatefulWidget {
  final String playlist;
  final String identifier;
  final String name;
  final String artist;
  const EditSongForm({
    super.key,
    required this.playlist,
    required this.identifier,
    required this.name,
    required this.artist,
  });

  @override
  State<EditSongForm> createState() => _EditSongFormState();
}

class _EditSongFormState extends State<EditSongForm> {
  late TextEditingController name = TextEditingController();
  late TextEditingController artist = TextEditingController();
  bool _isReset = false;
  Uint8List? _imageBytes;
  final FocusNode _focusNode = FocusNode();

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
      });
    } else {
      debugPrint("No image selected");
    }
  }

  Future<void> _pasteImage() async {
    final pastedImage = await Pasteboard.image;
    if (pastedImage != null) {
      setState(() {
        _imageBytes = pastedImage;
      });
    } else {
      debugPrint("No image in clipboard");
    }
  }

  Future<void> clearCachedImage() async {
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'cover'));
    final imageFile = File(p.join(target.path, '${widget.identifier}.png'));

    if (!await target.exists()) {
      await target.create(recursive: true);
    }
    await FileImage(File(imageFile.path)).evict();
  }

  Future<void> _editSongInfo() async {
    final playlistDir = await FolderUtils.checkPlaylistFolderExist();
    final playlistFile = File(
      p.join(playlistDir.path, '${widget.playlist}.json'),
    );
    if (!await playlistFile.exists()) {
      debugPrint('${playlistFile.path} not found');
      OverlayController.hideOverlay();
      return;
    }
    final contents = await playlistFile.readAsString();
    List<dynamic> songs = jsonDecode(contents);
    await saveImageFile();

    try {
      final match = songs.firstWhere(
        (song) => song['identifier'] == widget.identifier,
        orElse: () => null,
      );
      if (match == null) {
        debugPrint('${widget.identifier} couldnt be found');
        OverlayController.hideOverlay();
        return;
      }
      match['name'] = name.text;
      match['artist'] = artist.text;

      final updatedContents = jsonEncode(songs);
      await playlistFile.writeAsString(updatedContents);
      debugPrint('Song Info Updated');
    } catch (e) {
      debugPrint('error editing file $e');
      return;
    }
  }

  Future<bool> saveImageFile() async {
    if (_imageBytes == null) return false;
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'cover'));
    final fileName = '${widget.identifier}.png';
    final imageFile = File(p.join(target.path, fileName));
    if (!await target.exists()) {
      await target.create(recursive: true);
    }
    await imageFile.writeAsBytes(_imageBytes!);
    debugPrint('Saved Imaged As $fileName');
    return true;
  }

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.name);
    artist = TextEditingController(text: widget.artist);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    name.dispose();
    artist.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coverPath = p.join(
      Directory.current.path,
      '..',
      'cover',
      '${widget.identifier}.png',
    );
    final imageExist = File(coverPath).existsSync();

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyV &&
            event.physicalKey == PhysicalKeyboardKey.keyV &&
            HardwareKeyboard.instance.logicalKeysPressed.contains(
              LogicalKeyboardKey.controlLeft,
            )) {
          _pasteImage();
        }
      },
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Container(
          width: 600,
          height: 600,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            children: [
              SizedBox(
                width: 100,
                height: 60,
                child: Center(
                  child: Text(
                    'Edit Info',
                    style: montserratStyle(context: context, fontSize: 20),
                  ),
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: 500,
                height: 80,
                child: CustomInputBar(
                  controller: name,
                  onChanged: (query) {},
                  hintText: 'Edit Name',
                  fontColor: Theme.of(context).colorScheme.onSurface,
                  hintColor: Theme.of(context).colorScheme.onSurface,
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: Theme.of(context).colorScheme.onSurface,
                  icon: Icons.edit,
                ),
              ),
              SizedBox(
                width: 500,
                height: 80,
                child: CustomInputBar(
                  controller: artist,
                  onChanged: (query) {},
                  hintText: 'Edit Artist',
                  fontColor: Theme.of(context).colorScheme.onSurface,
                  hintColor: Theme.of(context).colorScheme.onSurface,
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: Theme.of(context).colorScheme.onSurface,
                  icon: Icons.edit,
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 50),
                  SizedBox(
                    width: 210,
                    height: 210,
                    child: _isReset
                        ? (_imageBytes != null
                              // selected not null use that. if image exist. use that. else fallback to placeholder
                              ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/placeholder.png',
                                  fit: BoxFit.cover,
                                ))
                        : !imageExist
                        ? (_imageBytes != null
                              ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/placeholder.png',
                                  fit: BoxFit.cover,
                                ))
                        : Image.file(File(coverPath), fit: BoxFit.cover),
                  ),
                  SizedBox(width: 80),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 1),
                      ),
                      child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 50, height: 10),
              Row(
                children: [
                  SizedBox(width: 50),
                  HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    borderRadius: 0,
                    onPressed: () {
                      setState(() {
                        _imageBytes = null;
                        _isReset = true;
                      });
                    },
                    height: 30,
                    width: 210,
                    child: Center(
                      child: Text(
                        'Reset Image To Default',
                        style: montserratStyle(
                          context: context,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  SizedBox(width: 370),
                  HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    borderRadius: 0,
                    onPressed: () {
                      OverlayController.hideOverlay();
                    },
                    height: 30,
                    width: 80,
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: montserratStyle(
                          context: context,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  HoverButton(
                    baseColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    borderRadius: 0,
                    onPressed: () async {
                      await _editSongInfo();
                      if (context.mounted) {
                        await context.read<SongModels>().loadSong(
                          widget.playlist,
                        );
                      }
                      if (_imageBytes != null) clearCachedImage();
                      if (!mounted) return;
                      if (context.mounted) {
                        await context
                            .read<SongModels>()
                            .loadActivePlaylistSong();
                      }
                      OverlayController.hideOverlay();
                    },
                    height: 30,
                    width: 80,
                    child: Center(
                      child: Text(
                        'Edit',
                        style: montserratStyle(
                          context: context,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
