# Task List — MemoCards V2

> **Fluxo por fase:** Implementar -> `flutter analyze` limpo -> `flutter test` verde -> Commit (Conventional Commits) -> Walkthrough curto -> Avançar para próxima fase.

---

## Fase 0 — Hardening da V1
- [x] **0.1** Verificar `environment` em `pubspec.yaml` (`sdk: ^3.13.5` compatível com `Dart 3.13.5`, adicionar `flutter: '>=3.27.0'`), e atualizar `README.md` com versões reais de Flutter (`3.47.7`) e Dart (`3.13.5`), além de revisar formatação Markdown.
- [x] **0.2** Corrigir `ResultScreen`: diferenciar *"Revisar Novamente"* (`Navigator.pop` retornando à `StudyScreen`) de *"Escolher outro Deck"* (`Navigator.popUntil` até a `DeckSelectionScreen`).
- [x] **0.3** Corrigir fila da `StudyScreen`: cards marcados como *"Errei"* voltam para a fila da sessão atual até serem acertados; manter contabilização clara da pontuação da primeira passagem/rodada.
- [x] **0.4** Tornar o cartão na `StudyScreen` responsivo com `LayoutBuilder` / `ConstrainedBox` (removendo tamanho fixo `350x400`), preservando a animação 3D e prevenindo overflow em telas pequenas/grandes.
- [x] **0.5** Adicionar acessibilidade mínima (`Semantics` nos botões de avaliação, flip do card e cards da lista; verificar escala de fonte).
- [x] **0.6** Centralizar strings de UI da V1 em `lib/core/constants/app_strings.dart` (preparação para l10n).
- [x] **0.7** Criar testes unitários para `DeckModel` e `FlashcardModel`, além de ampliar `widget_test.dart` cobrindo: retorno de *"Escolher outro Deck"* até `DeckSelectionScreen`, reenfileiramento de *"Errei"* e responsividade em viewport pequeno.
- **Critério de aceite (Fase 0):**
  - `flutter analyze` sem erros ou warnings.
  - Todos os testes unitários e de widget passando.
  - Comportamento dos botões na `ResultScreen` e reenfileiramento de *"Errei"* validados em teste.
  - Commit realizado em padrão Conventional Commits + Walkthrough gerado.

---

## Fase 1 — Fundação (Riverpod, go_router, Drift e Seed JSON)
- [x] **1.1** Adicionar dependências justificadas no `pubspec.yaml`: `flutter_riverpod`, `go_router`, `drift`, `drift_flutter`, `path_provider` e dev dependencies `drift_dev`, `build_runner`, `mocktail`.
- [x] **1.2** Estruturar `lib/core/`: `theme/app_theme.dart`, `constants/{app_colors,app_fonts,app_strings}.dart`, `errors/{failure,result}.dart`, `utils/clock.dart`, `di/providers.dart` e `bootstrap.dart`.
- [x] **1.3** Migrar curadoria de `mock_decks.dart` para `assets/seed/decks.json` e registrar em `pubspec.yaml`.
- [x] **1.4** Implementar camadas `domain/` e `data/` de `features/flashcards/`: entidades puras (`Deck`, `Flashcard`, `DeckStatus`), interface `DeckRepository`, tabelas Drift (`decks`, `cards`, `review_state`, `review_log`), DAOs, mappers e loader idempotente do seed no primeiro boot.
- [x] **1.5** Configurar `go_router` (`lib/core/router/app_router.dart`) com rotas para `DeckSelectionScreen`, `StudyScreen` e `ResultScreen`.
- [x] **1.6** Migrar `DeckSelectionScreen`, `StudyScreen`, `ResultScreen` e `main.dart` para Riverpod + `go_router` e remover `lib/features/flashcards/data/mock_decks.dart`.
- [x] **1.7** Escrever testes unitários de mappers, carga idempotente do seed (banco Drift in-memory) e atualizar widget tests com `ProviderScope`.
- **Critério de aceite (Fase 1):**
  - `mock_decks.dart` removido e seed JSON carregado de forma idempotente no Drift.
  - UI consumindo dados exclusivamente via Riverpod + repositórios (zero `setState` de dados de negócio).
  - Navegação completa funcionando via `go_router`.
  - `flutter analyze` limpo e todos os testes unitários + widget verdes.
  - Commit realizado + Walkthrough gerado.

---

