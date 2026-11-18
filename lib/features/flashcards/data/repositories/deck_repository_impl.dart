import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/clock.dart';
import '../../domain/entities/deck.dart';
import '../../domain/repositories/deck_repository.dart';
import '../datasources/deck_local_datasource.dart';
import '../datasources/seed_asset_datasource.dart';

/// Implementação offline-first de [DeckRepository] apoiada no Drift local.
class DeckRepositoryImpl implements DeckRepository {
  final DeckLocalDatasource _localDatasource;
  final SeedAssetDatasource _seedDatasource;
  final Clock _clock;

  const DeckRepositoryImpl({
    required this._localDatasource,
    required this._seedDatasource,
    required this._clock,
  });

  @override
  Stream<List<Deck>> watchDecks() => _localDatasource.watchActiveDecks();

  @override
  Stream<Deck?> watchDeckById(String deckId) =>
      _localDatasource.watchDeckById(deckId);

  @override
  Future<Result<Deck?>> getDeckById(String deckId) async {
    try {
      final deck = await _localDatasource.getDeckById(deckId);
      return Success(deck);
    } catch (e) {
      return Err(StorageFailure('Falha ao buscar deck $deckId', cause: e));
    }
  }

  @override
  Future<Result<void>> seedIfNeeded() async {
    try {
      final alreadySeeded = await _localDatasource.hasSeedDecks();
      if (alreadySeeded) return const Success(null);

      final seedDecks = await _seedDatasource.loadDecks();
      await _localDatasource.insertSeedDecks(seedDecks, now: _clock.now());
      return const Success(null);
    } catch (e) {
      return Err(
        SeedLoadFailure('Falha ao carregar o seed inicial de decks', cause: e),
      );
    }
  }
}
