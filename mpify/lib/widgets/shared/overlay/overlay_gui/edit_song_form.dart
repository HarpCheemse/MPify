import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/input_bar/input_bar.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/func.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class EditSongForm extends StatefulWidget {
  final playlist;
  final identifier;
  final name;
  final artist;
  final imagePath;
  const EditSongForm({
    super.key,
    required this.playlist,
    required this.identifier,
    required this.name,
    required this.artist,
    required this.imagePath,
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

    Future<void> pasteImage() async {
      final pastedImage = await Pasteboard.image;
      if (pastedImage != null) {
        setState(() {
          _imageBytes = pastedImage;
        });
      } else {
        debugPrint("No image in clipboard");
      }
    }

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
    final imagePath = await saveImageFile();

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
      if (_isReset) {
        if (imagePath == null) {
          match['imagePath'] = null;
        } else {
          match['imagePath'] = imagePath;
        }
      } else {
        if (imagePath != null) {
          match['imagePath'] = imagePath;
        } else {
          match['imagePath'] = widget.imagePath;
        }
      }
      ;

      final updatedContents = jsonEncode(songs);
      await playlistFile.writeAsString(updatedContents);
      debugPrint('Song Info Updated');
    } catch (e) {
      debugPrint('error editing file $e');
      return;
    }
  }

  Future<String?> saveImageFile() async {
    if (_imageBytes == null) return null;
    final current = Directory.current;
    final target = Directory(p.join(current.path, '..', 'cover'));
    final fileName = '${widget.identifier}.png';
    final imageFile = File(p.join(target.path, fileName));
    if (!await target.exists()) {
      await target.create(recursive: true);
    }
    await imageFile.writeAsBytes(_imageBytes!);
    return fileName;
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
        _focusNode.requestFocus(); // Persist focus
      }
    });

    @override
    void dispose() {
      _focusNode.dispose();
      name.dispose();
      artist.dispose();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        color: const Color.fromARGB(255, 43, 43, 43),
        child: Container(
          width: 600,
          height: 600,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 43, 43, 43),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 100,
                height: 60,
                child: Center(
                  child: Text(
                    'Edit Info',
                    style: montserratStyle(color: Colors.white, fontSize: 20),
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
                  fontColor: const Color.fromARGB(255, 255, 255, 255),
                  hintColor: const Color.fromARGB(255, 140, 140, 140),
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: const Color.fromARGB(255, 140, 140, 140),
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
                  fontColor: const Color.fromARGB(255, 255, 255, 255),
                  hintColor: const Color.fromARGB(255, 140, 140, 140),
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: const Color.fromARGB(255, 140, 140, 140),
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
                              // selected not null use that. if imagepath not null use that. else fallback to placeholder
                              ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/placeholder.png',
                                  fit: BoxFit.cover,
                                ))
                        : widget.imagePath == null
                        ? (_imageBytes != null
                              ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/placeholder.png',
                                  fit: BoxFit.cover,
                                ))
                        : Image.file(
                            File(
                              p.join(
                                Directory.current.path,
                                '..',
                                'cover',
                                widget.imagePath,
                              ),
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                  SizedBox(width: 80),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Icon(Icons.add, color: Colors.white),
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
                      await context.read<SongModels>().loadSong(
                        widget.playlist,
                      );
                      OverlayController.hideOverlay();
                    },
                    height: 30,
                    width: 80,
                    child: Center(
                      child: Text(
                        'Edit',
                        style: montserratStyle(
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
