import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flash_card_app/shared/models/flashcard_model.dart';
import 'package:flash_card_app/shared/services/firestore_service.dart';

class DataExportService {
  static Future<String> exportToJson() async {
    final flashcards = await FirestoreService.getAllFlashcards();
    final jsonData = flashcards.map((fc) => fc.toJson()).toList();
    return jsonEncode(jsonData);
  }

  static Future<void> importFromJson(String jsonString) async {
    try {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      for (final json in jsonData) {
        final flashcard = FlashcardModel.fromJson(json);
        await FirestoreService.saveFlashcard(flashcard);
      }
    } catch (e) {
      debugPrint('Import error: $e');
      rethrow;
    }
  }

  static Future<void> saveBackupToFile() async {
    // No-op: backup is now in Firestore cloud
  }

  static Future<bool> restoreBackupFromFile() async {
    return false;
  }

  static Future<int> getFlashcardCount() async {
    final flashcards = await FirestoreService.getAllFlashcards();
    return flashcards.length;
  }

  static Future<DateTime?> getLastBackupTime() async {
    return null;
  }
}
