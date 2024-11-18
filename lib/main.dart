//lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/reset_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await Firebase.initializeApp();
    logger.i('Firebase initialized successfully');
    runApp(const MyApp());
  } catch (error) {
    //debugPrint('Failed to initialize Firebase: $error');
    logger.e('Failed to initialize Firebase: $error');
  }
}

final logger = Logger();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    logger.i('Building MyApp');
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Kanit',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) {
          logger.i('Navigating to LoginPage');
          return const LoginPage();
        },
        '/register': (context) {
          logger.i('Navigating to RegisterPage');
          return const RegisterPage();
        },
        '/home': (context) {
          logger.i('Navigating to MyHomePage');
          return const MyHomePage();
        },
        '/reset_password': (context) {
          logger.i('Navigating to ResetPasswordPage');
          return const ResetPasswordPage();
        },
      },
    );
  }
}
