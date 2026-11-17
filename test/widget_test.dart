import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memocards/features/flashcards/presentation/widgets/flip_card_widget.dart';
import 'package:memocards/main.dart';

/// Abre o deck indicado a partir da tela inicial.
Future<void> _openDeck(WidgetTester tester, String title) async {
  await tester.pumpWidget(const MemoCardsApp());
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

Future<void> _answer(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Define o tamanho lógico da tela para o teste.
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
    testWidgets('lista todos os decks disponíveis', (tester) async {
      await tester.pumpWidget(const MemoCardsApp());

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

      await _answer(tester, 'Acertei'); // card 101 de primeira
      expect(find.text('2 / 3'), findsOneWidget);

      await _answer(tester, 'Errei'); // card 102 volta para a fila
      expect(find.text('3 / 4'), findsOneWidget);

      await _answer(tester, 'Acertei'); // card 103 de primeira
      expect(find.text('4 / 4'), findsOneWidget);
      expect(
        find.text('Qual a principal característica do Estado Novo (1937-1945)?'),
        findsOneWidget,
      );

      await _answer(tester, 'Acertei'); // card 102 na repetição

      // Pontuação conta apenas acertos de primeira.
      expect(find.text('Você acertou 2 de 3!'), findsOneWidget);

      await _answer(tester, 'Revisar Novamente');
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('O que foi a Revolução de 1930?'), findsOneWidget);
    });

    testWidgets('card marcado como "Errei" reaparece até ser acertado',
        (tester) async {
      await _openDeck(tester, 'Era Vargas');

      await _answer(tester, 'Errei'); // 101 vai para o fim
      expect(find.text('2 / 4'), findsOneWidget);
      expect(find.text('O que foi a Revolução de 1930?'), findsNothing);

      await _answer(tester, 'Acertei'); // 102
      await _answer(tester, 'Acertei'); // 103

      // 101 volta, exibindo a frente do cartão.
      expect(find.text('4 / 4'), findsOneWidget);
      expect(find.text('O que foi a Revolução de 1930?'), findsOneWidget);
      expect(find.text('PERGUNTA'), findsOneWidget);

      // Vira o cartão e erra de novo: mesmo card volta pela frente.
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

      // Erra todos uma vez e depois acerta as repetições: 0 de primeira.
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

      // A partir da lista é possível abrir outro deck normalmente.
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
