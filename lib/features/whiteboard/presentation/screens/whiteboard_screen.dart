import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flash_card_app/features/flashcard/domain/providers/flashcard_provider.dart';
import 'package:flash_card_app/features/recognition/domain/services/recognition_service.dart';
import 'package:flash_card_app/shared/models/stroke_model.dart';
import 'package:flash_card_app/shared/models/point_model.dart';

class WhiteboardScreen extends ConsumerStatefulWidget {
  final String? flashcardId;

  const WhiteboardScreen({super.key, this.flashcardId});

  @override
  ConsumerState<WhiteboardScreen> createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends ConsumerState<WhiteboardScreen> {
  final List<StrokeModel> _strokes = [];
  final List<StrokeModel> _redoStack = [];
  StrokeModel? _currentStroke;
  Color _currentColor = Colors.black;
  double _currentWidth = 3.0;
  bool _isRecognizing = false;
  String? _recognizedText;
  final RecognitionService _recognitionService = RecognitionService();
  final List<PointModel> _currentPoints = [];

  @override
  void dispose() {
    _recognitionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Whiteboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _isRecognizing ? null : _recognizeText,
            tooltip: 'Recognize',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAsFlashcard,
            tooltip: 'Save as Flashcard',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'language',
                child: ListTile(
                  leading: Icon(Icons.language),
                  title: Text('Language'),
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.delete_sweep, color: Colors.red),
                  title: Text('Clear All', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: _WhiteboardPainter(
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                      backgroundColor: Colors.white,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          if (_isRecognizing)
            const LinearProgressIndicator(),
          if (_recognizedText != null && _recognizedText!.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_fix_high,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Recognized Text',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recognizedText!,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          _buildToolbar(theme),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildColorPicker(theme),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWidthButton(2.0, theme),
              _buildWidthButton(3.0, theme),
              _buildWidthButton(5.0, theme),
              _buildWidthButton(8.0, theme),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _strokes.isEmpty ? null : _undo,
                icon: const Icon(Icons.undo, size: 20),
                tooltip: 'Undo',
              ),
              IconButton(
                onPressed: _redoStack.isEmpty ? null : _redo,
                icon: const Icon(Icons.redo, size: 20),
                tooltip: 'Redo',
              ),
              IconButton(
                onPressed: _strokes.isEmpty ? null : _clear,
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: 'Clear',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(ThemeData theme) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: colors.map((color) {
          final isSelected = color == _currentColor;
          return GestureDetector(
            onTap: () => setState(() => _currentColor = color),
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 3)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWidthButton(double width, ThemeData theme) {
    final isSelected = width == _currentWidth;
    return GestureDetector(
      onTap: () => setState(() => _currentWidth = width),
      child: Container(
        width: 40,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: theme.colorScheme.primary) : null,
        ),
        child: Center(
          child: Container(
            width: width * 2,
            height: width * 2,
            decoration: BoxDecoration(
              color: _currentColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.localPosition);
    _currentPoints.clear();
    _currentPoints.add(PointModel(
      x: localPosition.dx,
      y: localPosition.dy,
      time: DateTime.now().millisecondsSinceEpoch.toDouble(),
    ));
    setState(() {
      _currentStroke = StrokeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        points: _currentPoints.toList(),
        color: _currentColor,
        width: _currentWidth,
        timestamp: DateTime.now(),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.localPosition);
    _currentPoints.add(PointModel(
      x: localPosition.dx,
      y: localPosition.dy,
      time: DateTime.now().millisecondsSinceEpoch.toDouble(),
    ));
    setState(() {
      _currentStroke = StrokeModel(
        id: _currentStroke!.id,
        points: _currentPoints.toList(),
        color: _currentColor,
        width: _currentWidth,
        timestamp: _currentStroke!.timestamp,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke != null && _currentPoints.isNotEmpty) {
      setState(() {
        _strokes.add(_currentStroke!);
        if (_strokes.length > 50) {
          _strokes.removeAt(0);
        }
      });
    }
    setState(() {
      _currentStroke = null;
      _currentPoints.clear();
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _redoStack.add(_strokes.removeLast());
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _strokes.add(_redoStack.removeLast());
    });
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _redoStack.clear();
      _currentStroke = null;
      _currentPoints.clear();
      _recognizedText = null;
    });
  }

  Future<void> _recognizeText() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draw something first')),
      );
      return;
    }

    setState(() => _isRecognizing = true);

    try {
      final result = await _recognitionService.recognizeStrokes(_strokes);
      if (result != null && mounted) {
        setState(() => _recognizedText = result.text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recognition error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRecognizing = false);
      }
    }
  }

  Future<void> _saveAsFlashcard() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draw something first')),
      );
      return;
    }

    final titleController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as Flashcard'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'Enter card title',
            labelText: 'Title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, titleController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty && mounted) {
      final flashcard = await ref
          .read(flashcardProvider.notifier)
          .createFlashcard(
            title: result.trim(),
            frontStrokes: _strokes.toList(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved as "${flashcard.title}"'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () => context.push('/editor/${flashcard.id}'),
            ),
          ),
        );
      }
    }
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'language':
        _showLanguageDialog();
        break;
      case 'clear':
        _showClearDialog();
        break;
    }
  }

  void _showLanguageDialog() {
    final languages = {
      'en-US': 'English',
      'vi-VN': 'Tiếng Việt',
      'zh-CN': '中文',
      'ja-JP': '日本語',
      'ko-KR': '한국어',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _recognitionService.selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  _recognitionService.setLanguage(value);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Whiteboard'),
        content: const Text('Are you sure you want to clear all drawings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _clear();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _WhiteboardPainter extends CustomPainter {
  final List<StrokeModel> strokes;
  final StrokeModel? currentStroke;
  final Color backgroundColor;

  _WhiteboardPainter({
    required this.strokes,
    this.currentStroke,
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, StrokeModel stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (stroke.points.length == 1) {
      final p = stroke.points.first;
      path.moveTo(p.x, p.y);
      path.lineTo(p.x + 0.1, p.y + 0.1);
    } else if (stroke.points.length == 2) {
      path.moveTo(stroke.points.first.x, stroke.points.first.y);
      path.lineTo(stroke.points.last.x, stroke.points.last.y);
    } else {
      path.moveTo(stroke.points.first.x, stroke.points.first.y);
      for (int i = 1; i < stroke.points.length - 1; i++) {
        final p0 = stroke.points[i];
        final p1 = stroke.points[i + 1];
        final midX = (p0.x + p1.x) / 2;
        final midY = (p0.y + p1.y) / 2;
        path.quadraticBezierTo(p0.x, p0.y, midX, midY);
      }
      final last = stroke.points.last;
      path.lineTo(last.x, last.y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) => true;
}
