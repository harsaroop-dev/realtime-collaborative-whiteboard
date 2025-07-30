import 'package:flutter/material.dart';
import 'package:realtime_collaborative_whiteboard/models/stroke.dart';

class WhiteBoard {
  WhiteBoard({
    required this.strokes,
    required this.createdAt,
    required this.title,
    required this.id,
    required this.inviteKey,
  });

  final List<Stroke> strokes;
  final DateTime createdAt;
  final String title;
  final String id;
  final String inviteKey;

  WhiteBoard copyWith({
    List<Stroke>? strokes,
    DateTime? createdAt,
    String? title,
    String? id,
    String? inviteKey,
  }) {
    return WhiteBoard(
      strokes: strokes ?? this.strokes,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      id: id ?? this.id,
      inviteKey: inviteKey ?? this.inviteKey,
    );
  }
}
