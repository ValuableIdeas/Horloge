import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleur principale de l'app (rose)
  static const Color primaryColor = Color.fromARGB(255, 230, 58, 150);

  // Couleur secondaire pour les éléments actifs (bleu)
  static const Color secondaryColor = Color.fromARGB(255, 2, 110, 101);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      textTheme: GoogleFonts.alfaSlabOneTextTheme(),
      useMaterial3: true,
    );
  }
}
