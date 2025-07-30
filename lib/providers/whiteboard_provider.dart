import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_collaborative_whiteboard/models/stroke.dart';
import 'package:realtime_collaborative_whiteboard/models/whiteboard.dart';

class WhiteBoardNotifier extends StateNotifier<List<WhiteBoard>> {
  WhiteBoardNotifier() : super([]);

  void addWhiteBoard(WhiteBoard whiteBoard) {
    state = [...state, whiteBoard];
  }

  void updateWhiteBoardList(List<WhiteBoard> whiteBoards) {
    final whiteBoardMap = {for (var wb in state) wb.id: wb}; // Keep existing
    for (var wb in whiteBoards) {
      whiteBoardMap[wb.id] = wb; // Update if exists, add if new
    }
    state = whiteBoardMap.values.toList();
  }

  void addWhiteBoardList(List<WhiteBoard> whiteBoards) {
    state = whiteBoards;
  }

  void updateWhiteBoardStrokes(String id, List<Stroke> newStrokes) {
    state = state.map((whiteboard) {
      if (whiteboard.id == id) {
        if (whiteboard.strokes.length != newStrokes.length)
          return WhiteBoard(
              strokes: newStrokes,
              createdAt: whiteboard.createdAt,
              title: whiteboard.title,
              id: id,
              inviteKey: whiteboard.inviteKey);
      }
      return whiteboard;
    }).toList();
  }

  bool _strokesAreEqual(List<Stroke> oldStrokes, List<Stroke> newStrokes) {
    if (oldStrokes.length != newStrokes.length) return false;
    for (int i = 0; i < oldStrokes.length; i++) {
      if (oldStrokes[i] != newStrokes[i]) return false;
    }
    return true;
  }

  void updateWhiteBoardTitle(String id, String title) {
    state = state.map((whiteboard) {
      if (whiteboard.id == id) {
        return WhiteBoard(
          strokes: whiteboard.strokes,
          createdAt: whiteboard.createdAt,
          title: title,
          id: id,
          inviteKey: whiteboard.inviteKey,
        );
      }
      return whiteboard;
    }).toList();
  }

  void addStroke(WhiteBoard whiteboard, Stroke stroke) {
    state = state.map((wb) {
      if (wb.id == whiteboard.id) {
        return wb.copyWith(
          strokes: [
            ...wb.strokes,
            stroke,
          ],
        );
      }
      return wb;
    }).toList();
  }

  void addOffsetToLastStroke(WhiteBoard whiteboard, Offset offset) {
    state = state.map((wb) {
      if (wb.id == whiteboard.id) {
        List<Stroke> newStrokes = [...wb.strokes];
        newStrokes.last = newStrokes.last.copyWith(
          points: [
            ...newStrokes.last.points,
            offset,
          ],
        );
        return wb.copyWith(
          strokes: newStrokes,
        );
      }
      return wb;
    }).toList();
  }
}

final whiteBoardProvider =
    StateNotifierProvider<WhiteBoardNotifier, List<WhiteBoard>>(
        (ref) => WhiteBoardNotifier());
