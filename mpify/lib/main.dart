import 'package:flutter/material.dart';
import 'package:mpify/widget.dart';

void main() {
  runApp(MPify());
}

class Playlist extends StatelessWidget {
  const Playlist({super.key});

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
              child: Text('Your Playlists', style: montserratStyle()),
            ),
            Positioned(
              top: 15,
              left: 250,
              child: styledOutlinedButton(
                text: '+ Import',
                onPressed: () {
                  //TODO
                },
              ),
            ),
            Positioned(
              top: 60,
              left: 20,
              child: SizedBox(
                width: 320,
                child: CustomInputBar(
                  controller: TextEditingController(),
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
          ],
        ),
      ),
    );
  }
}

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
                          'Playlist Name',
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
              650,
              'Duration',
              14,
              500,
              const Color.fromARGB(255, 157, 157, 157),
            ),
            Positioned(
              top: 120,
              left: 100,
              child: Icon(Icons.shuffle_rounded, color: Colors.white, size: 30,)
            ),
            Positioned(
              top: 120,
              left: 150,
              child: Icon(
                Icons.add_circle_sharp,
                size: 30,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Player extends StatelessWidget {
  const Player({super.key});

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
              top: 100,
              left: 80,
              child: Icon(
                Icons.album,
                size: 200,
                color: Colors.green,
                opticalSize: 100,
              ),
            ),
            positionedHeader(400, 50, 'Music Name', 24, 500, Colors.white),
            positionedHeader(440, 50, 'Artist Name', 10, 400, Colors.white),
          ],
        ),
      ),
    );
  }
}

class SongDetails extends StatelessWidget {
  const SongDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 10),
      child: Container(
        width: 1520,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.transparent,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Image.asset(
                  'assets/placeholder.png',
                  fit: BoxFit.cover,
                  height: 50,
                  width: 50,
                ),
              ),
            ),
            positionedHeader(20, 70, 'Name', 14, 600, Colors.white),
            positionedHeader(
              40,
              70,
              'Artist',
              14,
              500,
              const Color.fromARGB(255, 150, 150, 150),
            ),
            Positioned(
              top: 10,
              left: 730,
              child: HoverButton(
                baseColor: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: 50,
                onPressed: () {},
                width: 45,
                height: 45,
                hoverColor: const Color.fromARGB(255, 150, 150, 150),
                child: Transform.translate(
                  offset: Offset(15, 10),
                  child: Text(
                    '| |',
                    style: montserratStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 830,
              child: Icon(Icons.fast_forward, color: Colors.white),
            ),
            Positioned(
              top: 20,
              left: 650,
              child: Icon(Icons.fast_rewind, color: Colors.white),
            ),

            Positioned(
              top: 20,
              left: 550,
              child: Icon(Icons.skip_previous, color: Colors.white),
            ),
            Positioned(
              top: 20,
              left: 950,
              child: Icon(Icons.skip_next, color: Colors.white),
            ),
            positionedHeader(10, 840, '5', 8, 500, Colors.white),
            positionedHeader(10, 660, '5', 8, 500, Colors.white),
            Positioned(
              top: 50,
              left: 420,
              child: CustomSlider(
                width: 650,
                height: 2,
                value: 100,
                min: 0,
                max: 100,
                baseColor: const Color.fromARGB(255, 150, 150, 150),
                progressColor: Colors.white,
                hoverColor: Colors.green,
                thumbSize: 6,
                thumbColor: Colors.green,
                onChanged: (double value) {},
              ),
            ),
            Positioned(
              top: 40,
              left: 1370,
              child: Icon(
                Icons.volume_up_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            Positioned(
              top: 40,
              left: 1330,
              child: Icon(
                Icons.music_note_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            Positioned(
              top: 25,
              left: 1380,
              child: CustomSlider(
                width: 150,
                height: 2,
                value: 100,
                min: 0,
                max: 100,
                baseColor: const Color.fromARGB(255, 150, 150, 150),
                progressColor: Colors.white,
                hoverColor: Colors.green,
                thumbSize: 6,
                thumbColor: Colors.green,
                onChanged: (double value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MPify extends StatelessWidget {
  const MPify({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Row(children: [Playlist(), Songs(), Player()]),
            SongDetails(),
          ],
        ),
      ),
    );
  }
}
