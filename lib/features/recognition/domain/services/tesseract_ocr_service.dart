import 'dart:js_util' as js_util;
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

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
    try {
      final base64Image = base64Encode(imageBytes);
      final dataUrl = 'data:image/png;base64,$base64Image';
      
      final jsObject = js_util.jsify({
        'logger': (dynamic m) => debugPrint('Tesseract: $m'),
      });
      
      final promise = js_util.callMethod(
        js_util.context['Tesseract'] as Object,
        'recognize',
        [dataUrl, _selectedLanguage, jsObject],
      );
      
      final result = await js_util.promiseToFuture<Map<dynamic, dynamic>>(promise);
      final data = result['data'] as Map<dynamic, dynamic>;
      final text = data['text'] as String? ?? '';
      
      return text.isNotEmpty ? text.trim() : null;
    } catch (e) {
      debugPrint('Tesseract OCR error: $e');
      return null;
    }
  }

  Future<Uint8List?> strokesToImageBytes(
    List<dynamic> strokes, {
    double width = 800,
    double height = 200,
  }) async {
    try {
      final canvas = html.CanvasElement(width: width.toInt(), height: height.toInt());
      final ctx = canvas.context2D;
      
      ctx.fillStyle = 'white';
      ctx.fillRect(0, 0, width, height);
      
      ctx.strokeStyle = 'black';
      ctx.lineWidth = 3;
      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';
      
      for (final stroke in strokes) {
        final points = stroke.points;
        if (points.isEmpty) continue;
        
        ctx.beginPath();
        ctx.moveTo(points.first.x, points.first.y);
        
        for (int i = 1; i < points.length; i++) {
          ctx.lineTo(points[i].x, points[i].y);
        }
        ctx.stroke();
      }
      
      final dataUrl = canvas.toDataUrl('image/png');
      final base64 = dataUrl.split(',').last;
      return base64Decode(base64);
    } catch (e) {
      debugPrint('Stroke to image error: $e');
      return null;
    }
  }
}
