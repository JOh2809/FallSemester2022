import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:units/Pages/Loginpage.dart';
import 'package:units/Pages/home_page.dart';




class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for auth state, you can show a loading indicator.
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            // User is logged in
            return HomePage();
          } else {
            // User is not logged in
            return Loginpage();
          }
        },
      ),
    );
  }
}