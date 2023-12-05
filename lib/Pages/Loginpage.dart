import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:units/components/My_button.dart';
import 'package:units/components/My_textfield.dart';

class Loginpage extends StatelessWidget {
  Loginpage({Key? key}) : super(key: key);

// Define TextEditingController for email and password input fields
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

// Asynchronous funct ion to sign in the user // username and password
  Future<void> signUserIn(BuildContext context) async {
    try {
      // Use FirebaseAuth instance to sign in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Handle successful login
      // Navigate to the home screen after successful login
      Navigator.pushReplacementNamed
        (context, '/home');
    } catch (e) {
      // Handle errors that may occur during the sign-in process
      print('Error signing in: $e');

      // Show error message to the user using a SnackBar or another method
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in. Check your credentials.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
// google function for sign in implemented at  line 153
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      print("Starting Google Sign-In process...");

      final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
      if (googleSignInAccount != null) {
        print("Google Sign-In successful for ${googleSignInAccount.email}");

        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        print("Signing in with Firebase credential...");

        await FirebaseAuth.instance.signInWithCredential(credential);

        print("Firebase Sign-In successful");

        // Handle successful Google Sign-In
        print("Navigating to home screen...");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('Google Sign-In canceled');
      }
    } catch (e) {
      print('Error signing in with Google: $e');

      // Show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing in with Google. Please try again.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 60,
                  child: CircleAvatar(
                    backgroundColor: Colors.lightBlueAccent,
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/logo_sweet_dreams.jpg'),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Welcome to Sweet Dreams!',
                  style: TextStyle(
                    color: Color(0xFF616161),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 50),
                MyTextField(
                  controller: emailController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                SizedBox(height: 16),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue[300]),
                    ),
                  ],
                ),
                MyButton(onTap: () => signUserIn(context)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          " or go with",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () => signInWithGoogle(context),
                  child: Text('Login with Google'),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}