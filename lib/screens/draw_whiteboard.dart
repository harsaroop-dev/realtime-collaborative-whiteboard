import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_collaborative_whiteboard/main.dart';
import 'package:realtime_collaborative_whiteboard/models/stroke.dart';
import 'package:realtime_collaborative_whiteboard/models/whiteboard.dart';
import 'package:realtime_collaborative_whiteboard/providers/stroke_size_provider.dart';
import 'package:realtime_collaborative_whiteboard/providers/whiteboard_provider.dart';
import 'package:share_plus/share_plus.dart';

class DrawWhiteBoard extends ConsumerStatefulWidget {
  const DrawWhiteBoard({super.key, required this.id});

  final String id;

  @override
  ConsumerState<DrawWhiteBoard> createState() => _DrawWhiteBoardState();
}

class _DrawWhiteBoardState extends ConsumerState<DrawWhiteBoard> {
  Color pickerColor = Colors.black;
  Color currentColor = Colors.black;

  bool selectedEraser = false;

  late double currentSliderValue;
  Stream<List<Map<String, dynamic>>>? strokeStream = null;
  StreamSubscription? _strokeSubsciption;
  Timer? _debounce;
  List<Stroke> listOfStrokes = [];
  late WhiteBoard whiteboard;

  @override
  void initState() {
    super.initState();

    strokeStream = supabase
        .from('strokes')
        .stream(primaryKey: ['stroke_id']).eq('whiteboard_id', widget.id);
    print("called stream");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _strokeSubsciption = strokeStream!.listen((snapshot) {
        final strokesList = snapshot.map((stroke) {
          final pointsList =
              (stroke['stroke_offset']['data'] as List).map((point) {
            return Offset(point['x'], point['y']);
          }).toList();
          return Stroke(
            points: pointsList,
            color: Color(stroke['color']),
            size: stroke['size'].toDouble(),
          );
        }).toList();

        // if (mounted) {
        // if (strokesList.length ==
        //         ref
        //             .read(whiteBoardProvider)
        //             .firstWhere(
        //               (e) => (e.id == widget.id),
        //             )
        //             .strokes
        //             .length ||
        //     ref
        //             .read(whiteBoardProvider)
        //             .firstWhere(
        //               (e) => (e.id == widget.id),
        //             )
        //             .strokes
        //             .length ==
        //         0)
        ref
            .read(whiteBoardProvider.notifier)
            .updateWhiteBoardStrokes(widget.id, strokesList);
        // print("strokes updated to provider from database");

        // }

        // setState(() {
        //   strokes = strokesList;
        // });
      });
    });

    // currentSliderValue = ref.read(strokeSizeProvider);
    // whiteBoards = ref.read(whiteBoardProvider);
    // for (int i = 0; i < whiteBoards.length; i++) {
    //   if (whiteBoards[i].id == widget.id) {
    //     strokes = whiteBoards[i].strokes;
    //   }
    // }

    // whiteBoardStream = supabase.from('strokes')
  }

  @override
  void dispose() {
    _strokeSubsciption?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
    });
  }

  List<Map<String, double>> toJson(List<Offset> points) {
    return points.map((offset) => {'x': offset.dx, 'y': offset.dy}).toList();
  }

  // void changeSize(double size) {
  //   setState(() {
  //     currentSliderValue = size;
  //   });
  // }

  // void addPoint(Offset point) {
  //   points.add(point);
  // }

  Future<void> _sizeDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SizePopUp();
        });
  }

  Future<void> _colorDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: changeColor,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentColor = pickerColor;
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Ok'),
              ),
            ],
          );
        });
  }

  void inviteUser(WhiteBoard whiteboard, String email) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 100,
            color: Colors.blue,
          );
        });
  }

  Widget whiteBoard() {
    // final strokes = ref.watch(whiteBoardProvider.select((whiteboards) =>
    //     whiteboards.firstWhere((wb) => wb.id == widget.id).strokes));

    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: selectedEraser ? null : _colorDialog,
                child: Text('Change Color')),
            ElevatedButton(onPressed: _sizeDialog, child: Text('Change Size')),
            IconButton(
              onPressed: () {
                setState(() {
                  selectedEraser = !selectedEraser;
                });
                selectedEraser
                    ? currentColor = Colors.red
                    : currentColor = pickerColor;
              },
              icon: Icon(Icons.draw),
              isSelected: selectedEraser,
              selectedIcon: Icon(Icons.delete_forever),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          // onPanEnd: (details) {
          //   strokes.add(points);
          // },
          onPanStart: (details) {
            _debounce?.cancel();
            // strokes.add(
            //   Stroke(points: [], color: currentColor, size: currentSliderValue),
            // );
            ref.read(whiteBoardProvider.notifier).addStroke(
                  whiteboard,
                  Stroke(
                    points: [details.localPosition],
                    color: currentColor,
                    size: currentSliderValue,
                  ),
                );
            // strokes.last.points.add(details.localPosition);
          },
          onPanUpdate: (details) {
            // setState(() {
            // strokes.last.points.add(details.localPosition);
            // });

            ref
                .read(whiteBoardProvider.notifier)
                .addOffsetToLastStroke(whiteboard, details.localPosition);
          },
          onPanEnd: (details) {
            // ref
            //     .read(whiteBoardProvider.notifier)
            //     .updateWhiteBoardStrokes(widget.id, strokes);
            //     await supabase.from('whiteboards').insert({
            //   'title': 'Untitled',
            //   'created_at': DateTime.now().toIso8601String(),
            //   'user_id': supabase.auth.currentUser!.id
            // });
            // final whiteBoardData = await supabase
            //     .from('whiteboards')
            //     .select('whiteboard_id')
            //     .eq('user_id', supabase.auth.currentUser!.id)
            //     .order('created_at', ascending: false)
            //     .limit(1)
            //     .single();
            listOfStrokes.add(Stroke(
                points: [...whiteboard.strokes.last.points],
                color: currentColor,
                size: currentSliderValue));
            _debounce = Timer(const Duration(milliseconds: 450), () async {
              List<Map<String, dynamic>> strokesToDatabase =
                  listOfStrokes.map((stroke) {
                return {
                  'size': stroke.size,
                  'color': stroke.color.value,
                  'stroke_offset': {'data': toJson(stroke.points)},
                  'whiteboard_id': int.parse(widget.id),
                };
              }).toList();
              await supabase.from('strokes').insert(strokesToDatabase

                  // 'size': currentSliderValue,
                  // 'color': pickerColor.value,
                  // 'stroke_offset': {'data': toJson(strokes.last.points)},
                  // 'whiteboard_id': int.parse(widget.id)
                  );

              listOfStrokes.clear();
            });
          },
          child: Container(
            color: Colors.red,
            height: MediaQuery.of(context).size.height - 293,
            width: MediaQuery.of(context).size.width,
            child: CustomPaint(
              painter: MyPainter(whiteboard.strokes),
            ),
          ),
        ),
      ],
    );
  }

  void shareInviteKey() async {
    final result = await Share.share(
      "You have an invite from ${supabase.auth.currentUser!.email} to join them for a art session. Download the app and join with this invite code: ${whiteboard.inviteKey}",
    );
  }

  @override
  Widget build(BuildContext context) {
    currentSliderValue = ref.watch(strokeSizeProvider);
    final whiteBoards = ref.watch(whiteBoardProvider);
    for (int i = 0; i < whiteBoards.length; i++) {
      if (whiteBoards[i].id == widget.id) {
        whiteboard = whiteBoards[i];
        break;
      }
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('hola'),
          actions: [
            IconButton(
              onPressed: shareInviteKey,
              icon: Icon(Icons.share),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        body: StreamBuilder(
          stream: strokeStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active &&
                snapshot.hasData) {
              print('streambuilder rebuild');
              return whiteBoard();
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<Stroke> strokes;

  const MyPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw each stroke separately
    for (Stroke stroke in strokes) {
      if (stroke.points.length < 2)
        continue; // Skip strokes with less than 2 points

      Paint paint = Paint()
        ..color = stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke.size
        ..style = PaintingStyle.stroke;

      Path path = Path(); // Create a new path for each stroke
      path.moveTo(
          stroke.points[0].dx, stroke.points[0].dy); // Move to first point

      // Draw lines between consecutive points
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    return true;
  }
}

// class MyPainter extends CustomPainter {
//   final List<Stroke> strokes;

//   const MyPainter(this.strokes);

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.black
//       ..strokeCap = StrokeCap.round
//       ..strokeWidth = 5.0
//       ..style = PaintingStyle.stroke;

//     Path path = Path();
//     if (strokes.isNotEmpty) {
//       for (Stroke stroke in strokes) {
//         int _i = 0;
//         for (Offset point in stroke.points) {
//           path.moveTo(stroke.points[_i].dx, stroke.points[_i].dy);

//           path.lineTo(point.dx, point.dy);
//           if (point != stroke.points.first) {
//             _i++;
//           }
//         }
//       }
//     }
//     canvas.drawPath(path, paint);

//   }

//   @override
//   bool shouldRepaint(MyPainter oldDelegate) {
//     return true;
//   }
// }

class SizePopUp extends ConsumerStatefulWidget {
  SizePopUp({super.key});

  @override
  ConsumerState<SizePopUp> createState() => _SizePopUpState();
}

class _SizePopUpState extends ConsumerState<SizePopUp> {
  @override
  Widget build(BuildContext context) {
    double currentSliderValue = ref.watch(strokeSizeProvider);
    return AlertDialog(
      title: Text('Pick size!'),
      content: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        height: 50,
        child: Slider(
          value: currentSliderValue,
          onChanged: (value) {
            setState(() {
              currentSliderValue = value;
            });
            ref.read(strokeSizeProvider.notifier).addStrokeSize(value);
          },
          min: 1,
          max: 30,
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            // setState(() {
            // currentSliderValue = value;
            // });
            Navigator.of(context).pop();
          },
          child: Text('Ok'),
        )
      ],
    );
  }
}
