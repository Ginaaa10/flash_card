import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flash_card_app/shared/models/whiteboard_data.dart';

class InfiniteCanvas extends StatefulWidget {
  final WhiteboardData data;
  final Function(WhiteboardData) onDataChanged;
  final Widget? child;
  final bool enablePan;
  final bool enableZoom;

  const InfiniteCanvas({
    super.key,
    required this.data,
    required this.onDataChanged,
    this.child,
    this.enablePan = true,
    this.enableZoom = true,
  });

  @override
  State<InfiniteCanvas> createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  late TransformationController _transformationController;
  double _minScale = 0.1;
  double _maxScale = 5.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: widget.enableZoom ? _minScale : 1.0,
      maxScale: widget.enableZoom ? _maxScale : 1.0,
      panEnabled: widget.enablePan,
      scaleEnabled: widget.enableZoom,
      onInteractionEnd: (details) {
        final matrix = _transformationController.value;
        final offset = matrix.getTranslation();
        final scale = matrix.getMaxScaleOnAxis();
        widget.onDataChanged(
          widget.data.copyWith(
            offsetX: offset.x,
            offsetY: offset.y,
            scale: scale,
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildGridBackground(),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }

  Widget _buildGridBackground() {
    return Container(
      width: 10000,
      height: 10000,
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _GridPainter(),
      ),
    );
  }

  void resetView() {
    _transformationController.value = Matrix4.identity();
  }

  void zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale < _maxScale) {
      _transformationController.value = _transformationController.value
        ..scale(1.2);
    }
  }

  void zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > _minScale) {
      _transformationController.value = _transformationController.value
        ..scale(0.8);
    }
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.5;

    final smallGridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 0.3;

    const smallGridSize = 20.0;
    const largeGridSize = 100.0;

    for (double x = 0; x < size.width; x += smallGridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        x % largeGridSize == 0 ? paint : smallGridPaint,
      );
    }

    for (double y = 0; y < size.height; y += smallGridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        y % largeGridSize == 0 ? paint : smallGridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
