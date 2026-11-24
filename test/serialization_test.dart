import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
