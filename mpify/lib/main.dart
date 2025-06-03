import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


void main(){
  runApp(MPify());
}
class MPify extends StatelessWidget {
  const MPify({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          children: [
            Padding(
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
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                    )
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 10, top: 80),
              child: Container(
                height: 600,
                width: 800,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: const Color.fromARGB(255, 24, 24, 24),
                ),
                child: Column(
                  children: [
                    Container(
                      child: Container( //header
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
                          )
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Image.asset(
                            'assets/folder.png',
                            fit: BoxFit.contain,
                            width: 60,
                          height: 60,
                          ),

                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 10, top: 80),
              child: Container(
                height: 600,
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: const Color.fromARGB(255, 24, 24, 24),
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}