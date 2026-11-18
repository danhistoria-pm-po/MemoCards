import '../entities/deck.dart';
import '../repositories/deck_repository.dart';

/// Caso de uso para observar um deck específico por ID.
class WatchDeckById {
  final DeckRepository _repository;

  const WatchDeckById(this._repository);

  Stream<Deck?> call(String deckId) => _repository.watchDeckById(deckId);
}
