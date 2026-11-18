import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/flashcards/presentation/screens/deck_selection_screen.dart';
import '../../features/flashcards/presentation/screens/result_screen.dart';
import '../../features/flashcards/presentation/screens/study_screen.dart';

/// Nomes e caminhos das rotas da aplicação.
abstract final class AppRoutes {
  static const String home = '/';
  static String study(String deckId) => '/study/$deckId';
  static String result(String deckId, {required int score, required int total}) =>
      '/study/$deckId/result?score=$score&total=$total';
}

/// Roteador declarativo central do MemoCards.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const DeckSelectionScreen(),
      ),
      GoRoute(
        path: '/study/:deckId',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId']!;
          return StudyScreen(deckId: deckId);
        },
        routes: [
          GoRoute(
            path: 'result',
            builder: (context, state) {
              final score =
                  int.tryParse(state.uri.queryParameters['score'] ?? '') ?? 0;
              final total =
                  int.tryParse(state.uri.queryParameters['total'] ?? '') ?? 0;
              return ResultScreen(score: score, totalCards: total);
            },
          ),
        ],
      ),
    ],
  );
});
