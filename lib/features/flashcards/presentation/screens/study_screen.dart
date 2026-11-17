import 'package:flutter/material.dart';

import '../../../../core/constants/app_fonts.dart';
import '../../data/mock_decks.dart';
import '../../domain/flashcard_model.dart';
import '../widgets/flip_card_widget.dart';
import 'result_screen.dart';

/// Tela de sessão de estudo: exibe um flashcard por vez e avança a fila
/// conforme a autoavaliação do estudante (Errei / Acertei).
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _currentIndex = 0;
  int _score = 0;

  /// Evita abrir a tela de resultado duas vezes em toques rápidos.
  bool _isShowingResult = false;

  /// Cards do deck "Era Vargas" (primeiro deck da curadoria).
  final List<FlashcardModel> _cards = mockDecks[0].cards;

  /// Registra a autoavaliação e avança a fila.
  /// No último card, abre a [ResultScreen] e reinicia o deck ao retornar.
  Future<void> _handleAnswer({required bool isCorrect}) async {
    if (_isShowingResult) return;

    if (isCorrect) _score++;

    if (_currentIndex < _cards.length - 1) {
      setState(() => _currentIndex++);
      return;
    }

    _isShowingResult = true;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(score: _score, totalCards: _cards.length),
      ),
    );
    if (!mounted) return;

    setState(() {
      _currentIndex = 0;
      _score = 0;
      _isShowingResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0FE),
      appBar: AppBar(
        title: const Text('MemoCards'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${_cards.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 350,
            height: 400,
            child: FlipCardWidget(flashcard: _cards[_currentIndex]),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleAnswer(isCorrect: false),
                  icon: const Icon(Icons.close),
                  label: const Text('Errei'),
                  style: _buttonStyle(const Color(0xFFDC2626)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleAnswer(isCorrect: true),
                  icon: const Icon(Icons.check),
                  label: const Text('Acertei'),
                  style: _buttonStyle(const Color(0xFF16A34A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(
        fontFamily: AppFonts.poppins,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
