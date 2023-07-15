import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app/screen/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:group_chat_app/screen/chart.dart';
import 'package:group_chat_app/screen/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // screen ma stuck on emulator while using firebase. SO, to avoid this we must use this code
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // For initialization of firebase

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'FlutterChat',
        theme: ThemeData().copyWith(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 63, 17, 177)),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            if (snapshot.hasData) {
              return const Chart();
            }
            return const AuthScreen();
          },
        ));
  }
}
