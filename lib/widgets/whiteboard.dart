import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Whiteboard extends StatefulWidget {
  final GlobalKey repaintKey;
  const Whiteboard({required this.repaintKey, super.key});

  @override
  State<Whiteboard> createState() => _WhiteboardState();
}

class _WhiteboardState extends State<Whiteboard> {
  List<DrawnLine> lines = [];
  DrawnLine? currentLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RepaintBoundary(
            key: widget.repaintKey,
            child: GestureDetector(
              onPanStart: (details) {
                final box = context.findRenderObject() as RenderBox;
                final point = box.globalToLocal(details.globalPosition);
                setState(() {
                  currentLine = DrawnLine([point]);
                  lines.add(currentLine!);
                });
              },
              onPanUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final point = box.globalToLocal(details.globalPosition);
                setState(() {
                  currentLine?.points.add(point);
                });
              },
              onPanEnd: (_) {
                setState(() {
                  currentLine = null;
                });
              },
              child: CustomPaint(
                painter: _WhiteboardPainter(lines: lines),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => setState(() => lines.clear()),
              tooltip: 'Xóa',
            ),
            IconButton(
              icon: Icon(Icons.undo),
              onPressed: () => setState(() {
                if (lines.isNotEmpty) lines.removeLast();
              }),
              tooltip: 'Hoàn tác',
            ),
          ],
        ),
      ],
    );
  }
}

class DrawnLine {
  List<Offset> points;
  DrawnLine(this.points);
}

class _WhiteboardPainter extends CustomPainter {
  final List<DrawnLine> lines;
  _WhiteboardPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final line in lines) {
      if (line.points.length < 2) continue;
      final path = Path();
      path.moveTo(line.points.first.dx, line.points.first.dy);
      for (int i = 1; i < line.points.length; i++) {
        path.lineTo(line.points[i].dx, line.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) => true;
}
