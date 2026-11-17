# 🧠 MemoCards
**Flashcards by Prof. Danny**

## 🎯 Visão do Produto
O **MemoCards** é um aplicativo educacional (MVP) focado em combater a "curva de esquecimento" de vestibulandos do ENEM. Utilizando a mecânica científica de *Active Recall* (Evocação Ativa) e curadoria premium de conteúdo (25 anos de experiência docente), o app entrega microlearning gamificado e direto ao ponto.

## 🚀 Escopo do MVP (V1)
Foco exclusivo na funcionalidade central de revisão offline:

- **Seleção de Decks:** Listagem de temas focados em História e Geografia.
- **Sessão de Flashcards:** Interface limpa com cartões de pergunta (frente) e resposta (verso).
- **Motor 3D (FlipCard):** Animação fluida de rotação utilizando `AnimationController` e `Transform(Matrix4)`.
- **Autoavaliação:** Botões de feedback (Acertei/Errei) para avanço de fila.
- **Resultado:** Tela de pontuação final da sessão.

## 🏗️ Arquitetura (Clean Architecture - Feature First)
O projeto foi estruturado para escalar futuramente com integrações de IA (Gemini API) e Backend as a Service (Firebase/Supabase).

> **Status atual:** Estrutura planejada para o MVP (no momento, apenas `lib/main.dart` está criado no repositório).

```text
lib/
├── core/
│   └── constants/        # Tema, cores e constantes de UI
├── features/
│   └── flashcards/
│       ├── domain/       # Modelos (DeckModel, FlashcardModel)
│       ├── data/         # Dados mockados (Curadoria Prof. Danny)
│       └── presentation/ # Telas e Widgets (StudyScreen, FlipCardWidget)
└── main.dart             # Ponto de entrada limpo
```

## 🛠️ Stack Tecnológica

- **Framework:** Flutter (Dart `^3.13.5`)
- **Gestão de Estado:** Nativa (`setState` para MVP)
- **Animações:** Flutter Animations (Tween, Matrix4)
- **Design Pattern:** Feature-First Clean Architecture

## ▶️ Como Executar

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (com Dart `^3.13.5`)
- Emulador Android/iOS, dispositivo físico ou navegador/desktop habilitado

### Passos
```bash
# 1. Instalar as dependências
flutter pub get

# 2. Executar o aplicativo
flutter run
```

### Testes
```bash
flutter test
```

## 🔮 Roadmap (Futuro - V2)

- [ ] Integração com **Gemini API** para geração dinâmica de Decks.
- [ ] Autenticação de usuários via **Firebase Auth** / **Supabase**.
- [ ] Implementação de Algoritmo Real de **Repetição Espaçada (SRS)**.
- [ ] Sincronização em nuvem e ecossistema integrado ao app **FocoUp**.

---
*Desenvolvido por Danny Cristian Gomes Bustamante (Product Manager, Product Owner & EdTech Specialist) - Prisma Digital*

