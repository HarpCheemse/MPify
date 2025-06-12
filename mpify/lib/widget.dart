import 'package:flutter/rendering.dart';
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

class CustomSearchBar extends StatelessWidget {
  final Function(String)? onChanged;
  final String hintText;
  final Color searchColor;
  final Color fontColor;
  final Color hintColor;
  final Color iconColor;

  const CustomSearchBar({
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
        prefixIcon: Icon(Icons.search, color: iconColor),
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
            activeTrackColor: _hovering ? widget.hoverColor : widget.progressColor,
            inactiveTrackColor: widget.baseColor,
            thumbColor: widget.thumbColor,
            thumbShape:  _hovering ? RoundSliderThumbShape(enabledThumbRadius: widget.thumbSize) : SliderComponentShape.noThumb,
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
