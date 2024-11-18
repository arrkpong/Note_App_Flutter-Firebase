//lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  String email = '';
  String password = '';

  final logger = Logger(); // สร้าง instance ของ Logger

  void _register() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      logger.i('User registered: ${userCredential.user!.uid}');
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      logger.e('Failed to register user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to register. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i('Building RegisterPage');
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Register')),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                logger.i('Register button pressed');
                _register();
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
