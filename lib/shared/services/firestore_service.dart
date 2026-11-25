import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_card_app/shared/models/flashcard_model.dart';

class FirestoreService {
  /// The current user id, resolved on every access so signing in or out always
  /// points at the right user's data.
  static String? get uid => FirebaseAuth.instance.currentUser?.uid;

  static bool get isReady => uid != null;

  /// Kept for backwards compatibility. No state is cached anymore because the
  /// user can change after starting the app (sign in / sign out / Google).
  static Future<void> init() async {
    if (uid == null) {
      throw Exception('Not signed in.');
    }
  }

  static CollectionReference get _ref {
    final currentUid = uid;
    if (currentUid == null) {
      throw Exception('Not signed in. Sign in to sync your flashcards.');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('flashcards');
  }

  static Future<void> saveFlashcard(FlashcardModel flashcard) async {
    await _ref.doc(flashcard.id).set(flashcard.toJson());
  }

  static Future<FlashcardModel?> getFlashcard(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) return null;
    return FlashcardModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  static Future<List<FlashcardModel>> getAllFlashcards() async {
    try {
      final snapshot =
          await _ref.orderBy('updatedAt', descending: true).get();
      return snapshot.docs.map((doc) {
        return FlashcardModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      final snapshot = await _ref.get();
      return snapshot.docs.map((doc) {
        return FlashcardModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    }
  }

  static Future<void> deleteFlashcard(String id) async {
    await _ref.doc(id).delete();
  }

  static Future<void> deleteAllFlashcards() async {
    final snapshot = await _ref.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
