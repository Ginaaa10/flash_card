import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_card_app/shared/models/flashcard_model.dart';

class FirestoreService {
  static CollectionReference? _flashcardsRef;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static bool get isReady => _flashcardsRef != null && _uid != null;

  static Future<void> init() async {
    final uid = _uid;
    if (uid == null) return;
    _flashcardsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('flashcards');
  }

  static CollectionReference get _ref {
    if (_flashcardsRef == null) {
      throw Exception('FirestoreService not initialized. Call init() first.');
    }
    return _flashcardsRef!;
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
