import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/deck.dart';
import '../mappers/deck_mapper.dart';
import 'seed_asset_datasource.dart';

/// Datasource local baseado em Drift para decks e cards.
class DeckLocalDatasource {
  final AppDatabase _db;

  const DeckLocalDatasource(this._db);

  /// Observa todos os decks ativos (não deletados) com seus cards ativos.
  Stream<List<Deck>> watchActiveDecks() {
    final decksQuery = _db.select(_db.decksTable)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);

    return decksQuery.watch().asyncMap((deckRows) async {
      if (deckRows.isEmpty) return const <Deck>[];

      final cardRows = await (_db.select(_db.cardsTable)
            ..where((t) => t.deletedAt.isNull()))
          .get();

      final cardsByDeck = <String, List<CardRow>>{};
      for (final card in cardRows) {
        cardsByDeck.putIfAbsent(card.deckId, () => []).add(card);
      }

      return deckRows
          .map((d) => DeckMapper.deckFromRows(d, cardsByDeck[d.id] ?? const []))
          .toList();
    });
  }

  /// Observa um único deck ativo por ID com seus cards ordenados.
  Stream<Deck?> watchDeckById(String deckId) {
    final deckQuery = _db.select(_db.decksTable)
      ..where((t) => t.id.equals(deckId) & t.deletedAt.isNull());

    return deckQuery.watchSingleOrNull().asyncMap((deckRow) async {
      if (deckRow == null) return null;

      final cardRows = await (_db.select(_db.cardsTable)
            ..where((t) => t.deckId.equals(deckId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

      return DeckMapper.deckFromRows(deckRow, cardRows);
    });
  }

  /// Busca pontual de um deck ativo por ID.
  Future<Deck?> getDeckById(String deckId) async {
    final deckRow = await (_db.select(_db.decksTable)
          ..where((t) => t.id.equals(deckId) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (deckRow == null) return null;

    final cardRows = await (_db.select(_db.cardsTable)
          ..where((t) => t.deckId.equals(deckId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    return DeckMapper.deckFromRows(deckRow, cardRows);
  }

  /// Retorna `true` se já houver ao menos um deck seed cadastrado.
  Future<bool> hasSeedDecks() async {
    final existing = await (_db.select(_db.decksTable)
          ..where((t) => t.isSeed.equals(true))
          ..limit(1))
        .getSingleOrNull();
    return existing != null;
  }

  /// Insere os decks do seed de forma idempotente (não sobrescreve progresso
  /// nem duplica registros em execuções repetidas).
  Future<void> insertSeedDecks(
    List<SeedDeckDto> decks, {
    required DateTime now,
  }) async {
    await _db.transaction(() async {
      for (final deck in decks) {
        await _db.into(_db.decksTable).insert(
              DecksTableCompanion.insert(
                id: deck.id,
                title: deck.title,
                description: deck.description,
                status: const Value('published'),
                isSeed: const Value(true),
                isCurated: const Value(true),
                createdAt: now,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );

        for (var i = 0; i < deck.cards.length; i++) {
          final card = deck.cards[i];
          await _db.into(_db.cardsTable).insert(
                CardsTableCompanion.insert(
                  id: card.id,
                  deckId: deck.id,
                  question: card.question,
                  answer: card.answer,
                  sortOrder: Value(i),
                  createdAt: now,
                  updatedAt: now,
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
      }
    });
  }
}
