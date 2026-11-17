import 'package:flutter/material.dart';

import '../../../../core/constants/app_fonts.dart';
import '../../data/mock_decks.dart';
import '../../domain/deck_model.dart';
import 'study_screen.dart';

/// Tela inicial do MemoCards onde o estudante escolhe o deck de estudo.
class DeckSelectionScreen extends StatelessWidget {
  const DeckSelectionScreen({super.key});

  static const Color _darkPurple = Color(0xFF4C1D95);
  static const Color _pastelBackground = Color(0xFFF4F0FE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pastelBackground,
      appBar: AppBar(
        backgroundColor: _pastelBackground,
        foregroundColor: _darkPurple,
        elevation: 0,
        title: const Text(
          'Escolha seu Deck',
          style: TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _darkPurple,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: mockDecks.length,
        itemBuilder: (context, index) {
          final deck = mockDecks[index];
          return _DeckCard(
            deck: deck,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => StudyScreen(deck: deck),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final DeckModel deck;
  final VoidCallback onTap;

  const _DeckCard({
    required this.deck,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardCount = deck.cards.length;
    final countLabel = cardCount == 1 ? '1 cartão' : '$cardCount cartões';

    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.deepPurple.withValues(alpha: 0.14),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F0FE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Colors.deepPurpleAccent,
            size: 28,
          ),
        ),
        title: Text(
          deck.title,
          style: const TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deck.description,
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  countLabel,
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4C1D95),
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.play_circle_fill,
          color: Color(0xFF16A34A),
          size: 36,
        ),
        onTap: onTap,
      ),
    );
  }
}
