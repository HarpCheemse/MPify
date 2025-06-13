import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:mpify/func.dart';

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

class CustomInputBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String hintText;
  final Color searchColor;
  final Color fontColor;
  final Color hintColor;
  final Color iconColor;
  final IconData icon;

  const CustomInputBar({
    super.key,
    required this.controller,
    required this.hintColor,
    required this.onChanged,
    required this.hintText,
    required this.searchColor,
    required this.fontColor,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: montserratStyle(color: fontColor),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor),
        prefixIcon: Icon(icon, color: iconColor),
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

class CustomSlider extends StatefulWidget {
  final double width;
  final double height;
  final double value;
  final double min;
  final double max;
  final Color baseColor;
  final Color progressColor;
  final Color hoverColor;
  final Color thumbColor;
  final double thumbSize;
  final ValueChanged<double> onChanged;

  const CustomSlider({
    super.key,
    required this.width,
    required this.height,
    required this.value,
    required this.min,
    required this.max,
    required this.baseColor,
    required this.progressColor,
    required this.hoverColor,
    required this.thumbColor,
    required this.thumbSize,
    required this.onChanged,
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late double _value;
  bool _hovering = false;
  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: SizedBox(
        width: widget.width,
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _hovering
                ? widget.hoverColor
                : widget.progressColor,
            inactiveTrackColor: widget.baseColor,
            thumbColor: widget.thumbColor,
            thumbShape: _hovering
                ? RoundSliderThumbShape(enabledThumbRadius: widget.thumbSize)
                : SliderComponentShape.noThumb,
            trackHeight: widget.height,
          ),
          child: Slider(
            value: _value,
            min: widget.min,
            max: widget.max,
            onChanged: (newValue) {
              setState(() {
                _value = newValue;
              });
              widget.onChanged(newValue);
            },
          ),
        ),
      ),
    );
  }
}

class OverlayController {
  static OverlayEntry? _entry;

  static void show(BuildContext context, Widget child) {
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: OverlayController.hideOverlay,
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
          Center(
            child: GestureDetector(onTap: () {}, child: child),
          ),
        ],
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  static void hideOverlay() {
    _entry?.remove();
    _entry = null;
  }
}
class CreatePlaylistForm extends StatefulWidget {
  const CreatePlaylistForm({super.key});

  @override
  State<CreatePlaylistForm> createState() => _CreatePlaylistFormState();
}

class _CreatePlaylistFormState extends State<CreatePlaylistForm> {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: const Color.fromARGB(255, 43, 43, 43),
      child: Container(
        width: 600,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 43, 43, 43),
        ),
        child: Stack(
          children: [
            positionedHeader(
              30,
              220,
              'New Playlist Folder',
              18,
              600,
              Colors.white,
            ),
            Positioned(
              top: 120,
              left: 45,
              child: SizedBox(
                width: 500,
                height: 50,
                child: CustomInputBar(
                  onChanged: (query) {},
                  controller: controller,
                  hintText: 'Playlist Name',
                  fontColor: const Color.fromARGB(255, 255, 255, 255),
                  hintColor: const Color.fromARGB(255, 140, 140, 140),
                  searchColor: const Color.fromARGB(134, 95, 95, 95),
                  iconColor: const Color.fromARGB(255, 140, 140, 140),
                  icon: Icons.add,
                ),
              ),
            ),
            Positioned(
              top: 340,
              left: 400,
              child: HoverButton(
                baseColor: Colors.transparent,
                borderRadius: 0,
                onPressed: () {OverlayController.hideOverlay();},
                width: 80,
                hoverColor: Colors.transparent,
                height: 40,
                child: Transform.translate(
                  offset: Offset(10, 10),
                  child: Text('Cancel', style: montserratStyle()),
                ),
              ),
            ),
            Positioned(
              top: 340,
              left: 500,
              child: HoverButton(
                baseColor: Colors.transparent,
                hoverColor: Colors.transparent,
                borderRadius: 0,
                onPressed: () {
                  final folderName = controller.text;
                  FolderUtils.createPlaylistFolder(folderName);
                  OverlayController.hideOverlay();
                  },
                width: 80,
                height: 40,
                child: Transform.translate(
                  offset: Offset(10, 10),
                  child: Text('Create', style: montserratStyle()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
