import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/flashcards/data/datasources/deck_local_datasource.dart';
import '../../features/flashcards/data/datasources/seed_asset_datasource.dart';
import '../../features/flashcards/data/repositories/deck_repository_impl.dart';
import '../../features/flashcards/domain/entities/deck.dart';
import '../../features/flashcards/domain/repositories/deck_repository.dart';
import '../../features/flashcards/domain/usecases/seed_initial_decks.dart';
import '../../features/flashcards/domain/usecases/watch_deck_by_id.dart';
import '../../features/flashcards/domain/usecases/watch_decks.dart';
import '../database/app_database.dart';
import '../utils/clock.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.defaults();
  ref.onDispose(db.close);
  return db;
});

final seedAssetDatasourceProvider = Provider<SeedAssetDatasource>(
  (ref) => SeedAssetDatasource(),
);

final deckLocalDatasourceProvider = Provider<DeckLocalDatasource>(
  (ref) => DeckLocalDatasource(ref.watch(appDatabaseProvider)),
);

final deckRepositoryProvider = Provider<DeckRepository>(
  (ref) => DeckRepositoryImpl(
    localDatasource: ref.watch(deckLocalDatasourceProvider),
    seedDatasource: ref.watch(seedAssetDatasourceProvider),
    clock: ref.watch(clockProvider),
  ),
);

final watchDecksUseCaseProvider = Provider<WatchDecks>(
  (ref) => WatchDecks(ref.watch(deckRepositoryProvider)),
);

final watchDeckByIdUseCaseProvider = Provider<WatchDeckById>(
  (ref) => WatchDeckById(ref.watch(deckRepositoryProvider)),
);

final seedInitialDecksUseCaseProvider = Provider<SeedInitialDecks>(
  (ref) => SeedInitialDecks(ref.watch(deckRepositoryProvider)),
);

final decksStreamProvider = StreamProvider<List<Deck>>(
  (ref) => ref.watch(watchDecksUseCaseProvider)(),
);

final deckByIdStreamProvider = StreamProvider.family<Deck?, String>(
  (ref, deckId) => ref.watch(watchDeckByIdUseCaseProvider)(deckId),
);
