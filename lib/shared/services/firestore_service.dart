import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_card_app/shared/models/flashcard_model.dart';

class FirestoreService {
  static late CollectionReference _flashcardsRef;

  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static Future<void> init() async {
    _flashcardsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('flashcards');
  }

  static Future<void> saveFlashcard(FlashcardModel flashcard) async {
    await _flashcardsRef.doc(flashcard.id).set(flashcard.toJson());
  }

  static Future<FlashcardModel?> getFlashcard(String id) async {
    final doc = await _flashcardsRef.doc(id).get();
    if (!doc.exists) return null;
    return FlashcardModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  static Future<List<FlashcardModel>> getAllFlashcards() async {
    final snapshot =
        await _flashcardsRef.orderBy('updatedAt', descending: true).get();
    return snapshot.docs.map((doc) {
      return FlashcardModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  static Future<void> deleteFlashcard(String id) async {
    await _flashcardsRef.doc(id).delete();
  }

  static Future<void> deleteAllFlashcards() async {
    final snapshot = await _flashcardsRef.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
