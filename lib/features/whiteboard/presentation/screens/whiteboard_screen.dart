import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flash_card_app/features/flashcard/domain/providers/flashcard_provider.dart';
import 'package:flash_card_app/features/flashcard/domain/providers/question_provider.dart';
import 'package:flash_card_app/shared/models/stroke_model.dart';
import 'package:flash_card_app/shared/models/point_model.dart';
import 'package:flash_card_app/shared/models/whiteboard_data.dart';
import 'package:flash_card_app/features/whiteboard/presentation/widgets/infinite_canvas.dart';
import 'package:flash_card_app/features/whiteboard/presentation/widgets/text_node.dart';
import 'package:flash_card_app/features/whiteboard/presentation/widgets/sticky_node.dart';
import 'package:flash_card_app/features/whiteboard/presentation/dialogs/question_generation_dialog.dart';
import 'package:flash_card_app/features/recognition/domain/services/tesseract_ocr_service.dart';

enum WhiteboardMode { draw, node }

class WhiteboardScreen extends ConsumerStatefulWidget {
  final String? flashcardId;

  const WhiteboardScreen({super.key, this.flashcardId});

  @override
  ConsumerState<WhiteboardScreen> createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends ConsumerState<WhiteboardScreen> {
  WhiteboardMode _mode = WhiteboardMode.draw;

  final List<StrokeModel> _strokes = [];
  final List<StrokeModel> _redoStack = [];
  StrokeModel? _currentStroke;
  Color _currentColor = Colors.black;
  double _currentWidth = 3.0;
  bool _isRecognizing = false;
  String? _recognizedText;
  final TesseractOcrService _ocrService = TesseractOcrService();
  final List<PointModel> _currentPoints = [];

  WhiteboardData _whiteboardData = WhiteboardData();
  String? _selectedNodeId;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Whiteboard'),
        actions: [
          _buildModeToggle(theme),
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _isRecognizing ? null : _recognizeText,
            tooltip: 'Recognize',
          ),
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: (_recognizedText == null || _recognizedText!.isEmpty) ? null : _showGenerateQuestionsDialog,
            tooltip: 'Generate Questions',
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
              margin: const EdgeInsets.all(8),
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
                child: _buildCanvas(),
              ),
            ),
          ),
          if (_isRecognizing) const LinearProgressIndicator(),
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
                  Text(_recognizedText!, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          const SizedBox(height: 8),
          _buildToolbar(theme),
        ],
      ),
    );
  }

  Widget _buildModeToggle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            mode: WhiteboardMode.draw,
            icon: Icons.draw,
            label: 'Draw',
            theme: theme,
          ),
          _buildModeButton(
            mode: WhiteboardMode.node,
            icon: Icons.check_box_outlined,
            label: 'Node',
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required WhiteboardMode mode,
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    final isActive = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    if (_mode == WhiteboardMode.node) {
      return _buildNodeCanvas();
    }
    return _buildDrawCanvas();
  }

  Widget _buildNodeCanvas() {
    return InfiniteCanvas(
      data: _whiteboardData,
      onDataChanged: (data) {
        setState(() => _whiteboardData = data);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: _whiteboardData.nodes.map((node) {
          if (node.type == 'sticky') {
            return StickyNode(
              node: node,
              isSelected: _selectedNodeId == node.id,
              onNodeChanged: _updateNode,
              onNodeSelected: _selectNode,
            );
          }
          return TextNode(
            node: node,
            isSelected: _selectedNodeId == node.id,
            onNodeChanged: _updateNode,
            onNodeSelected: _selectNode,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDrawCanvas() {
    return GestureDetector(
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
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    if (_mode == WhiteboardMode.node) {
      return _buildNodeToolbar(theme);
    }
    return _buildDrawToolbar(theme);
  }

  Widget _buildNodeToolbar(ThemeData theme) {
    return Container(
      height: 60,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToolbarAction(
            icon: Icons.text_fields,
            label: 'Text',
            onTap: () => _addNode('text'),
            theme: theme,
          ),
          const SizedBox(width: 12),
          _buildToolbarAction(
            icon: Icons.sticky_note_2,
            label: 'Sticky',
            onTap: () => _addNode('sticky'),
            theme: theme,
          ),
          const SizedBox(width: 12),
          _buildToolbarAction(
            icon: Icons.undo,
            label: 'Undo',
            onTap: _undo,
            enabled: _strokes.isNotEmpty,
            theme: theme,
          ),
          const SizedBox(width: 12),
          _buildToolbarAction(
            icon: Icons.redo,
            label: 'Redo',
            onTap: _redo,
            enabled: _redoStack.isNotEmpty,
            theme: theme,
          ),
          const SizedBox(width: 12),
          _buildToolbarAction(
            icon: Icons.delete_outline,
            label: 'Delete',
            onTap: _deleteSelectedNode,
            enabled: _selectedNodeId != null,
            theme: theme,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawToolbar(ThemeData theme) {
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

  Widget _buildToolbarAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
    required ThemeData theme,
    Color? color,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: enabled
                ? (color ?? theme.colorScheme.primary)
                : Colors.grey.shade400,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: enabled
                  ? (color ?? theme.colorScheme.onSurface)
                  : Colors.grey.shade400,
            ),
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

  void _addNode(String type) {
    final node = WhiteboardNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      x: 100 + (_whiteboardData.nodes.length * 30).toDouble(),
      y: 100 + (_whiteboardData.nodes.length * 30).toDouble(),
      backgroundColor: type == 'sticky'
          ? const Color(0xFFFFF176)
          : Colors.white,
    );
    setState(() {
      _whiteboardData = _whiteboardData.copyWith(
        nodes: [..._whiteboardData.nodes, node],
      );
      _selectedNodeId = node.id;
    });
  }

  void _updateNode(WhiteboardNode updatedNode) {
    setState(() {
      _whiteboardData = _whiteboardData.copyWith(
        nodes: _whiteboardData.nodes.map((n) {
          return n.id == updatedNode.id ? updatedNode : n;
        }).toList(),
      );
    });
  }

  void _selectNode(String nodeId) {
    setState(() => _selectedNodeId = nodeId.isEmpty ? null : nodeId);
  }

  void _deleteSelectedNode() {
    if (_selectedNodeId == null) return;
    setState(() {
      _whiteboardData = _whiteboardData.copyWith(
        nodes: _whiteboardData.nodes
            .where((n) => n.id != _selectedNodeId)
            .toList(),
      );
      _selectedNodeId = null;
    });
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
    if (_mode == WhiteboardMode.node) {
      final nodeTexts = _whiteboardData.nodes
          .where((n) => n.content.isNotEmpty)
          .map((n) => n.content)
          .join('\n');
      if (nodeTexts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add text to nodes first')),
        );
        return;
      }
      setState(() => _recognizedText = nodeTexts);
      return;
    }

    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draw something first')),
      );
      return;
    }

    setState(() => _isRecognizing = true);

    try {
      final imageBytes = await _ocrService.strokesToImageBytes(_strokes);
      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to process image')),
          );
        }
        return;
      }

      final result = await _ocrService.recognizeImage(imageBytes);
      if (result != null && mounted) {
        setState(() => _recognizedText = result);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text recognized. Try clearer handwriting.'),
            duration: Duration(seconds: 3),
          ),
        );
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

  void _showGenerateQuestionsDialog() {
    if (_recognizedText == null || _recognizedText!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please recognize text first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => QuestionGenerationDialog(
        recognizedText: _recognizedText!,
        flashcardId: widget.flashcardId ?? '',
        onGenerateQuestions: _generateQuestions,
      ),
    ).then((questions) {
      if (questions != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully generated ${questions.length} questions'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<List<QuestionModel>> _generateQuestions({
    required String text,
    required String flashcardId,
    required String questionType,
    required int numberOfQuestions,
  }) async {
    final questionNotifier = ref.read(questionProvider.notifier);
    return questionNotifier.generateQuestions(
      text: text,
      flashcardId: flashcardId,
      questionType: questionType,
      numberOfQuestions: numberOfQuestions,
    );
  }

  Future<void> _saveAsFlashcard() async {
    if (_strokes.isEmpty && _whiteboardData.nodes.isEmpty) {
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
      'vi+zh': 'Tiếng Việt + 中文',
      'vi': 'Tiếng Việt',
      'zh': '中文 (简体)',
      'en': 'English',
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
              groupValue: _ocrService.displayLanguage,
              onChanged: (value) {
                if (value != null) {
                  _ocrService.setLanguage(value);
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
