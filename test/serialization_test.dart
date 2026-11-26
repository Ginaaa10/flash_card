import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash_card_app/shared/models/flashcard_face_model.dart';
import 'package:flash_card_app/shared/models/flashcard_model.dart';
import 'package:flash_card_app/shared/models/stroke_model.dart';
import 'package:flash_card_app/shared/models/point_model.dart';

void main() {
  test('FlashcardModel.toJson must be Firestore-safe (nested strokes as maps)',
      () {
    final flashcard = FlashcardModel(
      id: 'test-id',
      title: 'Test',
      frontStrokes: [
        StrokeModel(
          id: 's1',
          points: const [
            PointModel(x: 1, y: 2, time: 0),
            PointModel(x: 3, y: 4, time: 1),
          ],
          color: Colors.black,
          width: 3.0,
          timestamp: DateTime(2026, 1, 1),
        ),
      ],
      backStrokes: const [],
      frontText: 'hello',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    final json = flashcard.toJson();

    // Firestore only supports plain maps/lists/primitives.
    final strokes = json['frontStrokes'] as List<dynamic>;
    expect(strokes.first, isA<Map<String, dynamic>>(),
        reason: 'Nested StrokeModel must be converted to a Map for Firestore');
  });

  test('FlashcardModel round-trips through a Firestore-like JSON payload', () {
    final original = FlashcardModel(
      id: 'test-id',
      title: 'Test',
      frontStrokes: [
        StrokeModel(
          id: 's1',
          points: const [
            PointModel(x: 1, y: 2, time: 0),
            PointModel(x: 3, y: 4, time: 1),
          ],
          color: Colors.blue,
          width: 3.0,
          timestamp: DateTime(2026, 1, 1),
        ),
      ],
      backStrokes: const [],
      frontText: 'hello',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    // Simulate what Firestore stores and returns.
    final stored = jsonDecode(jsonEncode(original.toJson()));
    final restored = FlashcardModel.fromJson(stored as Map<String, dynamic>);

    expect(restored.frontStrokes.length, 1);
    expect(restored.frontStrokes.first.points.length, 2);
    expect(restored.frontStrokes.first.color.value, Colors.blue.value);
    expect(restored.frontText, 'hello');
  });

  test('extra sides round-trip through Firestore JSON', () {
    final original = FlashcardModel(
      id: 'test-id',
      title: 'Test',
      frontStrokes: const [],
      backStrokes: const [],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      extraFaces: [
        FlashcardFace(
          id: 'side-3',
          name: 'Side 3',
          strokes: [
            StrokeModel(
              id: 's3',
              points: const [PointModel(x: 5, y: 6, time: 0)],
              color: Colors.green,
              width: 2.0,
              timestamp: DateTime(2026, 1, 1),
            ),
          ],
          text: 'third side',
          recognizedText: 'ocr text',
        ),
      ],
    );

    expect(original.faceCount, 3);

    final json = original.toJson();
    final storedFaces = json['extraFaces'] as List<dynamic>;
    expect(storedFaces.first, isA<Map<String, dynamic>>(),
        reason: 'Extra sides must be plain maps for Firestore');
    final storedStrokes =
        (storedFaces.first as Map<String, dynamic>)['strokes'] as List<dynamic>;
    expect(storedStrokes.first, isA<Map<String, dynamic>>(),
        reason: 'Strokes inside an extra side must also be plain maps');

    final restored = FlashcardModel.fromJson(
      jsonDecode(jsonEncode(json)) as Map<String, dynamic>,
    );

    expect(restored.extraFaces.length, 1);
    expect(restored.extraFaces.first.name, 'Side 3');
    expect(restored.extraFaces.first.text, 'third side');
    expect(restored.extraFaces.first.recognizedText, 'ocr text');
    expect(restored.extraFaces.first.strokes.length, 1);
    expect(restored.extraFaces.first.strokes.first.points.length, 1);
    expect(restored.faceCount, 3);
  });

  test('flashcards saved before extra sides existed still load', () {
    final legacyJson = {
      'id': 'old-id',
      'title': 'Old card',
      'frontStrokes': <dynamic>[],
      'backStrokes': <dynamic>[],
      'frontText': 'hello',
      'createdAt': '2026-01-01T00:00:00.000',
      'updatedAt': '2026-01-01T00:00:00.000',
      'tags': <dynamic>[],
      'reviewCount': 0,
      'isFavorite': false,
      'borderStyle': 'solid',
      'borderColor': 0xFF6366F1,
      'borderWidth': 2.0,
      'borderRadius': 16.0,
    };

    final restored = FlashcardModel.fromJson(legacyJson);

    expect(restored.extraFaces, isEmpty);
    expect(restored.faceCount, 2);
    expect(restored.frontText, 'hello');
  });
}
