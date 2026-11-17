import 'package:flutter/material.dart';

import '../../../../core/constants/app_fonts.dart';
import '../../domain/deck_model.dart';
import '../widgets/flip_card_widget.dart';
import 'result_screen.dart';

/// Tela de sessão de estudo: exibe um flashcard por vez e avança a fila
/// conforme a autoavaliação do estudante (Errei / Acertei).
class StudyScreen extends StatefulWidget {
  /// Baralho selecionado para esta sessão de revisão.
  final DeckModel deck;

  const StudyScreen({super.key, required this.deck});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _currentIndex = 0;
  int _score = 0;

  /// Evita abrir a tela de resultado duas vezes em toques rápidos.
  bool _isShowingResult = false;

  /// Registra a autoavaliação e avança a fila.
  /// No último card, abre a [ResultScreen] e reinicia o deck ao retornar.
  Future<void> _handleAnswer({required bool isCorrect}) async {
    final cards = widget.deck.cards;
    if (_isShowingResult || cards.isEmpty) return;

    if (isCorrect) _score++;

    if (_currentIndex < cards.length - 1) {
      setState(() => _currentIndex++);
      return;
    }

    _isShowingResult = true;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(score: _score, totalCards: cards.length),
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
    final cards = widget.deck.cards;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0FE),
      appBar: AppBar(
        title: Text(widget.deck.title),
        actions: [
          if (cards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: Text(
                  '${_currentIndex + 1} / ${cards.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: cards.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Este deck ainda não possui flashcards.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 16,
                    color: Color(0xFF4C1D95),
                  ),
                ),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: 350,
                  height: 400,
                  child: FlipCardWidget(flashcard: cards[_currentIndex]),
                ),
              ),
            ),
      bottomNavigationBar: cards.isEmpty
          ? null
          : SafeArea(
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
