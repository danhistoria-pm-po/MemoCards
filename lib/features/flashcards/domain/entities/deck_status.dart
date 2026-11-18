/// Status editorial de um deck no MemoCards.
enum DeckStatus {
  draft,
  published;

  static DeckStatus fromStorage(String value) {
    return switch (value) {
      'draft' => DeckStatus.draft,
      'published' => DeckStatus.published,
      _ => DeckStatus.published,
    };
  }
}
