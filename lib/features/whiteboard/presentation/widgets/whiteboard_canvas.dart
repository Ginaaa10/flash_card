import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flash_card_app/shared/models/point_model.dart';
import 'package:flash_card_app/shared/models/stroke_model.dart';
import 'package:flash_card_app/core/constants/app_constants.dart';

class WhiteboardPainter extends CustomPainter {
  final List<StrokeModel> strokes;
  final List<StrokeModel> redoStack;
  final StrokeModel? currentStroke;
  final Color backgroundColor;

  WhiteboardPainter({
    required this.strokes,
    required this.redoStack,
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

    final path = ui.Path();
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
  bool shouldRepaint(covariant WhiteboardPainter oldDelegate) => true;
}

class WhiteboardCanvas extends StatefulWidget {
  final List<StrokeModel> initialStrokes;
  final ValueChanged<List<StrokeModel>>? onStrokesChanged;
  final ValueChanged<StrokeModel>? onStrokeComplete;
  final Color backgroundColor;
  final Color defaultStrokeColor;
  final double defaultStrokeWidth;
  final bool enabled;

  const WhiteboardCanvas({
    super.key,
    this.initialStrokes = const [],
    this.onStrokesChanged,
    this.onStrokeComplete,
    this.backgroundColor = Colors.white,
    this.defaultStrokeColor = Colors.black,
    this.defaultStrokeWidth = AppConstants.defaultStrokeWidth,
    this.enabled = true,
  });

  @override
  State<WhiteboardCanvas> createState() => _WhiteboardCanvasState();
}

class _WhiteboardCanvasState extends State<WhiteboardCanvas> {
  final List<StrokeModel> _strokes = [];
  final List<StrokeModel> _redoStack = [];
  StrokeModel? _currentStroke;
  late Color _currentColor;
  late double _currentWidth;
  int _maxUndoSteps = AppConstants.maxUndoSteps;
  final List<PointModel> _currentPoints = [];

  @override
  void initState() {
    super.initState();
    _strokes.addAll(widget.initialStrokes);
    _currentColor = widget.defaultStrokeColor;
    _currentWidth = widget.defaultStrokeWidth;
  }

  @override
  void didUpdateWidget(WhiteboardCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStrokes != oldWidget.initialStrokes) {
      _strokes
        ..clear()
        ..addAll(widget.initialStrokes);
      _notifyStrokesChanged();
    }
  }

  void _notifyStrokesChanged() {
    widget.onStrokesChanged?.call(List.unmodifiable(_strokes));
  }

  void setStrokeColor(Color color) => setState(() => _currentColor = color);
  void setStrokeWidth(double width) => setState(() => _currentWidth = width);

  void clear() {
    setState(() {
      _strokes.clear();
      _redoStack.clear();
      _currentStroke = null;
      _currentPoints.clear();
    });
    _notifyStrokesChanged();
  }

  void undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _redoStack.add(_strokes.removeLast());
    });
    _notifyStrokesChanged();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _strokes.add(_redoStack.removeLast());
    });
    _notifyStrokesChanged();
  }

  bool get canUndo => _strokes.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  List<StrokeModel> get strokes => List.unmodifiable(_strokes);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: widget.enabled ? _onPanStart : null,
      onPanUpdate: widget.enabled ? _onPanUpdate : null,
      onPanEnd: widget.enabled ? _onPanEnd : null,
      child: CustomPaint(
        painter: WhiteboardPainter(
          strokes: _strokes,
          redoStack: _redoStack,
          currentStroke: _currentStroke,
          backgroundColor: widget.backgroundColor,
        ),
        size: Size.infinite,
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
        id: const Uuid().v4(),
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
        if (_strokes.length > _maxUndoSteps) {
          _strokes.removeAt(0);
        }
      });
      widget.onStrokeComplete?.call(_currentStroke!);
      _notifyStrokesChanged();
    }
    setState(() {
      _currentStroke = null;
      _currentPoints.clear();
    });
  }
}
