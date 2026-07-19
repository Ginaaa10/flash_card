import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageUploadService {
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static Future<String?> uploadImage({
    required String flashcardId,
    required String side,
    required String type,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        debugPrint('File bytes is null');
        return null;
      }

      debugPrint('File selected: ${file.name} (${bytes.length} bytes)');

      // Try Firebase Storage first
      try {
        final url = await _uploadToStorage(bytes, file.name, flashcardId, side, type);
        if (url != null) return url;
      } catch (e) {
        debugPrint('Storage upload failed: $e');
      }

      // Fallback: store as base64 in Firestore
      debugPrint('Falling back to Firestore base64 storage');
      return await _uploadToFirestore(bytes, file.name, flashcardId, side, type);
    } catch (e, stack) {
      debugPrint('Image upload error: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  static Future<String?> _uploadToStorage(
    Uint8List bytes,
    String fileName,
    String flashcardId,
    String side,
    String type,
  ) async {
    final ext = fileName.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final path = 'users/$_uid/flashcards/$flashcardId/${side}_${type}.$ext';

    final ref = FirebaseStorage.instance.ref().child(path);

    // Upload with timeout
    final uploadTask = ref.putData(bytes, SettableMetadata(contentType: contentType));

    final snapshot = await uploadTask.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        uploadTask.cancel();
        throw TimeoutException('Upload timed out');
      },
    );

    return await snapshot.ref.getDownloadURL();
  }

  static Future<String> _uploadToFirestore(
    Uint8List bytes,
    String fileName,
    String flashcardId,
    String side,
    String type,
  ) async {
    final base64Data = base64Encode(bytes);
    final ext = fileName.split('.').last.toLowerCase();
    final dataUrl = 'data:image/$ext;base64,$base64Data';

    // Store in Firestore under user's images collection
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('images')
        .doc('${flashcardId}_${side}_$type');

    await docRef.set({
      'dataUrl': dataUrl,
      'fileName': fileName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('Stored base64 in Firestore');
    return dataUrl;
  }

  static Future<void> deleteImage(String url) async {
    try {
      if (url.startsWith('data:')) {
        // It's a base64 data URL stored in Firestore - can't delete easily
        return;
      }
      await FirebaseStorage.instance.refFromURL(url).delete();
    } catch (e) {
      debugPrint('Image delete error: $e');
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}
