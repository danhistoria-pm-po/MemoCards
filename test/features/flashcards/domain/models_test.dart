import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:memocards/features/flashcards/data/datasources/seed_asset_datasource.dart';
import 'package:memocards/features/flashcards/domain/entities/deck.dart';
import 'package:memocards/features/flashcards/domain/entities/deck_status.dart';
import 'package:memocards/features/flashcards/domain/entities/flashcard.dart';

void main() {
  final fixedDate = DateTime.utc(2026, 11, 17);

  group('Flashcard', () {
    test('armazena propriedades e implementa igualdade por valor', () {
      final a = Flashcard(
        id: 'c1',
        deckId: 'd1',
        question: 'P?',
        answer: 'R.',
        sortOrder: 0,
        createdAt: fixedDate,
        updatedAt: fixedDate,
      );
      final b = Flashcard(
        id: 'c1',
        deckId: 'd1',
        question: 'P?',
        answer: 'R.',
        sortOrder: 0,
        createdAt: fixedDate,
        updatedAt: fixedDate,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('Deck', () {
    test('armazena metadados e preserva a ordem dos cards', () {
      final deck = Deck(
        id: 'd1',
        title: 'Título',
        description: 'Descrição',
        status: DeckStatus.published,
        isSeed: true,
        isCurated: true,
        cards: [
          Flashcard(
            id: 'c1',
            deckId: 'd1',
            question: 'P1',
            answer: 'R1',
            sortOrder: 0,
            createdAt: fixedDate,
            updatedAt: fixedDate,
          ),
          Flashcard(
            id: 'c2',
            deckId: 'd1',
            question: 'P2',
            answer: 'R2',
            sortOrder: 1,
            createdAt: fixedDate,
            updatedAt: fixedDate,
          ),
        ],
        createdAt: fixedDate,
        updatedAt: fixedDate,
      );

      expect(deck.id, 'd1');
      expect(deck.status, DeckStatus.published);
      expect(deck.cards.map((c) => c.id), ['c1', 'c2']);
    });

    test('DeckStatus.fromStorage converte valores conhecidos e fallback', () {
      expect(DeckStatus.fromStorage('draft'), DeckStatus.draft);
      expect(DeckStatus.fromStorage('published'), DeckStatus.published);
      expect(DeckStatus.fromStorage('desconhecido'), DeckStatus.published);
    });
  });

  group('Seed JSON (assets/seed/decks.json)', () {
    test('possui decks e cards válidos com ids únicos e textos preenchidos',
        () async {
      final raw = await File('assets/seed/decks.json').readAsString();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final decks = (decoded['decks'] as List<dynamic>)
          .map((e) => SeedDeckDto.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(decks, isNotEmpty);

      final deckIds = decks.map((d) => d.id).toList();
      expect(deckIds.toSet().length, deckIds.length);

      final cardIds = [
        for (final deck in decks) ...deck.cards.map((c) => c.id),
      ];
      expect(cardIds.toSet().length, cardIds.length);

      for (final deck in decks) {
        expect(deck.title.trim(), isNotEmpty);
        expect(deck.description.trim(), isNotEmpty);
        expect(deck.cards, isNotEmpty, reason: deck.title);
        for (final card in deck.cards) {
          expect(card.question.trim(), isNotEmpty, reason: card.id);
          expect(card.answer.trim(), isNotEmpty, reason: card.id);
        }
      }
    });
  });
}
