import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhiteboardToolbar extends ConsumerWidget {
  final Color currentColor;
  final double currentWidth;
  final bool canUndo;
  final bool canRedo;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onWidthChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final VoidCallback? onRecognize;
  final bool isRecognizing;

  const WhiteboardToolbar({
    super.key,
    required this.currentColor,
    required this.currentWidth,
    required this.canUndo,
    required this.canRedo,
    required this.onColorChanged,
    required this.onWidthChanged,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    this.onRecognize,
    this.isRecognizing = false,
  });

  static const List<Color> _defaultColors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

  static const List<double> _defaultWidths = [2.0, 3.0, 5.0, 8.0, 12.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      height: 100,
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
          const SizedBox(height: 4),
          _buildWidthPicker(theme),
          const SizedBox(height: 4),
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildColorPicker(ThemeData theme) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _defaultColors.map((color) {
          final isSelected = color == currentColor;
          return GestureDetector(
            onTap: () => onColorChanged(color),
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
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWidthPicker(ThemeData theme) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _defaultWidths.map((width) {
          final isSelected = width == currentWidth;
          return GestureDetector(
            onTap: () => onWidthChanged(width),
            child: Container(
              width: 40,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: theme.colorScheme.primary)
                    : null,
              ),
              child: Center(
                child: Container(
                  width: width * 2,
                  height: width * 2,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: canUndo ? onUndo : null,
            icon: const Icon(Icons.undo, size: 20),
            tooltip: 'Undo',
          ),
          IconButton(
            onPressed: canRedo ? onRedo : null,
            icon: const Icon(Icons.redo, size: 20),
            tooltip: 'Redo',
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Clear',
            color: Colors.red,
          ),
          if (onRecognize != null) ...[
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: isRecognizing ? null : onRecognize,
                icon: isRecognizing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_fix_high, size: 20),
                tooltip: 'Recognize',
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