## Fase 2 — Repetição Espaçada (SRS SM-2)
- [ ] **2.1** Criar `features/study/domain/`: `ReviewRating` (`again`, `hard`, `good`, `easy`), `ReviewState`, `ReviewLog`, `StudySession`, interface `ReviewScheduler` e implementação `Sm2ReviewScheduler`.
- [ ] **2.2** Criar use cases em `features/study/domain/usecases/`: carregar fila de cards devidos hoje (`dueAt <= now`), registrar avaliação (`SubmitReview`) e finalizar sessão (`CompleteStudySession`).
- [ ] **2.3** Implementar `StudyRepositoryImpl` com persistência em Drift (`review_state` + `review_log`) em transação atômica.
- [ ] **2.4** Atualizar `DeckSelectionScreen` para exibir contagem de cards pendentes/devidos hoje por deck.
- [ ] **2.5** Atualizar `StudyScreen` para usar fila devida hoje, reenfileirar *"Errei"* (`again`) na sessão e substituir os 2 botões pelos 4 níveis (`Errei`, `Difícil`, `Bom`, `Fácil`) preservando simplicidade visual, contraste e `Semantics`.
- [ ] **2.6** Atualizar `ResultScreen` para exibir acertos por nível (`Errei`, `Difícil`, `Bom`, `Fácil`) e data do próximo vencimento mais próximo.
- [ ] **2.7** Criar testes unitários exaustivos do `Sm2ReviewScheduler` (intervalos iniciais, `easeFactor` mínimo, lapsos, progressão por nível), testes dos use cases e widget tests de estudo/resultado.
- **Critério de aceite (Fase 2):**
  - Algoritmo SM-2 encapsulado atrás de `ReviewScheduler` com 100% de cobertura dos casos de transição nos testes unitários.
  - Cards com erro retornam à fila e progresso persiste no SQLite entre reinícios do app.
  - `flutter analyze` limpo e todos os testes passando.
  - Commit realizado + Walkthrough gerado.

---

## Fase 3 — Autenticação (Supabase Auth)
- [ ] **3.1** Adicionar `supabase_flutter` ao `pubspec.yaml` e configurar leitura de `SUPABASE_URL` e `SUPABASE_ANON_KEY` via `--dart-define` / `--dart-define-from-file` (garantindo arquivos locais no `.gitignore`).
- [ ] **3.2** Criar estrutura `supabase/config.toml` base e documentar no `README.md` a configuração no painel: *"Anonymous sign-ins"*, *"Manual linking"*, CAPTCHA (Turnstile/hCaptcha) e redirect URLs de OAuth.
- [ ] **3.3** Criar `features/auth/domain/` (`AuthUser`, `AuthRepository`, use cases de sessão anônima e upgrade de conta).
- [ ] **3.4** Criar `features/auth/data/` (`SupabaseAuthDatasource` isolado com `supabase_flutter`, `AuthRepositoryImpl` e tratamento de exceções como identidade já vinculada).
- [ ] **3.5** Configurar inicialização não-bloqueante de sessão anônima (`signInAnonymously`) quando houver conectividade, mantendo estudo 100% funcional offline sem cadastro.
- [ ] **3.6** Criar UI discreta de Conta/Backup (`features/auth/presentation/`) permitindo vincular Google (`linkIdentity`) com deep link configurado ou e-mail/senha (`updateUser`) preservando o mesmo `user.id`.
- [ ] **3.7** Adicionar testes unitários dos use cases/repositório de Auth (mockando datasource com `mocktail`) e widget tests da tela de conta.
- **Critério de aceite (Fase 3):**
  - App funciona 100% offline mesmo sem sessão Supabase prévia.
  - Nenhuma chave real ou `service_role` no código/repositório.
  - Fluxo de login anônimo e upgrade preservando `user.id` implementado e testado com mocks.
  - `flutter analyze` limpo e testes verdes.
  - Commit realizado + Walkthrough gerado.

---

## Fase 4 — Sincronização em Nuvem (Postgres + RLS)
- [ ] **4.1** Criar migrations SQL em `supabase/migrations/` para tabelas espelhadas (`decks`, `cards`, `review_state`, `review_log`) com `user_id`, `updated_at`, `deleted_at` (soft delete), índices e triggers de `updated_at`.
- [ ] **4.2** Habilitar RLS em **todas** as tabelas e escrever policies por usuário (`user_id = auth.uid()`), incluindo checagem da claim `is_anonymous` onde aplicável.
- [ ] **4.3** Criar testes SQL em `supabase/tests/` (pgTAP) validando que Usuário A não lê nem altera dados do Usuário B e validando regras de conta anônima vs. permanente.
- [ ] **4.4** Adicionar tabela `sync_queue` e cursor de sync no Drift (`schemaVersion` + migration local).
- [ ] **4.5** Implementar `features/sync/domain/` e `features/sync/data/`: enfileiramento de mutações offline, push em lote, pull incremental por `updated_at`, resolução *last-write-wins* por `updated_at` UTC e suporte a soft delete (`deleted_at`).
- [ ] **4.6** Adicionar indicador discreto de status de sincronização na UI (`SyncStatusIndicator`: sincronizado / pendente / sincronizando / offline-erro).
- [ ] **4.7** Criar testes unitários do motor de sync (resolução de conflitos *last-write-wins*, fila offline, retry) e rodar `supabase test db` se Docker/CLI local disponível.
- **Critério de aceite (Fase 4):**
  - Todas as tabelas no Postgres com RLS ativo e testadas em pgTAP.
  - Mutações offline enfileiradas e sincronizadas automaticamente sem Realtime.
  - `flutter analyze` limpo e todos os testes Dart/Flutter (e SQL se ambiente disponível) verdes.
  - Commit realizado + Walkthrough gerado.

