import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/deck.dart';
import '../../domain/entities/flashcard.dart';
import '../widgets/flip_card_widget.dart';

/// Tela de sessão de estudo: exibe um flashcard por vez e avança a fila
/// conforme a autoavaliação do estudante (Errei / Acertei).
///
/// Cards marcados como "Errei" voltam para o fim da fila e reaparecem
/// até serem acertados. A pontuação considera apenas acertos de primeira.
class StudyScreen extends ConsumerStatefulWidget {
  /// Identificador do deck selecionado para esta sessão.
  final String deckId;

  const StudyScreen({super.key, required this.deckId});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  static const double _maxCardWidth = 480;
  static const double _cardAspectRatio = 1.25;

  List<Flashcard> _queue = [];
  final Set<String> _missedCardIds = {};
  int _reviewsDone = 0;
  int _score = 0;
  int _sessionNumber = 0;
  bool _isShowingResult = false;
  String? _initializedDeckId;

  void _initSessionIfNeeded(Deck deck) {
    if (_initializedDeckId == deck.id) return;
    _initializedDeckId = deck.id;
    _resetSession(deck);
  }

  void _resetSession(Deck deck) {
    _queue = List.of(deck.cards);
    _missedCardIds.clear();
    _reviewsDone = 0;
    _score = 0;
    _sessionNumber++;
  }

  Future<void> _handleAnswer(Deck deck, {required bool isCorrect}) async {
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
    await context.push<void>(
      AppRoutes.result(
        deck.id,
        score: _score,
        total: deck.cards.length,
      ),
    );
    if (!mounted) return;

    setState(() {
      _resetSession(deck);
      _isShowingResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deckAsync = ref.watch(deckByIdStreamProvider(widget.deckId));

    return deckAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.pastelBackground,
        appBar: AppBar(title: const Text(AppStrings.appTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: AppColors.pastelBackground,
        appBar: AppBar(title: const Text(AppStrings.appTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppStrings.loadDecksError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text(AppStrings.backToDecks),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (deck) {
        if (deck == null) {
          return Scaffold(
            backgroundColor: AppColors.pastelBackground,
            appBar: AppBar(title: const Text(AppStrings.appTitle)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      AppStrings.deckNotFound,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: const Text(AppStrings.backToDecks),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        _initSessionIfNeeded(deck);

        final hasCards = deck.cards.isNotEmpty;
        final current = _reviewsDone + 1;
        final total = _reviewsDone + _queue.length;

        return Scaffold(
          backgroundColor: AppColors.pastelBackground,
          appBar: AppBar(
            title: Text(deck.title),
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
          bottomNavigationBar: hasCards ? _buildAnswerButtons(deck) : null,
        );
      },
    );
  }

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
            color: AppColors.darkPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButtons(Deck deck) {
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
                  onPressed: () => _handleAnswer(deck, isCorrect: false),
                  icon: const Icon(Icons.close),
                  label: const Text(AppStrings.wrong),
                  style: _buttonStyle(AppColors.errorRed),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Semantics(
                hint: AppStrings.correctHint,
                child: ElevatedButton.icon(
                  onPressed: () => _handleAnswer(deck, isCorrect: true),
                  icon: const Icon(Icons.check),
                  label: const Text(AppStrings.correct),
                  style: _buttonStyle(AppColors.successGreen),
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
