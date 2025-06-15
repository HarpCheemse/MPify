import 'package:flutter/material.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:mpify/widgets/shared/text/positioned_header.dart';
import 'package:mpify/widgets/shared/button/hover_button.dart';
import 'package:mpify/widgets/slider.dart/slider.dart';



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