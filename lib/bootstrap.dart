import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/providers.dart';
import 'main.dart';

/// Inicializa o container de dependências, carrega o seed local e retorna
/// o widget raiz pronto para execução.
Future<Widget> createMemoCardsApp({
  List<dynamic> overrides = const [],
}) async {
  final container = ProviderContainer(
    overrides: overrides.cast(),
  );
  await container.read(seedInitialDecksUseCaseProvider)();
  return UncontrolledProviderScope(
    container: container,
    child: const MemoCardsApp(),
  );
}

/// Ponto de inicialização da aplicação.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await createMemoCardsApp());
}
