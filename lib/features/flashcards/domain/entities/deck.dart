import 'deck_status.dart';
import 'flashcard.dart';

/// Entidade pura de domínio representando um baralho de estudo.
class Deck {
  final String id;
  final String title;
  final String description;
  final DeckStatus status;
  final bool isSeed;
  final bool isCurated;
  final List<Flashcard> cards;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Deck({
    required this.id,
    required this.title,
    required this.description,
    this.status = DeckStatus.published,
    this.isSeed = false,
    this.isCurated = false,
    required this.cards,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Deck ||
        id != other.id ||
        title != other.title ||
        description != other.description ||
        status != other.status ||
        isSeed != other.isSeed ||
        isCurated != other.isCurated ||
        createdAt != other.createdAt ||
        updatedAt != other.updatedAt ||
        deletedAt != other.deletedAt ||
        cards.length != other.cards.length) {
      return false;
    }
    for (var i = 0; i < cards.length; i++) {
      if (cards[i] != other.cards[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        status,
        isSeed,
        isCurated,
        Object.hashAll(cards),
        createdAt,
        updatedAt,
        deletedAt,
      );
}
