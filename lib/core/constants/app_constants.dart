import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Flash Card';

  static const double defaultStrokeWidth = 3.0;
  static const Color defaultStrokeColor = Colors.black;
  static const Color defaultBackgroundColor = Colors.white;

  static const int maxUndoSteps = 50;
  static const Duration recognitionDebounce = Duration(milliseconds: 800);

  static const List<String> supportedLanguages = [
    'en-US',
    'vi-VN',
    'zh-CN',
    'ja-JP',
    'ko-KR',
  ];
}