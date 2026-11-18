import '../entities/deck.dart';
import '../repositories/deck_repository.dart';

/// Caso de uso para observar a lista de decks disponíveis.
class WatchDecks {
  final DeckRepository _repository;

  const WatchDecks(this._repository);

  Stream<List<Deck>> call() => _repository.watchDecks();
}
