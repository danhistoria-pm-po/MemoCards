/// Modelo que representa um cartão de estudo (flashcard) com pergunta e resposta.
class FlashcardModel {
  /// Identificador único do flashcard.
  final String id;

  /// Enunciado ou pergunta exibida na frente do cartão.
  final String question;

  /// Resposta ou explicação exibida no verso do cartão.
  final String answer;

  /// Cria uma instância imutável de [FlashcardModel].
  const FlashcardModel({
    required this.id,
    required this.question,
    required this.answer,
  });
}
