# Walkthrough — Fase 1: Fundação (Riverpod, `go_router`, Drift e Seed JSON)

## 1. O que mudou

- **Infraestrutura `core/`:**
  - [app_colors.dart](file:///c:/Users/SAMSUNG/memocards/lib/core/constants/app_colors.dart) e [app_theme.dart](file:///c:/Users/SAMSUNG/memocards/lib/core/theme/app_theme.dart) extraídos do `main.dart`.
  - [failure.dart](file:///c:/Users/SAMSUNG/memocards/lib/core/errors/failure.dart) e [result.dart](file:///c:/Users/SAMSUNG/memocards/lib/core/errors/result.dart) para retorno funcional sem vazar exceções de persistência.
  - [clock.dart](file:///c:/Users/SAMSUNG/memocards/lib/core/utils/clock.dart) para timestamps determinísticos em UTC.
  - [providers.dart](file:///c:/Users/SAMSUNG/memocards/lib/core/di/providers.dart) e [bootstrap.dart](file:///c:/Users/SAMSUNG/memocards/lib/bootstrap.dart) com inicialização via `ProviderContainer` + seed local.
- **Persistência Drift (Android + Web) e Seed JSON:**
  - Tabelas [tables.dart](file:///c:/Users/SAMSUNG/memocards/lib/core/database/tables.dart) (`decks`, `cards`, `review_state`, `review_log`) e banco [app_database.dart](file:///c:/Users/SAMSUNG/memocards/lib/core/database/app_database.dart) (com `app_database.g.dart` gerado via `build_runner`).
  - Binários Web compatíveis (`web/sqlite3.wasm` para `sqlite3 3.5.2` e `web/drift_worker.js` para `drift 2.35.4`).
  - Curadoria migrada de `mock_decks.dart` para [decks.json](file:///c:/Users/SAMSUNG/memocards/assets/seed/decks.json); arquivos legados (`mock_decks.dart`, `deck_model.dart`, `flashcard_model.dart`) removidos.
- **Clean Architecture em `features/flashcards/`:**
  - `domain/`: entidades puras (`Deck`, `Flashcard`, `DeckStatus`), contrato `DeckRepository` e use cases (`WatchDecks`, `WatchDeckById`, `SeedInitialDecks`).
  - `data/`: [seed_asset_datasource.dart](file:///c:/Users/SAMSUNG/memocards/lib/features/flashcards/data/datasources/seed_asset_datasource.dart), [deck_local_datasource.dart](file:///c:/Users/SAMSUNG/memocards/lib/features/flashcards/data/datasources/deck_local_datasource.dart), [deck_mapper.dart](file:///c:/Users/SAMSUNG/memocards/lib/features/flashcards/data/mappers/deck_mapper.dart) e [deck_repository_impl.dart](file:///c:/Users/SAMSUNG/memocards/lib/features/flashcards/data/repositories/deck_repository_impl.dart).
- **Navegação (`go_router`) e Telas:**
  - [app_router.dart](file:///c:/Users/SAMSUNG/memocards/lib/core/router/app_router.dart) com rotas `/`, `/study/:deckId` e `/study/:deckId/result`.
  - [DeckSelectionScreen](file:///c:/Users/SAMSUNG/memocards/lib/features/flashcards/presentation/screens/deck_selection_screen.dart), [StudyScreen](file:///c:/Users/SAMSUNG/memocards/lib/features/flashcards/presentation/screens/study_screen.dart), [ResultScreen](file:///c:/Users/SAMSUNG/memocards/lib/features/flashcards/presentation/screens/result_screen.dart) e [main.dart](file:///c:/Users/SAMSUNG/memocards/lib/main.dart) migrados para Riverpod + `go_router`.

---

## 2. Diagnóstico do travamento nos testes e validação

- **Causa raiz do timeout anterior em `widget_test.dart`:** `NativeDatabase.memory()` (que usa FFI/stream assíncrono do SQLite) dentro do `FakeAsync` de `testWidgets`, combinado com `CircularProgressIndicator()` animado no estado `loading` e `UncontrolledProviderScope` sem `dispose`, fazia `pumpAndSettle()` aguardar indefinidamente.
- **Correção aplicada:**
  - Testes reais de Drift (`NativeDatabase.memory()`, `seedIfNeeded` idempotente, `watchDeckById` e `DeckMapper`) ficaram isolados em [deck_repository_impl_test.dart](file:///c:/Users/SAMSUNG/memocards/test/features/flashcards/data/deck_repository_impl_test.dart) com `await db.close()` no `tearDown`.
  - Widget tests em [widget_test.dart](file:///c:/Users/SAMSUNG/memocards/test/widget_test.dart) passaram a usar `ProviderScope` com `_FakeDeckRepository` em memória (`Stream.value`), mantendo toda a árvore real de UI, Riverpod e `go_router`.
- **Resultados executados sequencialmente (um arquivo por vez):**
  - `models_test.dart`: **4/4 passaram** (`< 1s`)
  - `deck_repository_impl_test.dart`: **4/4 passaram** (`1s`)
  - `widget_test.dart`: **10/10 passaram** (`8s`)
  - `flutter analyze`: **No issues found!**

---

## 3. Como testar e próximos passos

```bash
flutter analyze
flutter test test/features/flashcards/domain/models_test.dart --reporter expanded --timeout 60s
flutter test test/features/flashcards/data/deck_repository_impl_test.dart --reporter expanded --timeout 60s
flutter test test/widget_test.dart --reporter expanded --timeout 60s
```

- **Próxima fase:** **Fase 2 — SRS (SM-2)** (`ReviewScheduler`, `Sm2ReviewScheduler`, fila de "cards devidos hoje", contagem de pendentes nos decks, 4 níveis de avaliação e `ResultScreen` detalhada).
