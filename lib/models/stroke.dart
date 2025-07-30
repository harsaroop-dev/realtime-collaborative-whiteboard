import 'package:flutter/material.dart';

class Stroke {
  Stroke({
    required this.points,
    required this.color,
    required this.size,
  });
  final List<Offset> points;
  final Color color;
  final double size;

  Stroke copyWith({
    List<Offset>? points,
    Color? color,
    double? size,
  }) {
    return Stroke(
      points: points ?? this.points,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }
}
