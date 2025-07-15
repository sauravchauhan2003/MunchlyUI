import 'package:flutter/material.dart';
import 'package:munchly/logic/Routes.dart';
import 'package:munchly/pages/ForgetPassword.dart';
import 'package:munchly/pages/LoginScreen.dart';
import 'package:munchly/pages/SignUpScreen.dart';
import 'package:munchly/pages/VerificationPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      routes: {
        Routes.LoginScreen: (_) => LoginScreen(),
        Routes.SignUpPage: (_) => SignUpScreen(),
        Routes.ForgotPassword: (_) => ForgotPasswordScreen(),
        Routes.VerificationPage: (_) => VerificationScreen(),
      },
    );
  }
}
