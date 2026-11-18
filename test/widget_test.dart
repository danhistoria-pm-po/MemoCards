import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memocards/core/di/providers.dart';
import 'package:memocards/core/errors/result.dart';
import 'package:memocards/features/flashcards/domain/entities/deck.dart';
import 'package:memocards/features/flashcards/domain/entities/deck_status.dart';
import 'package:memocards/features/flashcards/domain/entities/flashcard.dart';
import 'package:memocards/features/flashcards/domain/repositories/deck_repository.dart';
import 'package:memocards/features/flashcards/presentation/widgets/flip_card_widget.dart';
import 'package:memocards/main.dart';

class _FakeDeckRepository implements DeckRepository {
  static final _now = DateTime.utc(2026, 11, 17);

  static final List<Deck> _decks = [
    Deck(
      id: '1',
      title: 'Era Vargas',
      description: 'Revisão essencial sobre o período varguista para o ENEM.',
      status: DeckStatus.published,
      isSeed: true,
      isCurated: true,
      createdAt: _now,
      updatedAt: _now,
      cards: [
        Flashcard(
          id: '101',
          deckId: '1',
          question: 'O que foi a Revolução de 1930?',
          answer:
              'Movimento que depôs Washington Luís e colocou Getúlio Vargas no poder, pondo fim à República Oligárquica.',
          sortOrder: 0,
          createdAt: _now,
          updatedAt: _now,
        ),
        Flashcard(
          id: '102',
          deckId: '1',
          question: 'Qual a principal característica do Estado Novo (1937-1945)?',
          answer:
              'Ditadura de Vargas marcada por centralização, censura (DIP) e criação de direitos trabalhistas (CLT).',
          sortOrder: 1,
          createdAt: _now,
          updatedAt: _now,
        ),
        Flashcard(
          id: '103',
          deckId: '1',
          question: 'O que foi o movimento Queremismo?',
          answer:
              'Movimento popular no fim do Estado Novo que defendia a permanência de Vargas no poder e uma nova constituinte.',
          sortOrder: 2,
          createdAt: _now,
          updatedAt: _now,
        ),
      ],
    ),
    Deck(
      id: '2',
      title: 'Geopolítica Contemporânea',
      description: 'Conceitos fundamentais de Geografia para vestibulares.',
      status: DeckStatus.published,
      isSeed: true,
      isCurated: true,
      createdAt: _now,
      updatedAt: _now,
      cards: [
        Flashcard(
          id: '201',
          deckId: '2',
          question: 'O que caracteriza a Nova Ordem Mundial?',
          answer:
              'Configuração pós-Guerra Fria, marcada pela multipolaridade econômica e unipolaridade militar (hegemonia dos EUA).',
          sortOrder: 0,
          createdAt: _now,
          updatedAt: _now,
        ),
        Flashcard(
          id: '202',
          deckId: '2',
          question: 'O que é Gentrificação?',
          answer:
              'Revitalização de espaços urbanos que encarece o custo de vida e expulsa a população de baixa renda para as periferias.',
          sortOrder: 1,
          createdAt: _now,
          updatedAt: _now,
        ),
        Flashcard(
          id: '203',
          deckId: '2',
          question: 'Qual a diferença entre Estado e Nação?',
          answer:
              'Estado é a instituição política e jurídica (governo, território). Nação é o sentimento de pertencimento, cultura e identidade de um povo.',
          sortOrder: 2,
          createdAt: _now,
          updatedAt: _now,
        ),
      ],
    ),
  ];

