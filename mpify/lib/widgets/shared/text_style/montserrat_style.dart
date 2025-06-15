import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

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