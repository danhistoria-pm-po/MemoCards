/// Textos de interface centralizados (pt-BR).
///
/// Ponto único para todas as strings visíveis ao aluno, preparado para uma
/// futura migração para `flutter_localizations` / arquivos `.arb`.
abstract final class AppStrings {
  // App
  static const String appTitle = 'MemoCards';

  // Seleção de decks
  static const String deckSelectionTitle = 'Escolha seu Deck';
  static const String startDeckHint = 'iniciar o estudo deste deck';
  static const String emptyDecksList = 'Nenhum deck disponível no momento.';
  static const String loadDecksError = 'Não foi possível carregar os decks.';
  static const String deckNotFound = 'Deck não encontrado.';
  static const String backToDecks = 'Voltar aos Decks';
  static String cardCount(int count) =>
      count == 1 ? '1 cartão' : '$count cartões';

  // Cartão (FlipCard)
  static const String questionLabel = 'PERGUNTA';
  static const String answerLabel = 'RESPOSTA';
  static const String tapToRevealAnswer = 'Toque para ver a resposta';
  static const String tapToShowQuestion = 'Toque para voltar à pergunta';
  static const String flipCardHint = 'virar o cartão';

  // Sessão de estudo
  static const String wrong = 'Errei';
  static const String correct = 'Acertei';
  static const String wrongHint =
      'marca como errado; o cartão volta para o fim da fila desta sessão';
  static const String correctHint =
      'marca como acertado e avança para o próximo cartão';
  static const String emptyDeck = 'Este deck ainda não possui flashcards.';
  static String progress(int current, int total) => '$current / $total';
  static String progressSemantics(int current, int total) =>
      'Cartão $current de $total';

  // Resultado
  static String resultScore(int score, int total) =>
      'Você acertou $score de $total!';
  static const String reviewAgain = 'Revisar Novamente';
  static const String chooseAnotherDeck = 'Escolher outro Deck';
  static const String trophySemantics = 'Troféu de sessão concluída';
}
