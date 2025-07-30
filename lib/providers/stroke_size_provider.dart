import 'package:flutter_riverpod/flutter_riverpod.dart';

class StrokeSizeNotifier extends StateNotifier<double> {
  StrokeSizeNotifier() : super(5.0);

  void addStrokeSize(double strokeSize) {
    state = strokeSize;
  }
}

final strokeSizeProvider = StateNotifierProvider<StrokeSizeNotifier, double>(
    (ref) => StrokeSizeNotifier());
