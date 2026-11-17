import 'package:flutter_test/flutter_test.dart';

import 'package:memocards/features/flashcards/data/mock_decks.dart';
import 'package:memocards/features/flashcards/domain/deck_model.dart';
import 'package:memocards/features/flashcards/domain/flashcard_model.dart';

void main() {
  group('FlashcardModel', () {
    test('armazena id, pergunta e resposta', () {
      const card = FlashcardModel(id: 'c1', question: 'P?', answer: 'R.');

      expect(card.id, 'c1');
      expect(card.question, 'P?');
      expect(card.answer, 'R.');
    });

    test('instâncias const idênticas são canonicalizadas', () {
      const a = FlashcardModel(id: 'c1', question: 'P?', answer: 'R.');
      const b = FlashcardModel(id: 'c1', question: 'P?', answer: 'R.');

      expect(identical(a, b), isTrue);
    });
  });

  group('DeckModel', () {
    test('armazena metadados e preserva a ordem dos cards', () {
      const deck = DeckModel(
        id: 'd1',
        title: 'Título',
        description: 'Descrição',
        cards: [
          FlashcardModel(id: 'c1', question: 'P1', answer: 'R1'),
          FlashcardModel(id: 'c2', question: 'P2', answer: 'R2'),
        ],
      );

      expect(deck.id, 'd1');
      expect(deck.title, 'Título');
      expect(deck.description, 'Descrição');
      expect(deck.cards.map((c) => c.id), ['c1', 'c2']);
    });

    test('aceita deck sem cards', () {
      const deck = DeckModel(id: 'd0', title: 'T', description: 'D', cards: []);

      expect(deck.cards, isEmpty);
    });
  });

  group('mockDecks (curadoria Prof. Danny)', () {
    test('possui decks com ids únicos', () {
      final ids = mockDecks.map((d) => d.id).toList();

      expect(ids, isNotEmpty);
      expect(ids.toSet().length, ids.length);
    });

    test('ids de cards são únicos entre todos os decks', () {
      final ids = [
        for (final deck in mockDecks) ...deck.cards.map((c) => c.id),
      ];

      expect(ids.toSet().length, ids.length);
    });

    test('nenhum deck ou card possui texto vazio', () {
      for (final deck in mockDecks) {
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
