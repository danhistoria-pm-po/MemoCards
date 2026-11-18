import '../../../../core/errors/result.dart';
import '../entities/deck.dart';

/// Contrato de acesso aos decks e cards (offline-first via repositório).
abstract interface class DeckRepository {
  /// Observa os decks ativos ordenados para exibição na tela inicial.
  Stream<List<Deck>> watchDecks();

  /// Observa um deck específico por ID (ou `null` se não existir/deletado).
  Stream<Deck?> watchDeckById(String deckId);

  /// Busca um deck pontual por ID.
  Future<Result<Deck?>> getDeckById(String deckId);

  /// Carrega os decks iniciais do seed JSON caso ainda não existam localmente.
  Future<Result<void>> seedIfNeeded();
}
