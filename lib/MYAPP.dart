import 'package:flutter/material.dart';
import 'package:units/Pages/Auth_page.dart';
import 'package:units/Pages/Loginpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  // Make sure this import is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Corrected typo here
  );
  runApp(MYAPP());
}

class MYAPP extends StatelessWidget {
   const MYAPP ({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}


