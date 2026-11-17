import 'flashcard_model.dart';

/// Modelo que representa um baralho (deck) temático de flashcards.
class DeckModel {
  /// Identificador único do deck.
  final String id;

  /// Título do deck exibido na listagem.
  final String title;

  /// Breve descrição do conteúdo abordado no deck.
  final String description;

  /// Lista de flashcards pertencentes a este deck.
  final List<FlashcardModel> cards;

  /// Cria uma instância imutável de [DeckModel].
  const DeckModel({
    required this.id,
    required this.title,
    required this.description,
    required this.cards,
  });
}
