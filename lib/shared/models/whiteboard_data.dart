import 'package:flutter/material.dart';

class WhiteboardNode {
  final String id;
  final String type;
  final String content;
  double x;
  double y;
  double width;
  double height;
  Color backgroundColor;

  WhiteboardNode({
    required this.id,
    required this.type,
    this.content = '',
    this.x = 0,
    this.y = 0,
    this.width = 200,
    this.height = 80,
    this.backgroundColor = Colors.yellow,
  });

  WhiteboardNode copyWith({
    String? id,
    String? type,
    String? content,
    double? x,
    double? y,
    double? width,
    double? height,
    Color? backgroundColor,
  }) => WhiteboardNode(
    id: id ?? this.id,
    type: type ?? this.type,
    content: content ?? this.content,
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
    backgroundColor: backgroundColor ?? this.backgroundColor,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'content': content,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'backgroundColor': backgroundColor.value,
  };

  factory WhiteboardNode.fromJson(Map<String, dynamic> json) => WhiteboardNode(
    id: json['id'] as String,
    type: json['type'] as String,
    content: json['content'] as String? ?? '',
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    width: (json['width'] as num?)?.toDouble() ?? 200,
    height: (json['height'] as num?)?.toDouble() ?? 80,
    backgroundColor: Color(json['backgroundColor'] as int? ?? Colors.yellow.value),
  );
}

class WhiteboardData {
  final List<WhiteboardNode> nodes;
  final double offsetX;
  final double offsetY;
  final double scale;

  WhiteboardData({
    this.nodes = const [],
    this.offsetX = 0,
    this.offsetY = 0,
    this.scale = 1.0,
  });

  WhiteboardData copyWith({
    List<WhiteboardNode>? nodes,
    double? offsetX,
    double? offsetY,
    double? scale,
  }) => WhiteboardData(
    nodes: nodes ?? this.nodes,
    offsetX: offsetX ?? this.offsetX,
    offsetY: offsetY ?? this.offsetY,
    scale: scale ?? this.scale,
  );

  Map<String, dynamic> toJson() => {
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'offsetX': offsetX,
    'offsetY': offsetY,
    'scale': scale,
  };

  factory WhiteboardData.fromJson(Map<String, dynamic> json) => WhiteboardData(
    nodes: (json['nodes'] as List<dynamic>?)
        ?.map((e) => WhiteboardNode.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    offsetX: (json['offsetX'] as num?)?.toDouble() ?? 0,
    offsetY: (json['offsetY'] as num?)?.toDouble() ?? 0,
    scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
  );
}
