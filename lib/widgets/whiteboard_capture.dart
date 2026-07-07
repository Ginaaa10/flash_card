import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../services/ocr_service.dart';
import '../services/question_generator_service.dart';

class WhiteboardCaptureButton extends StatefulWidget {
  final GlobalKey repaintKey;
  const WhiteboardCaptureButton({required this.repaintKey, super.key});

  @override
  State<WhiteboardCaptureButton> createState() => _WhiteboardCaptureButtonState();
}

class _WhiteboardCaptureButtonState extends State<WhiteboardCaptureButton> {
  bool loading = false;
  String? lastResult;

  Future<Uint8List> _capturePng() async {
    final boundary = widget.repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _scanAndGenerate() async {
    setState(() => loading = true);
    try {
      final pngBytes = await _capturePng();

      // Run on-device OCR
      final text = await OcrService.runOnDeviceTextRecognition(pngBytes);

      // If OCR result seems empty, prompt user
      if (text.trim().isEmpty) {
        setState(() => lastResult = 'Không thấy văn bản. Vui lòng viết rõ hơn hoặc thử lại.');
        return;
      }

      // Send text to question generator backend
      final questionsJson = await QuestionGeneratorService.generateFromText(text);

      setState(() => lastResult = questionsJson);

      // Show result dialog
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Câu hỏi tạo tự động'),
          content: SingleChildScrollView(child: Text(questionsJson)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Đóng')),
          ],
        ),
      );
    } catch (e) {
      setState(() => lastResult = 'Lỗi: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : _scanAndGenerate,
      icon: loading ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.camera_alt),
      label: Text(loading ? 'Đang xử lý...' : 'Quét & Tạo câu hỏi'),
    );
  }
}
