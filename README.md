# 🧠 MemoCards
**Flashcards by Prof. Danny**

## 🎯 Visão do Produto
O **MemoCards** é um aplicativo educacional (MVP) focado em combater a "curva de esquecimento" de vestibulandos do ENEM. Utilizando a mecânica científica de *Active Recall* (Evocação Ativa) e curadoria premium de conteúdo (25 anos de experiência docente), o app entrega microlearning gamificado e direto ao ponto.

## 🚀 Escopo do MVP (V1)
Foco exclusivo na funcionalidade central de revisão offline:

- **Seleção de Decks:** Listagem de temas focados em História e Geografia.
- **Sessão de Flashcards:** Interface limpa com cartões de pergunta (frente) e resposta (verso), em tamanho responsivo para celular, tablet e paisagem.
- **Motor 3D (FlipCard):** Animação fluida de rotação utilizando `AnimationController` e `Transform(Matrix4)`.
- **Autoavaliação:** Botões de feedback (Acertei/Errei). Cartões marcados como "Errei" voltam para o fim da fila até serem acertados.
- **Resultado:** Tela de pontuação final da sessão (acertos de primeira), com opção de revisar novamente ou voltar à seleção de decks.

## 🏗️ Arquitetura (Clean Architecture - Feature First)
O projeto foi estruturado para escalar futuramente com integrações de IA (Gemini API) e Backend as a Service (Firebase/Supabase).

```text
lib/
├── bootstrap.dart                             # Inicialização e carga do seed local
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                    # Paleta oficial do MemoCards
│   │   ├── app_fonts.dart                     # Fontes locais (Poppins offline)
│   │   └── app_strings.dart                   # Textos de UI centralizados (pré-l10n)
│   ├── database/
│   │   ├── app_database.dart                  # Banco SQLite local (Drift)
│   │   ├── app_database.g.dart                # Código gerado pelo drift_dev
│   │   └── tables.dart                        # Tabelas locais (decks, cards, SRS)
│   ├── di/
│   │   └── providers.dart                     # Injeção de dependências (Riverpod)
│   ├── errors/
│   │   ├── failure.dart                       # Hierarquia de falhas de domínio
│   │   └── result.dart                        # Tipo Result<T>
│   ├── router/
│   │   └── app_router.dart                    # Rotas declarativas (go_router)
│   ├── theme/
│   │   └── app_theme.dart                     # ThemeData global
│   └── utils/
│       └── clock.dart                         # Abstração de relógio para testes
├── features/
│   └── flashcards/
│       ├── domain/
│       │   ├── entities/                      # Deck, Flashcard, DeckStatus
│       │   ├── repositories/                  # DeckRepository (interface)
│       │   └── usecases/                      # WatchDecks, WatchDeckById, SeedInitialDecks
│       ├── data/
│       │   ├── datasources/                   # DeckLocalDatasource, SeedAssetDatasource
│       │   ├── mappers/                       # DeckMapper
│       │   └── repositories/                  # DeckRepositoryImpl
│       └── presentation/
│           ├── screens/
│           │   ├── deck_selection_screen.dart # Seleção de Decks
│           │   ├── study_screen.dart          # Sessão de estudo
│           │   └── result_screen.dart         # Pontuação final da sessão
│           └── widgets/
│               └── flip_card_widget.dart      # Cartão 3D interativo
└── main.dart                                  # Ponto de entrada limpo
```

## 🛠️ Stack Tecnológica

- **Framework:** Flutter `>=3.27` (testado com Flutter `3.47.7` / Dart `3.13.5`)
- **Gestão de Estado:** Riverpod (`flutter_riverpod`)
- **Roteamento:** `go_router`
- **Persistência Local:** Drift (SQLite offline-first com suporte Android e Web) + seed em `assets/seed/decks.json`
- **Animações:** Flutter Animations (Tween, Matrix4)
- **Design Pattern:** Feature-First Clean Architecture

## ▶️ Como Executar

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) `3.27` ou superior (Dart `^3.13.5`)
- Emulador Android/iOS, dispositivo físico ou navegador/desktop habilitado

### Passos
```bash
# 1. Instalar as dependências
flutter pub get

# 2. Executar o aplicativo
flutter run
```

### Testes e análise estática
```bash
flutter analyze
flutter test
```

## 🔮 Roadmap (Futuro - V2)

- [ ] Integração com **Gemini API** para geração dinâmica de Decks.
- [ ] Autenticação de usuários via **Firebase Auth** / **Supabase**.
- [ ] Implementação de Algoritmo Real de **Repetição Espaçada (SRS)**.
- [ ] Sincronização em nuvem e ecossistema integrado ao app **FocoUp**.

---
*Desenvolvido por Danny Cristian Gomes Bustamante (Product Manager, Product Owner & EdTech Specialist) - Prisma Digital*

