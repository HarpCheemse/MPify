import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mpify/func.dart';

void main() {
  runApp(MPify());
}

Widget positionedHeader(
  double top,
  double left,
  String text,
  double fontSize,
  double fontWeight,
  Color color,
) {
  final fontWeightMap = {
    100: FontWeight.w100,
    200: FontWeight.w200,
    300: FontWeight.w300,
    400: FontWeight.w400,
    500: FontWeight.w500,
    600: FontWeight.w600,
    700: FontWeight.w700,
    800: FontWeight.w800,
    900: FontWeight.w900,
  };

  return Positioned(
    top: top,
    left: left,
    child: Text(
      text,
      style: montserratStyle(
        fontSize: fontSize,
        fontWeight: fontWeightMap[fontWeight] ?? FontWeight.normal,
        color: color,
      ),
    ),
  );
}

class HoverButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final TextStyle? textStyle;
  final double width;
  final double height;
  final double borderRadius;
  final Color? hoverColor;
  final Color? hoverFontColor;
  final Color baseColor;
  final Widget? child;

  final Color splashColor;
  final Color highlightColor;

  final Widget Function(bool hovering)? childBuilder;

  const HoverButton({
    super.key,

    this.child,
    this.text = '',
    this.textStyle,
    this.hoverFontColor = Colors.transparent,
    this.hoverColor = const Color.fromARGB(255, 173, 173, 173),
    required this.baseColor,
    required this.borderRadius,
    required this.onPressed,
    required this.width,
    required this.height,
    this.childBuilder,

    this.splashColor = Colors.transparent,
    this.highlightColor = Colors.transparent,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: _hovering ? widget.hoverColor : widget.baseColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: InkWell(
          splashColor: widget.splashColor,
          highlightColor: widget.highlightColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          onTap: widget.onPressed,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: widget.childBuilder != null
                ? widget.childBuilder!(_hovering)
                : widget.child ??
                      Text(
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
  final Color searchColor;
  final Color fontColor;
  final Color hintColor;
  final Color iconColor;

  const SearchBar({
    super.key,
    this.hintColor = Colors.white,
    this.onChanged,
    this.hintText = 'Search...',
    this.searchColor = Colors.white,
    this.fontColor = Colors.black,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: montserratStyle(color: fontColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor),
        prefixIcon: Icon(Icons.search, color: iconColor,),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: searchColor,
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

class playlist extends StatelessWidget {
  const playlist({super.key});

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
                child: SearchBar(
                  onChanged: (query) {},
                  hintText: 'Search Playlist',
                  fontColor: const Color.fromARGB(255, 140, 140, 140),
                  hintColor: const Color.fromARGB(255, 140, 140, 140),
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: const Color.fromARGB(255, 140, 140, 140),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 20,
              child: HoverButton(
                baseColor: Colors.transparent,
                hoverColor: const Color.fromARGB(105, 113, 113, 113),
                textStyle: montserratStyle(),
                borderRadius: 5,
                width: 320,
                height: 70,
                onPressed: () {
                  FolderUtils.createPlaylistFolder('../playlist/name');
                },
                child: Transform.translate(
                  offset: Offset(65, 25),
                  child: Text('New Playlist', style: montserratStyle()),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 20,
              child: Image.asset(
                'assets/empty_folder.png',
                fit: BoxFit.contain,
                width: 60,
                height: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class songs extends StatelessWidget {
  const songs({super.key});

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
                child: SearchBar(
                  onChanged: (query) {},
                  hintText: 'Search Name',
                  searchColor: Colors.transparent,
                  fontColor: Colors.white,
                  hintColor: const Color.fromARGB(255, 140, 140, 140),
                  iconColor: const Color.fromARGB(255, 140, 140, 140),
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
          ],
        ),
      ),
    );
  }
}

class player extends StatelessWidget {
  const player({super.key});

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
      ),
    );
  }
}

class songDetails extends StatelessWidget {
  const songDetails({super.key});

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
                baseColor: Colors.green,
                borderRadius: 50,
                onPressed: () {},
                width: 45,
                height: 45,
                hoverColor: const Color.fromARGB(255, 134, 212, 137),
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
            Row(children: [playlist(), songs(), player()]),
            songDetails(),
          ],
        ),
      ),
    );
  }
}
