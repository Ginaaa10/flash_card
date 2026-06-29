import 'package:flutter/material.dart';
import 'package:flash_card_app/shared/models/whiteboard_data.dart';

class StickyNode extends StatefulWidget {
  final WhiteboardNode node;
  final Function(WhiteboardNode) onNodeChanged;
  final Function(String) onNodeSelected;
  final bool isSelected;

  const StickyNode({
    super.key,
    required this.node,
    required this.onNodeChanged,
    required this.onNodeSelected,
    this.isSelected = false,
  });

  @override
  State<StickyNode> createState() => _StickyNodeState();
}

class _StickyNodeState extends State<StickyNode> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  static const List<Color> _stickyColors = [
    Color(0xFFFFF176),
    Color(0xFFFFAB91),
    Color(0xFF81D4FA),
    Color(0xFFA5D6A7),
    Color(0xFFCE93D8),
    Color(0xFFFFCC80),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.node.content);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.node.x,
      top: widget.node.y,
      child: GestureDetector(
        onPanStart: (details) {
          widget.onNodeSelected(widget.node.id);
        },
        onPanUpdate: (details) {
          widget.onNodeChanged(
            widget.node.copyWith(
              x: widget.node.x + details.delta.dx,
              y: widget.node.y + details.delta.dy,
            ),
          );
        },
        onDoubleTap: () {
          setState(() => _isEditing = true);
          _focusNode.requestFocus();
        },
        child: Container(
          width: widget.node.width,
          constraints: const BoxConstraints(minHeight: 100),
          decoration: BoxDecoration(
            color: widget.node.backgroundColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildContent(),
              if (widget.isSelected) _buildColorPicker(),
              _buildDeleteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isEditing) {
      return TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
          hintText: 'Write something...',
        ),
        onChanged: (value) {
          widget.onNodeChanged(widget.node.copyWith(content: value));
        },
        onTapOutside: (event) {
          setState(() => _isEditing = false);
          _focusNode.unfocus();
        },
        onSubmitted: (value) {
          setState(() => _isEditing = false);
          _focusNode.unfocus();
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        widget.node.content.isEmpty ? 'Double tap to edit' : widget.node.content,
        style: TextStyle(
          fontSize: 14,
          color: widget.node.content.isEmpty ? Colors.black54 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Positioned(
      top: -40,
      left: 0,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _stickyColors.map((color) {
            final isSelected = color.value == widget.node.backgroundColor.value;
            return GestureDetector(
              onTap: () {
                widget.onNodeChanged(
                  widget.node.copyWith(backgroundColor: color),
                );
              },
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    if (!widget.isSelected) return const SizedBox.shrink();
    return Positioned(
      top: -8,
      right: -8,
      child: GestureDetector(
        onTap: () {
          widget.onNodeSelected('');
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
