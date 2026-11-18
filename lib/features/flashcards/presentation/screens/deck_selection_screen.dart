import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/deck.dart';

/// Tela inicial do MemoCards onde o estudante escolhe o deck de estudo.
class DeckSelectionScreen extends ConsumerWidget {
  const DeckSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(decksStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.pastelBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pastelBackground,
        foregroundColor: AppColors.darkPurple,
        elevation: 0,
        title: const Text(
          AppStrings.deckSelectionTitle,
          style: TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.darkPurple,
          ),
        ),
      ),
      body: decksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppStrings.loadDecksError,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 16,
                    color: AppColors.darkPurple,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(decksStreamProvider),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
        data: (decks) {
          if (decks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  AppStrings.emptyDecksList,
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

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return _DeckCard(
                deck: deck,
                onTap: () => context.push(AppRoutes.study(deck.id)),
              );
            },
          );
        },
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback onTap;

  const _DeckCard({
    required this.deck,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final countLabel = AppStrings.cardCount(deck.cards.length);

    return Semantics(
      onTapHint: AppStrings.startDeckHint,
      child: Card(
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
              color: AppColors.pastelBackground,
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
              color: AppColors.neutralText,
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
                    color: AppColors.secondaryText,
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
                    color: AppColors.softPurpleBadge,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    countLabel,
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: const Icon(
            Icons.play_circle_fill,
            color: AppColors.playGreen,
            size: 36,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
