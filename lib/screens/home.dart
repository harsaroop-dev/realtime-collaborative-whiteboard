import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_collaborative_whiteboard/main.dart';
import 'package:realtime_collaborative_whiteboard/models/whiteboard.dart';
import 'package:realtime_collaborative_whiteboard/providers/whiteboard_provider.dart';
import 'package:realtime_collaborative_whiteboard/screens/draw_whiteboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Stream<List<Map<String, dynamic>>>? userWhiteboardsStream = null;
  StreamSubscription? whiteboardSubsciption;
  late List<String> inviteKeyList;
  final _form = GlobalKey<FormState>();
  var inviteKey = '';

  @override
  void initState() {
    super.initState();
    inviteKeyList = [];
    // userWhiteboardsStream = supabase
    //     .from('userswhiteboards')
    //     .stream(primaryKey: ['userwhiteboards_id']).eq(
    //         'user_id', supabase.auth.currentUser!.id);
    userWhiteboardsStream = supabase
        .from('userswhiteboards')
        .stream(primaryKey: ['userwhiteboards_id']);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userWhiteboardsStream != null) {
        // print("inside if");
        // print(supabase.auth.currentUser!.email);
        whiteboardSubsciption = userWhiteboardsStream?.listen((snapshot) async {
          // final wbIdList = snapshot.map((w) => w['whiteboard_id']).toList();
          final data = await supabase
              .from('userswhiteboards')
              .select('whiteboard_id')
              .eq('user_id', supabase.auth.currentUser!.id);

          final wbIdList = data.map((whiteboard) {
            return whiteboard['whiteboard_id'];
          }).toList();

          if (wbIdList.isEmpty) {
            ref.read(whiteBoardProvider.notifier).updateWhiteBoardList([]);
            return;
          }

          final res = await supabase
              .from('whiteboards')
              .select()
              .inFilter('whiteboard_id', wbIdList);

          final whiteboardsList = res.map((whiteboard) {
            // print('before return');
            return WhiteBoard(
              strokes: [],
              createdAt: DateTime.parse(whiteboard['created_at']),
              title: whiteboard['title'],
              id: whiteboard['whiteboard_id'].toString(),
              inviteKey: whiteboard['invite_key'].toString(),
            );
          }).toList();

          final allWb = await supabase.from('whiteboards').select('invite_key');
          setState(() {
            inviteKeyList = allWb.map(
              (whiteboard) {
                return whiteboard['invite_key'].toString();
              },
            ).toList();
          });

          // print('whiteboard list  done');
          ref
              .read(whiteBoardProvider.notifier)
              .updateWhiteBoardList(whiteboardsList);
        });
      }
    });
  }

  @override
  void dispose() {
    whiteboardSubsciption?.cancel();
    super.dispose();
  }

  int random() {
    int a = 100000 + Random().nextInt(1000000 - 100000);
    if (inviteKeyList.contains(a.toString())) {
      return random();
    }
    return a;
  }

  Widget addWhiteBoard() {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        height: 200.0,
        width: 180.0,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          // child: Container(
          // margin: EdgeInsets.all(20),
          // decoration: BoxDecoration(
          //   color: Colors.grey.shade100,
          //   border: Border.all(),
          //   borderRadius: BorderRadius.all(Radius.circular(8)),
          // ),
          // height: 200,
          // width: 180,
          child: Center(child: Icon(Icons.add_box_rounded)),
          // ),
          onTap: () async {
            final inviteKey = random();
            final response = await supabase
                .from('whiteboards')
                .insert({
                  'title': 'Untitled',
                  'created_at': DateTime.now().toIso8601String(),
                  'invite_key': inviteKey
                })
                .select()
                .single();

            final whiteboardId = response['whiteboard_id'].toString();

            await supabase.from('userswhiteboards').insert({
              'whiteboard_id': int.parse(whiteboardId),
              'user_id': supabase.auth.currentUser!.id
            });

            ref.read(whiteBoardProvider.notifier).addWhiteBoard(
                  WhiteBoard(
                    strokes: [],
                    createdAt: DateTime.parse(response['created_at']),
                    title: response['title'],
                    id: whiteboardId,
                    inviteKey: response['invite_key'].toString(),
                  ),
                );

            // final latestWhiteBoard = await supabase
            //     .from('whiteboards')
            //     .select()
            //     .order('created_at', ascending: false)
            //     .limit(1)
            //     .single();

            // String id = uuid.v4();
            // ref.read(whiteBoardProvider.notifier).addWhiteBoard(
            //       WhiteBoard(
            //         strokes: [],
            //         createdAt: DateTime.parse(latestWhiteBoard['created_at']),
            //         title: latestWhiteBoard['title'],
            //         id: latestWhiteBoard['whiteboard_id'].toString(),
            //       ),
            //     );

            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return DrawWhiteBoard(id: whiteboardId);
            }));
          },
        ),
      ),
    );
  }

  Widget savedWhiteBoards(WhiteBoard whiteboard) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        height: 200,
        width: 180,
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return DrawWhiteBoard(id: whiteboard.id);
        }));
      },
    );
  }

  Future<void> joinWhiteboard() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter WhiteBoard Id: "),
            content: Form(
              key: _form,
              child: Container(
                height: 60,
                // color: Colors.red,
                child: TextFormField(
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.length != 6 ||
                        !inviteKeyList.contains(value)) {
                      print(value);
                      print(inviteKeyList);
                      return 'Please enter a valid invite key';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    inviteKey = newValue!;
                  },
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!_form.currentState!.validate()) {
                    return;
                  }
                  _form.currentState!.save();

                  final wb = await supabase
                      .from('whiteboards')
                      .select()
                      .eq('invite_key', inviteKey)
                      .single();

                  //

                  final whiteboardId = wb['whiteboard_id'].toString();

                  await supabase.from('userswhiteboards').insert({
                    'whiteboard_id': int.parse(whiteboardId),
                    'user_id': supabase.auth.currentUser!.id
                  });

                  ref.read(whiteBoardProvider.notifier).addWhiteBoard(
                        WhiteBoard(
                          strokes: [],
                          createdAt: DateTime.parse(wb['created_at']),
                          title: wb['title'],
                          id: whiteboardId,
                          inviteKey: wb['invite_key'].toString(),
                        ),
                      );

                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return DrawWhiteBoard(id: whiteboardId);
                  }));
                },
                child: Text('Join'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // double currentSliderValue = ref.watch(strokeSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(supabase.auth.currentUser!.email ?? 'Home Screen'),
        centerTitle: true,
        actions: [
          ElevatedButton(
            onPressed: joinWhiteboard,
            child: Text('Join'),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: userWhiteboardsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active &&
                snapshot.hasData) {
              // final whiteboardsList = snapshot.data!.map((whiteboard) {
              //   return WhiteBoard(
              //       strokes: [],
              //       createdAt: DateTime.parse(whiteboard['created_at']),
              //       title: whiteboard['title'],
              //       id: whiteboard['whiteboard_id'].toString());
              // }).toList();
              // ref
              //     .read(whiteBoardProvider.notifier)
              //     .addWhiteBoardList(whiteboardsList);
              final whiteboards = ref.watch(whiteBoardProvider);
              return Container(
                padding: EdgeInsets.all(20),
                child: GridView.count(crossAxisCount: 2, children: [
                  addWhiteBoard(),
                  ...whiteboards.reversed
                      .map((e) => savedWhiteBoards(e))
                      .toList(),
                ]),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      // body: () {
      //   if (whiteboardsStream != null) {
      //     return Container(
      //       padding: EdgeInsets.all(20),
      //       child: GridView.count(crossAxisCount: 2, children: [
      //         addWhiteBoard(),
      //         ...whiteboards.reversed.map((e) => savedWhiteBoards(e)).toList(),
      //       ]),
      //     );
      //   } else {
      //     return Center(
      //       child: CircularProgressIndicator(),
      //     );
      //   }
      // }(),
    );
  }
}
