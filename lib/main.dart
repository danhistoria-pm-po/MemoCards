import 'package:flutter/material.dart';

import 'core/constants/app_fonts.dart';
import 'features/flashcards/presentation/screens/study_screen.dart';

void main() {
  runApp(const MemoCardsApp());
}

/// Widget raiz do aplicativo MemoCards.
class MemoCardsApp extends StatelessWidget {
  const MemoCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoCards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppFonts.poppins,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        scaffoldBackgroundColor: const Color(0xFFF4F0FE),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4C1D95),
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
      ),
      home: const StudyScreen(),
    );
  }
}
