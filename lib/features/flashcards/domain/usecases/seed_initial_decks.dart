import '../../../../core/errors/result.dart';
import '../repositories/deck_repository.dart';

/// Caso de uso executado no boot para popular os decks iniciais no banco local.
class SeedInitialDecks {
  final DeckRepository _repository;

  const SeedInitialDecks(this._repository);

  Future<Result<void>> call() => _repository.seedIfNeeded();
}
