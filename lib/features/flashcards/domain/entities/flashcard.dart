/// Entidade pura de domínio representando um flashcard.
class Flashcard {
  final String id;
  final String deckId;
  final String question;
  final String answer;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Flashcard({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Flashcard &&
            id == other.id &&
            deckId == other.deckId &&
            question == other.question &&
            answer == other.answer &&
            sortOrder == other.sortOrder &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt &&
            deletedAt == other.deletedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        deckId,
        question,
        answer,
        sortOrder,
        createdAt,
        updatedAt,
        deletedAt,
      );
}
