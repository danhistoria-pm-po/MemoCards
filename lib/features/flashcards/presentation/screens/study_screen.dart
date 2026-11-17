import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/deck_model.dart';
import '../../domain/flashcard_model.dart';
import '../widgets/flip_card_widget.dart';
import 'result_screen.dart';

/// Tela de sessão de estudo: exibe um flashcard por vez e avança a fila
/// conforme a autoavaliação do estudante (Errei / Acertei).
///
/// Cards marcados como "Errei" voltam para o fim da fila e reaparecem
/// até serem acertados. A pontuação considera apenas acertos de primeira.
class StudyScreen extends StatefulWidget {
  /// Baralho selecionado para esta sessão de revisão.
  final DeckModel deck;

  const StudyScreen({super.key, required this.deck});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  /// Largura máxima do cartão em telas largas (tablets/desktop).
  static const double _maxCardWidth = 480;

  /// Proporção altura/largura preferida do cartão.
  static const double _cardAspectRatio = 1.25;

  /// Fila de revisão da sessão atual (o primeiro item é o card exibido).
  late List<FlashcardModel> _queue;

  /// Cards errados ao menos uma vez nesta sessão.
  final Set<String> _missedCardIds = {};

  /// Quantidade de respostas dadas na sessão (inclui repetições).
  int _reviewsDone = 0;

  /// Acertos de primeira (cards nunca marcados como "Errei" na sessão).
  int _score = 0;

  /// Incrementado a cada nova sessão para recriar o cartão do zero.
  int _sessionNumber = 0;

  /// Evita abrir a tela de resultado duas vezes em toques rápidos.
  bool _isShowingResult = false;

  @override
  void initState() {
    super.initState();
    _resetSession();
  }

  void _resetSession() {
    _queue = List.of(widget.deck.cards);
    _missedCardIds.clear();
    _reviewsDone = 0;
    _score = 0;
    _sessionNumber++;
  }

  /// Registra a autoavaliação e avança a fila.
  ///
  /// "Errei" recoloca o card no fim da fila. Quando o último card pendente
  /// é acertado, abre a [ResultScreen] e reinicia a sessão ao retornar.
  Future<void> _handleAnswer({required bool isCorrect}) async {
    if (_isShowingResult || _queue.isEmpty) return;

    final card = _queue.first;
    if (isCorrect && !_missedCardIds.contains(card.id)) _score++;
    if (!isCorrect) _missedCardIds.add(card.id);

    final isSessionFinished = isCorrect && _queue.length == 1;
    if (!isSessionFinished) {
      setState(() {
        _queue.removeAt(0);
        _reviewsDone++;
        if (!isCorrect) _queue.add(card);
      });
      return;
    }

    _isShowingResult = true;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          score: _score,
          totalCards: widget.deck.cards.length,
        ),
      ),
    );
    if (!mounted) return;

    setState(() {
      _resetSession();
      _isShowingResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasCards = widget.deck.cards.isNotEmpty;
    final current = _reviewsDone + 1;
    final total = _reviewsDone + _queue.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F0FE),
      appBar: AppBar(
        title: Text(widget.deck.title),
        actions: [
          if (hasCards)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: Semantics(
                  label: AppStrings.progressSemantics(current, total),
                  excludeSemantics: true,
                  child: Text(
                    AppStrings.progress(current, total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: hasCards ? _buildCardArea() : _buildEmptyDeck(),
      bottomNavigationBar: hasCards ? _buildAnswerButtons() : null,
    );
  }

  /// Área do cartão responsiva: ocupa o espaço disponível respeitando
  /// largura máxima e proporção, sem estourar em telas pequenas ou paisagem.
  Widget _buildCardArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(constraints.maxWidth, _maxCardWidth);
          final height =
              math.min(constraints.maxHeight, width * _cardAspectRatio);

          return Center(
            child: SizedBox(
              width: width,
              height: height,
              child: FlipCardWidget(
                key: ValueKey('$_sessionNumber-$_reviewsDone'),
                flashcard: _queue.first,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyDeck() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          AppStrings.emptyDeck,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 16,
            color: Color(0xFF4C1D95),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Semantics(
                hint: AppStrings.wrongHint,
                child: ElevatedButton.icon(
                  onPressed: () => _handleAnswer(isCorrect: false),
                  icon: const Icon(Icons.close),
                  label: const Text(AppStrings.wrong),
                  style: _buttonStyle(const Color(0xFFDC2626)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Semantics(
                hint: AppStrings.correctHint,
                child: ElevatedButton.icon(
                  onPressed: () => _handleAnswer(isCorrect: true),
                  icon: const Icon(Icons.check),
                  label: const Text(AppStrings.correct),
                  // Verde 700: contraste 5:1 com texto branco (WCAG AA).
                  style: _buttonStyle(const Color(0xFF15803D)),
                ),
              ),
            ),
          ],
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
