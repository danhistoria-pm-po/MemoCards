import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Banco SQLite local (Drift) como fonte única da verdade (offline-first).
@DriftDatabase(
  tables: [
    DecksTable,
    CardsTable,
    ReviewStatesTable,
    ReviewLogsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Construtor padrão usado pelo aplicativo em produção (Android, Desktop e Web).
  AppDatabase.defaults() : super(_openConnection());

  /// Construtor para testes (ex.: `NativeDatabase.memory()`).
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'memocards_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
