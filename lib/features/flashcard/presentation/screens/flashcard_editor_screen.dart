import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flash_card_app/features/flashcard/domain/providers/flashcard_provider.dart';
import 'package:flash_card_app/features/recognition/domain/services/recognition_service.dart';
import 'package:flash_card_app/shared/models/stroke_model.dart';
import 'package:flash_card_app/shared/models/point_model.dart';

class FlashcardEditorScreen extends ConsumerStatefulWidget {
  final String? flashcardId;

  const FlashcardEditorScreen({super.key, this.flashcardId});

  @override
  ConsumerState<FlashcardEditorScreen> createState() =>
      _FlashcardEditorScreenState();
}

class _FlashcardEditorScreenState extends ConsumerState<FlashcardEditorScreen> {
  bool _isFront = true;
  bool _isRecognizing = false;
  bool _isEditingTitle = false;
  bool _isSaving = false;
  String? _activeTool;
  String? _hoveredTool;
  final TextEditingController _titleController = TextEditingController();
  final RecognitionService _recognitionService = RecognitionService();
  final GlobalKey<_WhiteboardDrawingAreaState> _frontCanvasKey = GlobalKey();
  final GlobalKey<_WhiteboardDrawingAreaState> _backCanvasKey = GlobalKey();
  String? _frontRecognizedText;
  String? _backRecognizedText;

  @override
  void initState() {
    super.initState();
    _loadFlashcard();
  }