  @override
  Future<Result<Deck?>> getDeckById(String deckId) async {
    for (final deck in _decks) {
      if (deck.id == deckId) return Success(deck);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> seedIfNeeded() async => const Success(null);

  @override
  Stream<Deck?> watchDeckById(String deckId) {
    for (final deck in _decks) {
      if (deck.id == deckId) return Stream.value(deck);
    }
    return Stream.value(null);
  }

  @override
  Stream<List<Deck>> watchDecks() => Stream.value(_decks);
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        deckRepositoryProvider.overrideWithValue(_FakeDeckRepository()),
      ],
      child: const MemoCardsApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openDeck(WidgetTester tester, String title) async {
  await _pumpApp(tester);
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

Future<void> _answer(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void _setLogicalScreenSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 2.0;
  tester.view.physicalSize = size * 2.0;
  addTearDown(tester.view.reset);
}

void main() {
  test('Fontes Poppins estão embarcadas nos assets (modo offline)', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const weights = ['Regular', 'Medium', 'SemiBold', 'Bold'];
    for (final weight in weights) {
      final data = await rootBundle.load('assets/fonts/Poppins-$weight.ttf');
      expect(data.lengthInBytes, greaterThan(0), reason: 'Poppins-$weight');
    }
  });

  group('DeckSelectionScreen', () {
    testWidgets('lista os decks disponíveis via Riverpod', (tester) async {
      await _pumpApp(tester);

      expect(find.text('Escolha seu Deck'), findsOneWidget);
      expect(find.text('Era Vargas'), findsOneWidget);
      expect(find.text('Geopolítica Contemporânea'), findsOneWidget);
      expect(find.text('3 cartões'), findsNWidgets(2));
    });
  });

  group('StudyScreen - fila da sessão', () {
    testWidgets('fluxo completo: estuda, abre resultado e reinicia o deck',
        (tester) async {
      await _openDeck(tester, 'Era Vargas');

      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('O que foi a Revolução de 1930?'), findsOneWidget);

      await _answer(tester, 'Acertei');
      expect(find.text('2 / 3'), findsOneWidget);

      await _answer(tester, 'Errei');
      expect(find.text('3 / 4'), findsOneWidget);

      await _answer(tester, 'Acertei');
      expect(find.text('4 / 4'), findsOneWidget);
      expect(
        find.text('Qual a principal característica do Estado Novo (1937-1945)?'),
        findsOneWidget,
      );

      await _answer(tester, 'Acertei');

      expect(find.text('Você acertou 2 de 3!'), findsOneWidget);

      await _answer(tester, 'Revisar Novamente');
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('O que foi a Revolução de 1930?'), findsOneWidget);
    });

    testWidgets('card marcado como "Errei" reaparece até ser acertado',
        (tester) async {
      await _openDeck(tester, 'Era Vargas');

      await _answer(tester, 'Errei');
      expect(find.text('2 / 4'), findsOneWidget);
      expect(find.text('O que foi a Revolução de 1930?'), findsNothing);

      await _answer(tester, 'Acertei');
      await _answer(tester, 'Acertei');

      expect(find.text('4 / 4'), findsOneWidget);
      expect(find.text('O que foi a Revolução de 1930?'), findsOneWidget);
      expect(find.text('PERGUNTA'), findsOneWidget);

      await tester.tap(find.byType(FlipCardWidget));
      await tester.pumpAndSettle();
      expect(find.text('RESPOSTA'), findsOneWidget);

      await _answer(tester, 'Errei');
      expect(find.text('5 / 5'), findsOneWidget);
      expect(find.text('PERGUNTA'), findsOneWidget);

      await _answer(tester, 'Acertei');
      expect(find.text('Você acertou 2 de 3!'), findsOneWidget);
    });

    testWidgets('pontuação zera ao reiniciar o deck', (tester) async {
      await _openDeck(tester, 'Geopolítica Contemporânea');
      expect(
        find.text('O que caracteriza a Nova Ordem Mundial?'),
        findsOneWidget,
      );

      for (var i = 0; i < 3; i++) {
        await _answer(tester, 'Acertei');
      }
      expect(find.text('Você acertou 3 de 3!'), findsOneWidget);

      await _answer(tester, 'Revisar Novamente');

      for (var i = 0; i < 3; i++) {
        await _answer(tester, 'Errei');
      }
      expect(find.text('4 / 6'), findsOneWidget);
      for (var i = 0; i < 3; i++) {
        await _answer(tester, 'Acertei');
      }
      expect(find.text('Você acertou 0 de 3!'), findsOneWidget);
    });

    testWidgets('FlipCard exibe a resposta após o toque', (tester) async {
      await _openDeck(tester, 'Era Vargas');

      expect(find.text('PERGUNTA'), findsOneWidget);

      await tester.tap(find.text('O que foi a Revolução de 1930?'));
      await tester.pumpAndSettle();

      expect(find.text('RESPOSTA'), findsOneWidget);
      expect(find.textContaining('Washington Luís'), findsOneWidget);
    });
  });

  group('ResultScreen - navegação', () {
    testWidgets('"Escolher outro Deck" volta para a seleção de decks',
        (tester) async {
      await _openDeck(tester, 'Era Vargas');
      for (var i = 0; i < 3; i++) {
        await _answer(tester, 'Acertei');
      }
      expect(find.text('Você acertou 3 de 3!'), findsOneWidget);

      await _answer(tester, 'Escolher outro Deck');

      expect(find.text('Escolha seu Deck'), findsOneWidget);
      expect(find.text('Errei'), findsNothing);
      expect(find.byType(FlipCardWidget), findsNothing);

      await tester.tap(find.text('Geopolítica Contemporânea'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 3'), findsOneWidget);
    });
  });

  group('StudyScreen - layout responsivo', () {
    testWidgets('celular pequeno em retrato (320x568) sem overflow',
        (tester) async {
      _setLogicalScreenSize(tester, const Size(320, 568));
      await _openDeck(tester, 'Era Vargas');

      final cardSize = tester.getSize(find.byType(FlipCardWidget));
      expect(cardSize.width, lessThanOrEqualTo(320 - 48));
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(FlipCardWidget));
      await tester.pumpAndSettle();
      expect(find.text('RESPOSTA'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('celular em paisagem (568x320) sem overflow', (tester) async {
      _setLogicalScreenSize(tester, const Size(568, 320));
      await _openDeck(tester, 'Era Vargas');

      expect(find.byType(FlipCardWidget), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(FlipCardWidget));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet (1024x1366): cartão limitado a 480 de largura',
        (tester) async {
      _setLogicalScreenSize(tester, const Size(1024, 1366));
      await _openDeck(tester, 'Era Vargas');

      final cardSize = tester.getSize(find.byType(FlipCardWidget));
      expect(cardSize.width, 480);
      expect(cardSize.height, 600);
      expect(tester.takeException(), isNull);
    });
  });
}
