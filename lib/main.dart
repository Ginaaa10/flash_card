import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'shared/services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      // On web the saved session is restored asynchronously. Wait for that
      // restore before creating a new anonymous account, otherwise every load
      // can create a fresh account and the user sees a different flashcard set.
      User? restored;
      try {
        restored = await auth.authStateChanges().first.timeout(
          const Duration(seconds: 8),
          onTimeout: () => auth.currentUser,
        );
      } catch (_) {
        restored = auth.currentUser;
      }
      if (restored == null) {
        await auth.signInAnonymously();
      }
    }
  } catch (e) {
    debugPrint('Anonymous auth error: $e');
  }

  try {
    await FirestoreService.init();
  } catch (e) {
    debugPrint('Firestore init error: $e');
  }

  runApp(const ProviderScope(child: FlashCardApp()));
}

class FlashCardApp extends ConsumerWidget {
  const FlashCardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Flash Card App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
