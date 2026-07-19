import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flash_card_app/features/flashcard/presentation/screens/flashcard_list_screen.dart';
import 'package:flash_card_app/features/flashcard/presentation/screens/flashcard_editor_screen.dart';
import 'package:flash_card_app/features/flashcard/presentation/screens/quiz_screen.dart';
import 'package:flash_card_app/features/whiteboard/presentation/screens/whiteboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const FlashcardListScreen(),
      ),
      GoRoute(
        path: '/editor/:id',
        name: 'editor',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return FlashcardEditorScreen(flashcardId: id);
        },
      ),
      GoRoute(
        path: '/whiteboard',
        name: 'whiteboard',
        builder: (context, state) => const WhiteboardScreen(),
      ),
      GoRoute(
        path: '/quiz',
        name: 'quiz',
        builder: (context, state) => const QuizScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