---

## Fase 5 — Geração de Decks com Gemini (Edge Function + Curadoria)
- [ ] **5.1** Criar migration SQL para a tabela `ai_usage` com RLS ativado (registro de uso diário por usuário).
- [ ] **5.2** Implementar Edge Function `supabase/functions/generate-deck/` (`index.ts`, `schema.ts`, `index.test.ts`):
  - `verify_jwt = true` no `config.toml` + validação de usuário.
  - Limite diário por usuário via `ai_usage`.
  - Chamada à Gemini API usando `GEMINI_API_KEY` e `GEMINI_MODEL` via secrets (sem hardcode de modelo ou chave).
  - System prompt em português estilo ENEM (História e Geografia) proibindo invenção de fatos/datas e instruindo omissão na dúvida.
  - Saída estruturada JSON + validação Zod no servidor rejeitando vazios/duplicados/inválidos e retornando erros claros.
- [ ] **5.3** Implementar `features/ai_generation/domain/` e `data/`: invocação via `supabase.functions.invoke('generate-deck')`, criação de deck local com `status: draft` e selo *"Gerado por IA - revisar"*.
- [ ] **5.4** Implementar telas em `features/ai_generation/presentation/`: formulário (tema, nível, quantidade) e tela de revisão onde o curador edita, aprova ou descarta cada card antes de promover para *"Curadoria Prof. Danny"*.
- [ ] **5.5** Atualizar `README.md` documentando `supabase secrets set GEMINI_API_KEY=...`, `GEMINI_MODEL` e `supabase functions deploy generate-deck` (sem executar deploy sem aprovação).
- [ ] **5.6** Escrever testes Deno para validação Zod/erros da Edge Function e testes unitários/widget da camada `ai_generation` no Flutter.
- **Critério de aceite (Fase 5):**
  - Nenhuma chave Gemini ou lógica direta de LLM no app Flutter.
  - Decks gerados iniciam sempre como `draft` / *"Gerado por IA - revisar"* e só mudam após aprovação manual.
  - Tratamento completo de timeout, erro de schema e limite diário atingido.
  - `flutter analyze` limpo, testes Flutter e Deno verdes.
  - Commit realizado + Walkthrough gerado.

---

## Fase 6 — Ponto de Extensão FocoUp (Somente Preparação)
- [ ] **6.1** Criar `lib/features/integrations/domain/study_session_summary.dart` (DTO puro de domínio: `deckId`, `totalCards`, acertos por nível, `duration`, `completedAt`) sem imports de Flutter, Supabase ou Drift.
- [ ] **6.2** Criar `lib/features/integrations/domain/focoup_port.dart` com interface abstrata `FocoUpPort` (`isAvailable` e `reportStudySessionCompleted(StudySessionSummary)`), sem tipos, endpoints ou campos específicos do FocoUp.
- [ ] **6.3** Criar `lib/features/integrations/data/focoup_port_stub.dart` com `FocoUpPortStub` (*no-op*, `isAvailable = false`, sem exceções).
- [ ] **6.4** Registrar `focoUpPortProvider` apontando para `FocoUpPortStub` de forma que trocá-lo no futuro exija alterar apenas esse provider.
- [ ] **6.5** Conectar o ponto único de chamada no use case de finalização de sessão dentro de `try/catch` não-bloqueante, sem afetar a UI.
- [ ] **6.6** Criar teste unitário garantindo que o stub não lança exceções e que o fluxo de estudo se comporta de forma idêntica com ele.
- [ ] **6.7** Criar `docs/focoup_integration.md` documentando propósito da porta, comportamento do stub, pendências (auth compartilhada, formato de eventos, transporte, privacidade/LGPD) e passos futuros de implementação.
- **Restrições verificadas:** zero dependências novas, zero chamadas de rede, zero deep links/SDKs/chaves/URLs/coleções do FocoUp e zero alteração de UI visível ao aluno.
- **Critério de aceite (Fase 6):**
  - `flutter analyze` limpo.
  - Todos os testes (incluindo teste unitário do stub e fluxo de estudo) verdes.
  - Nenhuma mudança de comportamento perceptível na UI; app compila sem o FocoUp existir.
  - Commit realizado + Walkthrough gerado.
