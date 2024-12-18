import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pw_frontend/widgets/passphrase.dart';
import '../utils/user_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  bool _isPasswordVisible = false;

  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await addUser(userCredential, _firestore, _emailController);
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.toString()}')),
      );
    }
  }

  void _openPassphraseDialog() {
    showDialog(
      context: context,
      builder: (context) => PassphraseWidget(
        onSelected: (selectedWords) {
          setState(() {
            _passwordController.text = selectedWords;
            _confirmPasswordController.text = selectedWords;
          });
        },
      ),
    );
  }

  Future<void> _githubSignup() async {
    try {
      // Usa signInWithPopup per Flutter Web
      final GithubAuthProvider githubProvider = GithubAuthProvider();
      UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(githubProvider);

      // Recupera l'email dell'utente
      String email = userCredential.user?.email ?? 'No email available';

      // Aggiungi l'utente al database Firestore
      await addUser(userCredential, _firestore, TextEditingController(text: email));

      // Naviga al dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      print('GitHub signup failed: $e');
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
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), // Raggio di arrotondamento
              border: Border.all(color: Colors.grey, width: 1), // Bordo opzionale
            ), 
            child: SizedBox(
              width: 370,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.lightbulb_outline),
                              onPressed: _openPassphraseDialog,
                            ),
                          ],
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: !_isPasswordVisible,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00796B)),
                      child: const Text(
                        'Sign Up with Email',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 0), // Padding personalizzato
                          ),
                          onPressed: () {
                            _googleSignIn.signIn();
                          },
                          child: SvgPicture.asset(
                            'assets/google.svg',
                            height: 20,
                            width: 20
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 0), // Padding personalizzato
                          ),
                          onPressed: () {
                            _githubSignup();
                          },
                          child: SvgPicture.asset(
                            'assets/github.svg',
                            height: 20,
                            width: 20
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20), // Padding personalizzato
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Already have an account? Login'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
