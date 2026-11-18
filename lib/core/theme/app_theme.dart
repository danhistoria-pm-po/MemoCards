import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

/// Tema global do MemoCards preservando a identidade visual da V1.
abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.poppins,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
      scaffoldBackgroundColor: AppColors.pastelBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkPurple,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.poppins,
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
