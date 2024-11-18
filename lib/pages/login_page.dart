//lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';

  final logger = Logger(); // สร้าง instance ของ Logger

  void _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.i('User logged in: ${userCredential.user!.uid}');
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      logger.e('Failed to login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect email or password.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i('Building LoginPage');
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Login')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                email = value;
                logger.i('Email changed: $email');
              },
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              onChanged: (value) {
                password = value;
                logger.i('Password changed: $password');
              },
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                logger.i('Login button pressed');
                _login();
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 2),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/reset_password');
              },
              child: const Text('Forgot Password?'),
            ),
            const SizedBox(height: 2),
            TextButton(
              onPressed: () {
                logger.i('Create an Account button pressed');
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Create an Account'),
            ),
          ],
        ),
      ),
    );
  }
}
