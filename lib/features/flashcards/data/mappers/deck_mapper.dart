import '../../domain/entities/deck.dart';
import '../../domain/entities/deck_status.dart';
import '../../domain/entities/flashcard.dart';
import '../../../../core/database/app_database.dart';

/// Converte registros do Drift para entidades puras de domínio.
abstract final class DeckMapper {
  static Flashcard cardFromRow(CardRow row) {
    return Flashcard(
      id: row.id,
      deckId: row.deckId,
      question: row.question,
      answer: row.answer,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  static Deck deckFromRows(DeckRow row, List<CardRow> cardRows) {
    final sorted = List<CardRow>.of(cardRows)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Deck(
      id: row.id,
      title: row.title,
      description: row.description,
      status: DeckStatus.fromStorage(row.status),
      isSeed: row.isSeed,
      isCurated: row.isCurated,
      cards: sorted.map(cardFromRow).toList(),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}
