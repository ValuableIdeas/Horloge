import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';

class AppTheme {
  static final Color customColor = RandomColor.getColor(
    Options(
      colorType: [ColorType.red, ColorType.blue],
      luminosity: Luminosity.dark,
      format: Format.rgba,
      alpha: 0.8,
    ),
  );
  static const Color primaryBlue = Color.fromARGB(255, 58, 153, 230);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 230, 58, 150),
      //primaryColor: customColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 0, 255, 255),
      ),
      textTheme: GoogleFonts.alfaSlabOneTextTheme(),
      useMaterial3: true,
    );
  }
}
