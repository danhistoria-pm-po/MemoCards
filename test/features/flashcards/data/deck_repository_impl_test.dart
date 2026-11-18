import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memocards/core/database/app_database.dart';
import 'package:memocards/core/utils/clock.dart';
import 'package:memocards/features/flashcards/data/datasources/deck_local_datasource.dart';
import 'package:memocards/features/flashcards/data/datasources/seed_asset_datasource.dart';
import 'package:memocards/features/flashcards/data/mappers/deck_mapper.dart';
import 'package:memocards/features/flashcards/data/repositories/deck_repository_impl.dart';
import 'package:memocards/features/flashcards/domain/entities/deck_status.dart';
import 'package:mocktail/mocktail.dart';

class _MockSeedDatasource extends Mock implements SeedAssetDatasource {}

class _FixedClock implements Clock {
  final DateTime _now;
  const _FixedClock(this._now);

  @override
  DateTime now() => _now;
}

void main() {
  late AppDatabase db;
  late DeckLocalDatasource localDatasource;
  late _MockSeedDatasource seedDatasource;
  late DeckRepositoryImpl repository;
  final fixedNow = DateTime.utc(2026, 11, 17, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    localDatasource = DeckLocalDatasource(db);
    seedDatasource = _MockSeedDatasource();
    repository = DeckRepositoryImpl(
      localDatasource: localDatasource,
      seedDatasource: seedDatasource,
      clock: _FixedClock(fixedNow),
    );
  });

  tearDown(() async {
    await db.close();
  });

  const sampleSeed = [
    SeedDeckDto(
      id: '1',
      title: 'Era Vargas',
      description: 'Revisão ENEM',
      cards: [
        SeedCardDto(id: '101', question: 'P1', answer: 'R1'),
        SeedCardDto(id: '102', question: 'P2', answer: 'R2'),
      ],
    ),
  ];

  test('seedIfNeeded popula o banco e é idempotente na segunda chamada',
      () async {
    when(() => seedDatasource.loadDecks()).thenAnswer((_) async => sampleSeed);

    final first = await repository.seedIfNeeded();
    final second = await repository.seedIfNeeded();

    expect(first.isSuccess, isTrue);
    expect(second.isSuccess, isTrue);
    verify(() => seedDatasource.loadDecks()).called(1);

    final decks = await repository.watchDecks().first;
    expect(decks, hasLength(1));
    expect(decks.first.title, 'Era Vargas');
    expect(decks.first.isSeed, isTrue);
    expect(decks.first.isCurated, isTrue);
    expect(decks.first.status, DeckStatus.published);
    expect(decks.first.cards.map((c) => c.id), ['101', '102']);
  });

  test('seedIfNeeded retorna Err(SeedLoadFailure) quando o JSON falha',
      () async {
    when(() => seedDatasource.loadDecks()).thenThrow(Exception('arquivo ruim'));

    final result = await repository.seedIfNeeded();

    expect(result.isError, isTrue);
  });

  test('watchDeckById retorna deck existente e null quando inexistente',
      () async {
    when(() => seedDatasource.loadDecks()).thenAnswer((_) async => sampleSeed);
    await repository.seedIfNeeded();

    final found = await repository.watchDeckById('1').first;
    final missing = await repository.watchDeckById('999').first;

    expect(found, isNotNull);
    expect(found!.cards, hasLength(2));
    expect(missing, isNull);
  });

  test('DeckMapper ordena cards por sortOrder', () {
    final deckRow = DeckRow(
      id: '1',
      title: 'T',
      description: 'D',
      status: 'published',
      isSeed: true,
      isCurated: true,
      userId: null,
      createdAt: fixedNow,
      updatedAt: fixedNow,
      deletedAt: null,
    );
    final cardRows = [
      CardRow(
        id: 'b',
        deckId: '1',
        question: 'P2',
        answer: 'R2',
        sortOrder: 1,
        createdAt: fixedNow,
        updatedAt: fixedNow,
        deletedAt: null,
      ),
      CardRow(
        id: 'a',
        deckId: '1',
        question: 'P1',
        answer: 'R1',
        sortOrder: 0,
        createdAt: fixedNow,
        updatedAt: fixedNow,
        deletedAt: null,
      ),
    ];

    final deck = DeckMapper.deckFromRows(deckRow, cardRows);

    expect(deck.cards.map((c) => c.id), ['a', 'b']);
  });
}
