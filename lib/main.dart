import 'package:flutter/material.dart';
import 'package:units/Pages/Auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  // Make sure this import is correct

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);  // Fix the constructor syntax here

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}

