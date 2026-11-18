import 'package:drift/drift.dart';

/// Tabela local de baralhos (decks).
@DataClassName('DeckRow')
class DecksTable extends Table {
  @override
  String get tableName => 'decks';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get status => text().withDefault(const Constant('published'))();
  BoolColumn get isSeed => boolean().withDefault(const Constant(false))();
  BoolColumn get isCurated => boolean().withDefault(const Constant(false))();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela local de flashcards vinculados a um deck.
@DataClassName('CardRow')
class CardsTable extends Table {
  @override
  String get tableName => 'cards';

  TextColumn get id => text()();
  TextColumn get deckId =>
      text().references(DecksTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get question => text()();
  TextColumn get answer => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Estado atual de repetição espaçada (SRS) por card.
@DataClassName('ReviewStateRow')
class ReviewStatesTable extends Table {
  @override
  String get tableName => 'review_state';

  TextColumn get cardId =>
      text().references(CardsTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {cardId};
}

/// Histórico imutável de revisões realizadas por card.
@DataClassName('ReviewLogRow')
class ReviewLogsTable extends Table {
  @override
  String get tableName => 'review_log';

  TextColumn get id => text()();
  TextColumn get cardId =>
      text().references(CardsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get rating => text()();
  DateTimeColumn get reviewedAt => dateTime()();
  IntColumn get intervalDaysAfter => integer()();
  RealColumn get easeFactorAfter => real()();

  @override
  Set<Column> get primaryKey => {id};
}
