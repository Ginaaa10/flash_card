import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Streams the current Firebase user so the UI can react to sign in / sign out
/// and to account linking (which keeps the same uid and therefore does not
/// trigger [FirebaseAuth.authStateChanges]).
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});

/// A user-facing authentication error with a readable message.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static bool get isGuest => currentUser?.isAnonymous ?? true;

  static bool _isAlreadyInUse(FirebaseAuthException e) =>
      e.code == 'credential-already-in-use' ||
      e.code == 'email-already-in-use' ||
      e.code == 'provider-already-linked';

  static String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-not-found':
        return 'No account was found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'weak-password':
        return 'The password must be at least 6 characters.';
      case 'email-already-in-use':
        return 'That email is already registered. Try signing in instead.';
      case 'operation-not-allowed':
        return 'This sign-in method is disabled. Enable it in the Firebase console.';
      case 'unauthorized-domain':
        return 'This domain is not authorized for sign-in. Add it in the Firebase console.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Sign-in was cancelled.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }

  /// Upgrades the current guest account to an email/password account.
  /// Linking keeps the same user id, so the guest's flashcards are preserved.
  static Future<void> createAccountWithEmail({
    required String email,
    required String password,
  }) async {
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    final user = _auth.currentUser;
    try {
      if (user != null && user.isAnonymous) {
        await user.linkWithCredential(credential);
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (_isAlreadyInUse(e)) {
        throw const AuthException(
          'That email is already registered. Use "Sign in" instead.',
        );
      }
      throw AuthException(_messageFor(e));
    }
  }

  /// Signs into an existing email/password account.
  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    try {
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// Signs in with Google. Linking is attempted first so a guest's cards stay.
  static Future<void> signInWithGoogle() async {
    if (!kIsWeb) {
      throw const AuthException(
        'Google sign-in is currently available on the web version only.',
      );
    }
    final provider = GoogleAuthProvider();
    final user = _auth.currentUser;
    try {
      if (user != null && user.isAnonymous) {
        try {
          await user.linkWithPopup(provider);
          return;
        } on FirebaseAuthException catch (e) {
          if (!_isAlreadyInUse(e)) rethrow;
          // The Google account already exists; switch to that account instead.
        }
      }
      await _auth.signInWithPopup(provider);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// Signs out of the current account and falls back to a fresh guest account
  /// so the app can keep using Firestore.
  static Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _auth.signInAnonymously();
    } catch (_) {
      // Ignore: the UI reports the problem if Firestore is unavailable.
    }
  }
}
