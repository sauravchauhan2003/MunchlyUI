import 'package:flutter/material.dart';
import 'package:munchly/logic/Routes.dart';
import 'package:munchly/pages/HomeScreen.dart';
import 'package:munchly/pages/LoadingScreen.dart';
import 'package:munchly/pages/LoginScreen.dart';
import 'package:munchly/pages/SignUpScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for plugins like SharedPreferences
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(),
      routes: {
        Routes.LoadingScreen: (_) => LoadingScreen(),
        Routes.LoginScreen: (_) => LoginScreen(),
        Routes.SignUpPage: (_) => SignUpScreen(),
        Routes.HomeScreen: (_) => HomeScreen(),
      },
    );
  }
}
