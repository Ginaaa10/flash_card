import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';

// Conditional imports for web platform
import 'tesseract_ocr_service_web.dart'
    if (dart.library.html) 'tesseract_ocr_service_web.dart'
    as web_service;

class TesseractOcrService {
  String _selectedLanguage = 'vie+chi_sim';
  
  static const Map<String, String> _langMap = {
    'vi': 'vie',
    'zh': 'chi_sim',
    'en': 'eng',
    'vi+zh': 'vie+chi_sim',
  };

  void setLanguage(String lang) {
    _selectedLanguage = _langMap[lang] ?? 'vie+chi_sim';
  }

  String get selectedLanguage => _selectedLanguage;

  String get displayLanguage {
    if (_selectedLanguage == 'vie+chi_sim') return 'vi+zh';
    if (_selectedLanguage == 'vie') return 'vi';
    if (_selectedLanguage == 'chi_sim') return 'zh';
    return 'en';
  }

  Future<String?> recognizeImage(Uint8List imageBytes) async {
    if (kIsWeb) {
      return web_service.recognizeImage(imageBytes, _selectedLanguage);
    }
    // Non-web implementation
    debugPrint('OCR not supported on this platform');
    return null;
  }

  Future<Uint8List?> strokesToImageBytes(
    List<dynamic> strokes, {
    double width = 800,
    double height = 200,
  }) async {
    if (kIsWeb) {
      return web_service.strokesToImageBytes(strokes, width: width, height: height);
    }
    // Non-web implementation
    debugPrint('Stroke to image conversion not supported on this platform');
    return null;
  }
}
