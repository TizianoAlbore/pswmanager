import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/user_utils.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1067949980182-26n01pdsdfca41kip46kcudm5cbka91j.apps.googleusercontent.com',
  );

  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      // Crea l'utente in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Aggiungi l'utente al database Firestore
      await addUser(userCredential, _firestore, _emailController);

      // Naviga al dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _googleSignup() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(credential);

        // Aggiungi l'utente al database Firestore
        await addUser(userCredential, _firestore, TextEditingController(text: googleUser.email));

        // Naviga al dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google signup failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _githubSignup() async {
    try {
      final githubProvider = GithubAuthProvider();
      UserCredential userCredential = await _auth.signInWithProvider(githubProvider);

      // Recupera i dettagli dell'utente GitHub
      String email = userCredential.user?.email ?? 'No email available';

      // Aggiungi l'utente al database Firestore
      await addUser(userCredential, _firestore, TextEditingController(text: email));

      // Naviga al dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GitHub signup failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView( // Aggiungi questo widget per permettere lo scrolling
          child: SizedBox(
            width: 300, // Limita la larghezza del form
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0), // Padding verticale
              child: Column(
                mainAxisSize: MainAxisSize.min, // Minimizza lo spazio occupato verticalmente
                crossAxisAlignment: CrossAxisAlignment.stretch, // Allinea gli elementi
                children: [
                  const Text(
                    'Signup',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center, // Allinea il titolo al centro
                  ),
                  const SizedBox(height: 20), // Spazio
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signup,
                    child: const Text('Sign Up with Email'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _googleSignup,
                    child: const Text('Sign Up with Google'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _githubSignup,
                    child: const Text('Sign Up with GitHub'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

