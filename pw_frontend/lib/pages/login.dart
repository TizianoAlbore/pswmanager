import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Chiave del form per la validazione
  final _formKey = GlobalKey<FormState>();

  // Controller per i campi di input email e password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Funzione di login che viene eseguita quando l'utente preme il pulsante di login
  void _login() {
    // Verifica se il form è valido
    if (_formKey.currentState?.validate() ?? false) {
      // Se valido, naviga alla pagina dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  // Funzione per navigare alla pagina di registrazione
  void _navigateToSignup() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Titolo della barra in alto
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // Associa la chiave al form
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo di testo per l'email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                // Validatore per verificare che l'email sia inserita correttamente
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insert an email';
                  }
                  // Verifica se l'email ha un formato valido
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Insert a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), // Spazio tra i campi

              // Campo di testo per la password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true, // Nasconde il testo per la privacy
                // Validatore per la password
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insert password';
                  }
                  // Controlla che la password sia di almeno 6 caratteri
                  if (value.length < 6) {
                    return 'Password should be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24), // Spazio tra i campi e il bottone

              // Pulsante di login
              ElevatedButton(
                onPressed: _login, // Chiamata alla funzione di login
                child: Text('Submit'),
              ),

              SizedBox(height: 16), // Spazio tra i pulsanti

              // Pulsante per navigare alla pagina di registrazione
              TextButton(
                onPressed: _navigateToSignup, // Chiamata alla funzione di navigazione a signup
                child: Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Libera le risorse dei controller quando il widget viene rimosso
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}