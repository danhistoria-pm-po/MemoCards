import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memocards/main.dart';

void main() {
  test('Fontes Poppins estão embarcadas nos assets (modo offline)', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const weights = ['Regular', 'Medium', 'SemiBold', 'Bold'];
    for (final weight in weights) {
      final data = await rootBundle.load('assets/fonts/Poppins-$weight.ttf');
      expect(data.lengthInBytes, greaterThan(0), reason: 'Poppins-$weight');
    }
  });

  testWidgets('DeckSelectionScreen lista todos os decks disponíveis',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MemoCardsApp());

    expect(find.text('Escolha seu Deck'), findsOneWidget);
    expect(find.text('Era Vargas'), findsOneWidget);
    expect(find.text('Geopolítica Contemporânea'), findsOneWidget);
    expect(find.text('3 cartões'), findsNWidgets(2));
  });

  testWidgets(
      'Fluxo completo: seleciona deck, estuda, abre resultado e reinicia',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MemoCardsApp());

    // Abre o primeiro deck ("Era Vargas").
    await tester.tap(find.text('Era Vargas'));
    await tester.pumpAndSettle();

    expect(find.text('Era Vargas'), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('O que foi a Revolução de 1930?'), findsOneWidget);

    // Acertei → Errei → Acertei = 2 acertos de 3.
    await tester.tap(find.text('Acertei'));
    await tester.pump();
    expect(find.text('2 / 3'), findsOneWidget);

    await tester.tap(find.text('Errei'));
    await tester.pump();
    expect(find.text('3 / 3'), findsOneWidget);

    await tester.tap(find.text('Acertei'));
    await tester.pumpAndSettle();

    // Tela de resultado com a pontuação.
    expect(find.text('Você acertou 2 de 3!'), findsOneWidget);
    expect(find.text('Revisar Novamente'), findsOneWidget);
    expect(find.text('Escolher outro Deck'), findsOneWidget);

    // Ao voltar, o deck é reiniciado.
    await tester.tap(find.text('Revisar Novamente'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.text('O que foi a Revolução de 1930?'), findsOneWidget);
  });

  testWidgets('Selecionar segundo deck exibe suas perguntas e zera ao reiniciar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MemoCardsApp());

    await tester.tap(find.text('Geopolítica Contemporânea'));
    await tester.pumpAndSettle();

    expect(find.text('Geopolítica Contemporânea'), findsOneWidget);
    expect(find.text('O que caracteriza a Nova Ordem Mundial?'), findsOneWidget);

    // 1ª rodada: 3 acertos.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Acertei'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Você acertou 3 de 3!'), findsOneWidget);

    await tester.tap(find.text('Escolher outro Deck'));
    await tester.pumpAndSettle();

    // 2ª rodada: 0 acertos.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Errei'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Você acertou 0 de 3!'), findsOneWidget);
  });

  testWidgets('FlipCard exibe a resposta após o toque',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MemoCardsApp());

    await tester.tap(find.text('Era Vargas'));
    await tester.pumpAndSettle();

    expect(find.text('PERGUNTA'), findsOneWidget);

    await tester.tap(find.text('O que foi a Revolução de 1930?'));
    await tester.pumpAndSettle();

    expect(find.text('RESPOSTA'), findsOneWidget);
    expect(find.textContaining('Washington Luís'), findsOneWidget);
  });
}
