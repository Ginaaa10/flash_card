import 'package:flutter/material.dart';
import 'package:flash_card_app/shared/models/whiteboard_data.dart';

class TextNode extends StatefulWidget {
  final WhiteboardNode node;
  final Function(WhiteboardNode) onNodeChanged;
  final Function(String) onNodeSelected;
  final bool isSelected;
  final bool isDragging;

  const TextNode({
    super.key,
    required this.node,
    required this.onNodeChanged,
    required this.onNodeSelected,
    this.isSelected = false,
    this.isDragging = false,
  });

  @override
  State<TextNode> createState() => _TextNodeState();
}

class _TextNodeState extends State<TextNode> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

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
          constraints: const BoxConstraints(minHeight: 50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.blue
                  : Colors.grey.shade300,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _isEditing
              ? _buildEditingMode()
              : _buildDisplayMode(),
        ),
      ),
    );
  }

  Widget _buildDisplayMode() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        widget.node.content.isEmpty ? 'Double tap to edit' : widget.node.content,
        style: TextStyle(
          fontSize: 16,
          color: widget.node.content.isEmpty ? Colors.grey : Colors.black,
        ),
      ),
    );
  }

  Widget _buildEditingMode() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      maxLines: null,
      style: const TextStyle(fontSize: 16),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(12),
        hintText: 'Enter text...',
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
}
