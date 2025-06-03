import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MPify());
}

TextStyle montserratStyle({
  Color color = Colors.white,
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w700,
}) {
  return GoogleFonts.montserrat(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
}

class SearchBar extends StatelessWidget {
  final Function(String)? onChanged;
  final String hintText;

  const SearchBar({Key? key, this.onChanged, this.hintText = 'Search...'})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: montserratStyle(),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      onChanged: onChanged,
    );
  }
}

Widget styledOutlinedButton({
  required String text,
  required VoidCallback onPressed,
  Color borderColor = Colors.white,
  double borderRadius = 10,
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
  ),
  TextStyle? textStyle,
}) {
  return OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: borderColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
    ),
    child: Text(text, style: textStyle ?? montserratStyle(fontSize: 12)),
  );
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
                      child: Text('Your Playlists', style: montserratStyle()),
                    ),
                    Positioned(
                      top: 15,
                      left: 250,
                      child: styledOutlinedButton(
                        text: '+ Create',
                        onPressed: () {
                          print('Create button pressed');
                        },
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: 20,
                      child: SizedBox(
                        width: 300,
                        child: SearchBar(
                          onChanged: (query){
                        
                          },
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
                width: 800,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: const Color.fromARGB(255, 24, 24, 24),
                ),
                child: Column(
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
                                Text(
                                  'Playlist',
                                  style: montserratStyle(fontSize: 10),
                                ),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