  void _loadFlashcard() {
    if (widget.flashcardId != null) {
      final flashcard =
          ref.read(flashcardByIdProvider(widget.flashcardId!));
      if (flashcard != null) {
        _titleController.text = flashcard.title;
        _frontRecognizedText = flashcard.frontRecognizedText;
        _backRecognizedText = flashcard.backRecognizedText;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _frontCanvasKey.currentState?.loadStrokes(flashcard.frontStrokes);
            _backCanvasKey.currentState?.loadStrokes(flashcard.backStrokes);
          }
        });
      } else {
        _titleController.text = 'New Flashcard';
        _waitForFlashcard();
      }
    } else {
      _titleController.text = 'New Flashcard';
    }
  }

  void _waitForFlashcard() {
    if (widget.flashcardId == null) return;
    ref.listen(flashcardByIdProvider(widget.flashcardId!), (prev, next) {
      if (next != null && mounted) {
        _titleController.text = next.title;
        _frontRecognizedText = next.frontRecognizedText;
        _backRecognizedText = next.backRecognizedText;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _frontCanvasKey.currentState?.loadStrokes(next.frontStrokes);
            _backCanvasKey.currentState?.loadStrokes(next.backStrokes);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recognitionService.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() => _isFront = !_isFront);
  }

  _WhiteboardDrawingAreaState? get _currentCanvas =>
      _isFront ? _frontCanvasKey.currentState : _backCanvasKey.currentState;

  void _undo() {
    _currentCanvas?.undo();
    setState(() {});
  }

  void _redo() {
    _currentCanvas?.redo();
    setState(() {});
  }

  void _clearCurrent() {
    _currentCanvas?.clear();
    setState(() {
      if (_isFront) {
        _frontRecognizedText = null;
      } else {
        _backRecognizedText = null;
      }
    });
  }

  Future<void> _recognizeText() async {
    final strokes = _currentStrokes;
    if (strokes.isEmpty) return;

    setState(() => _isRecognizing = true);

    try {
      final result = await _recognitionService.recognizeStrokes(strokes);
      if (mounted && result != null && result.text.isNotEmpty) {
        setState(() {
          if (_isFront) {
            _frontRecognizedText = result.text;
          } else {
            _backRecognizedText = result.text;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recognized: "${result.text}"'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text recognized'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recognition failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecognizing = false);
    }
  }

  List<StrokeModel> get _currentStrokes =>
      _currentCanvas?.strokes ?? [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;
    final cardHeight = cardWidth * 0.65;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _saveFlashcard();
            if (mounted) context.go('/');
          },
        ),
        title: _isEditingTitle
            ? TextField(
                controller: _titleController,
                autofocus: true,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter title',
                ),
                onSubmitted: (value) {
                  setState(() => _isEditingTitle = false);
                },
              )
            : GestureDetector(
                onTap: () => setState(() => _isEditingTitle = true),
                child: Text(
                  _titleController.text.isEmpty
                      ? 'New Flashcard'
                      : _titleController.text,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildSideSelector(theme),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: _buildFlashcard(cardWidth, cardHeight, theme),
              ),
            ),
            if (_isRecognizing) const LinearProgressIndicator(),
            _buildToolbar(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSideSelector(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSideButton('Front', _isFront, theme, () {
          if (!_isFront) _flipCard();
        }),
        const SizedBox(width: 12),
        _buildSideButton('Back', !_isFront, theme, () {
          if (_isFront) _flipCard();
        }),
      ],
    );
  }

  Widget _buildSideButton(
      String label, bool isActive, ThemeData theme, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFlashcard(double width, double height, ThemeData theme) {
    final recognizedText =
        _isFront ? _frontRecognizedText : _backRecognizedText;

    return _buildCardContent(width, height, theme, recognizedText);
  }

  Widget _buildCardContent(
    double width,
    double height,
    ThemeData theme,
    String? recognizedText,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildDrawingArea(theme),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildCardHeader(theme),
            ),
            if (recognizedText != null && recognizedText.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildRecognizedText(recognizedText, theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(ThemeData theme) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _buildColorDot(Colors.black),
          _buildColorDot(Colors.red),
          _buildColorDot(Colors.blue),
          _buildColorDot(Colors.green),
          const SizedBox(width: 8),
          Container(width: 1, height: 20, color: Colors.grey.shade300),
          const SizedBox(width: 8),
          _buildWidthDot(2.0),
          _buildWidthDot(3.0),
          _buildWidthDot(5.0),
          const Spacer(),
          IconButton(
            onPressed: _currentStrokes.isNotEmpty ? _undo : null,
            icon: const Icon(Icons.undo, size: 18),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            onPressed: _currentCanvas?.canRedo == true ? _redo : null,
            icon: const Icon(Icons.redo, size: 18),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            onPressed: _currentStrokes.isNotEmpty ? _clearCurrent : null,
            icon: const Icon(Icons.delete_outline, size: 18),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
    );
  }

  Widget _buildWidthDot(double width) {
    return Container(
      width: 28,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: width * 2,
          height: width * 2,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawingArea(ThemeData theme) {
    return Container(
      color: Colors.white,
      child: IndexedStack(
        index: _isFront ? 0 : 1,
        children: [
          _WhiteboardDrawingArea(key: _frontCanvasKey),
          _WhiteboardDrawingArea(key: _backCanvasKey),
        ],
      ),
    );
  }

  Widget _buildRecognizedText(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_fix_high,
              size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolbarButton(
            toolId: 'undo',
            icon: Icons.undo,
            label: 'Undo',
            enabled: _currentStrokes.isNotEmpty,
            isActive: false,
            onTap: _undo,
            theme: theme,
          ),
          _buildToolbarButton(
            toolId: 'redo',
            icon: Icons.redo,
            label: 'Redo',
            enabled: _currentCanvas?.canRedo == true,
            isActive: false,
            onTap: _redo,
            theme: theme,
          ),
          _buildToolbarButton(
            toolId: 'flip',
            icon: Icons.flip_to_front,
            label: 'Flip',
            enabled: true,
            isActive: false,
            onTap: _flipCard,
            theme: theme,
          ),
          _buildToolbarButton(
            toolId: 'ocr',
            icon: Icons.text_snippet,
            label: 'OCR',
            enabled: _currentStrokes.isNotEmpty,
            isActive: _isRecognizing,
            onTap: _recognizeText,
            theme: theme,
          ),
          _buildToolbarButton(
            toolId: 'save',
            icon: Icons.save,
            label: _isSaving ? 'Saving...' : 'Save',
            enabled: !_isSaving,
            isActive: _isSaving,
            onTap: () async {
              setState(() => _isSaving = true);
              await _saveFlashcard();
              if (mounted) {
                setState(() => _isSaving = false);
                context.go('/');
              }
            },
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required String toolId,
    required IconData icon,
    required String label,
    required bool enabled,
    required bool isActive,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final isHovered = _hoveredTool == toolId;
    final color = isActive
        ? theme.colorScheme.primary
        : enabled
            ? theme.colorScheme.onSurface
            : Colors.grey.shade400;

    return MouseRegion(
      onEnter: enabled ? (_) => setState(() => _hoveredTool = toolId) : null,
      onExit: enabled ? (_) => setState(() => _hoveredTool = null) : null,
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: isActive || isHovered ? 14 : 12,
            vertical: isActive || isHovered ? 10 : 8,
          ),
          decoration: (isActive || isHovered) && enabled
              ? BoxDecoration(
                  color: theme.colorScheme.primary
                      .withOpacity(isActive ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  icon,
                  size: isActive ? 26 : (isHovered ? 24 : 22),
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight:
                      (isActive || isHovered) ? FontWeight.w700 : FontWeight.normal,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveFlashcard() async {
    final notifier = ref.read(flashcardProvider.notifier);
    final frontStrokes = _frontCanvasKey.currentState?.strokes ?? [];
    final backStrokes = _backCanvasKey.currentState?.strokes ?? [];
    final title = _titleController.text.isEmpty
        ? 'New Flashcard'
        : _titleController.text;

    try {
      if (widget.flashcardId != null) {
        final existing =
            ref.read(flashcardByIdProvider(widget.flashcardId!));
        if (existing != null) {
          await notifier.updateFlashcard(
            existing.copyWith(
              title: title,
              frontStrokes: frontStrokes,
              backStrokes: backStrokes,
              frontRecognizedText: _frontRecognizedText,
              backRecognizedText: _backRecognizedText,
            ),
          );
        } else {
          await notifier.createFlashcard(
            title: title,
            frontStrokes: frontStrokes,
            backStrokes: backStrokes,
          );
        }
      } else {
        await notifier.createFlashcard(
          title: title,
          frontStrokes: frontStrokes,
          backStrokes: backStrokes,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }
}

class _WhiteboardDrawingArea extends StatefulWidget {
  const _WhiteboardDrawingArea({super.key});

  @override
  State<_WhiteboardDrawingArea> createState() =>
      _WhiteboardDrawingAreaState();
}

class _WhiteboardDrawingAreaState extends State<_WhiteboardDrawingArea> {
  final List<StrokeModel> _strokes = [];
  final List<StrokeModel> _redoStack = [];
  StrokeModel? _currentStroke;
  final List<PointModel> _currentPoints = [];
  final GlobalKey _paintKey = GlobalKey();

  List<StrokeModel> get strokes => List.unmodifiable(_strokes);
  bool get canRedo => _redoStack.isNotEmpty;

  void loadStrokes(List<StrokeModel> strokes) {
    setState(() {
      _strokes
        ..clear()
        ..addAll(strokes);
      _redoStack.clear();
    });
  }

  void undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _redoStack.add(_strokes.removeLast());
    });
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _strokes.add(_redoStack.removeLast());
    });
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _redoStack.clear();
      _currentStroke = null;
      _currentPoints.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        key: _paintKey,
        painter: _WhiteboardPainter(
          strokes: _strokes,
          currentStroke: _currentStroke,
          backgroundColor: Colors.white,
        ),
        size: Size.infinite,
      ),
    );
  }

  PointModel _globalToLocal(Offset globalPosition) {
    final RenderBox box =
        _paintKey.currentContext!.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalPosition);
    return PointModel(
      x: local.dx,
      y: local.dy,
      time: DateTime.now().millisecondsSinceEpoch.toDouble(),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final point = _globalToLocal(details.globalPosition);
    _currentPoints.clear();
    _currentPoints.add(point);
    setState(() {
      _currentStroke = StrokeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        points: _currentPoints.toList(),
        color: Colors.black,
        width: 3.0,
        timestamp: DateTime.now(),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final point = _globalToLocal(details.globalPosition);
    _currentPoints.add(point);
    _currentStroke = StrokeModel(
      id: _currentStroke!.id,
      points: List.unmodifiable(_currentPoints),
      color: Colors.black,
      width: 3.0,
      timestamp: _currentStroke!.timestamp,
    );
    setState(() {});
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
