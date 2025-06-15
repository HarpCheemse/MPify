import 'package:flutter/material.dart';
import 'package:mpify/widgets/shared/text/positioned_header.dart';

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