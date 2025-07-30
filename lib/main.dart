import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_collaborative_whiteboard/screens/home.dart';
import 'package:realtime_collaborative_whiteboard/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    ProviderScope(
      child: MainApp(),
    ),
  );
}

final supabase = Supabase.instance.client;
var uuid = Uuid();

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _MainAppView(),
    );
  }
}

class _MainAppView extends StatefulWidget {
  const _MainAppView({
    super.key,
  });

  @override
  State<_MainAppView> createState() => _MainAppViewState();
}

class _MainAppViewState extends State<_MainAppView> {
  StreamSubscription? authSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authSubscription = supabase.auth.onAuthStateChange.listen(
        (data) {
          final AuthChangeEvent event = data.event;
          final Session? session = data.session;

          print('event: $event, session: $session');

          switch (event) {
            case AuthChangeEvent.initialSession:
              // handle initial session
              return;

            case AuthChangeEvent.signedIn:
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) {
                return HomeScreen();
              }));
            // handle signed in
            case AuthChangeEvent.signedOut:
            // handle signed out
            case AuthChangeEvent.passwordRecovery:
            // handle password recovery
            case AuthChangeEvent.tokenRefreshed:
            // handle token refreshed
            case AuthChangeEvent.userUpdated:
            // handle user updated
            case AuthChangeEvent.userDeleted:
            // handle user deleted
            case AuthChangeEvent.mfaChallengeVerified:
            // handle mfa challenge verified
          }
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    authSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen();
  }
}
