import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MPify());
}

class HoverButton  extends StatefulWidget{
  final String text;
  final VoidCallback onPressed;
  final TextStyle? textStyle;
  final double width;
  final double height;
  final double borderRadius;

  const HoverButton({
    super.key,
    required this.text,
    required this.textStyle,
    required this.borderRadius,
    required this.onPressed,
    required this.width,
    required this.height,
  });
  
  @override
  State<HoverButton> createState() => _HoverButtonState();
}
class _HoverButtonState extends State<HoverButton>{
  bool _hovering = false;

  @override
  Widget build(BuildContext context){
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: _hovering ? Colors.grey : Colors.transparent,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          onTap: widget.onPressed,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(widget.borderRadius)
            ),
            child: Text(
              widget.text,
              style: widget.textStyle ?? montserratStyle(),
            ),
          ),
        ),
      ),
    );
  }
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

  const SearchBar({
    super.key,
    this.onChanged, this.hintText = 'Search...'
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: montserratStyle(color: Colors.black),
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
      debugShowCheckedModeBanner: false,
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
                        child: SearchBar(onChanged: (query) {}),
                      ),
                    ),
                    Positioned(
                      top: 120,
                      left: 20,
                      child: styledOutlinedButton(
                        text: 'New Playlist',
                        borderRadius: 0,
                        onPressed: () {
                          //TODO
                        },
                      ),
                    ),
                    Positioned(
                      top: 200,
                      left: 20,
                      child: HoverButton(text: 'Create Playlist',
                      textStyle: montserratStyle(),
                      borderRadius: 0,
                      width: 100,
                      height: 50,
                      onPressed: () {

                      }),
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
