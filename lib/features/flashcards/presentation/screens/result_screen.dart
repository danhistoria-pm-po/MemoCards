import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';

/// Tela exibida ao final da sessão de estudo com a pontuação obtida.
///
/// - "Revisar Novamente" volta para a sessão (que reinicia o deck).
/// - "Escolher outro Deck" volta direto para a seleção de decks.
class ResultScreen extends StatelessWidget {
  /// Quantidade de cards acertados de primeira.
  final int score;

  /// Quantidade total de cards da sessão.
  final int totalCards;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalCards,
  });

  static const Color _darkPurple = Color(0xFF4C1D95);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0FE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _AnimatedTrophy(),
                const SizedBox(height: 32),
                Text(
                  AppStrings.resultScore(score, totalCards),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _darkPurple,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text(AppStrings.reviewAgain),
                    style: _buttonStyle(
                      background: Colors.deepPurpleAccent,
                      foreground: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // Volta até a raiz da navegação (DeckSelectionScreen).
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.grid_view_rounded),
                    label: const Text(AppStrings.chooseAnotherDeck),
                    style: _buttonStyle(
                      background: Colors.white,
                      foreground: AppColors.darkPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle({
    required Color background,
    required Color foreground,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(
        fontFamily: AppFonts.poppins,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

/// Troféu com animação de entrada (escala elástica) e brilho em gradiente.
class _AnimatedTrophy extends StatelessWidget {
  const _AnimatedTrophy();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withValues(alpha: 0.35),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Icon(
          Icons.emoji_events_rounded,
          size: 96,
          color: Colors.amberAccent,
          semanticLabel: AppStrings.trophySemantics,
        ),
      ),
    );
  }
}
