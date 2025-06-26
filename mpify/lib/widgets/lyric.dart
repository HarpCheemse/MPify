import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/utils/folder_ultis.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/overlay/overlay_controller.dart';
import 'package:mpify/widgets/shared/overlay/overlay_gui/edit_lyric_form.dart';
import 'package:provider/provider.dart';

class Lyric extends StatefulWidget {
  const Lyric({super.key});
  @override
  State<Lyric> createState() => _LyricState();
}

class _LyricState extends State<Lyric> {
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
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Container(
                width: 300,
                height: 520,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 44, 44, 44),
                ),
                child: Center(
                  child: Selector<SongModels, String>(
                    selector: (_, model) => model
                        .songsBackground[model.currentSongIndex]
                        .identifier,
                    builder: (context, identifier, child) {
                      return FutureBuilder<String?>(
                        future: FolderUtils.getSongLyric(identifier),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error Loading lyric');
                          } else {
                            final lyric =
                                snapshot.data ??
                                'This Song Does Not Has Lyric :<. Try Add Some!';
                            return ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black,
                                    Colors.black,
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.05, 0.95, 1],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstIn,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(15),
                                child: Text(lyric, style: montserratStyle()),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    OverlayController.show(context, EditLyricForm());
                  },
                  icon: Icon(Icons.edit),
                  iconSize: 20,
                ),
                SizedBox(width: 10,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
