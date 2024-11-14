import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Chiave del form per la validazione
  final _formKey = GlobalKey<FormState>();

  // Controller per i campi di input nome, email e password
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Funzione di registrazione che viene eseguita quando l'utente preme il pulsante di registrazione
  void _signup() {
    // Verifica se il form è valido
    if (_formKey.currentState?.validate() ?? false) {
      // Se valido, naviga alla pagina dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  // Funzione per navigare alla pagina di login
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Titolo della barra in alto
        title: Text('Sign up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // Associa la chiave al form
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo di testo per il nome
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
                keyboardType: TextInputType.name,
                // Validatore per verificare che il nome sia inserito
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci il tuo nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16), // Spazio tra i campi

              // Campo di testo per l'email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                // Validatore per verificare che l'email sia inserita correttamente
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un\'email';
                  }
                  // Verifica se l'email ha un formato valido
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Inserisci un\'email valida';
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
                    return 'Inserisci una password';
                  }
                  // Controlla che la password sia di almeno 6 caratteri
                  if (value.length < 6) {
                    return 'La password deve essere di almeno 6 caratteri';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24), // Spazio tra i campi e il bottone

              // Pulsante di registrazione
              ElevatedButton(
                onPressed: _signup, // Chiamata alla funzione di registrazione
                child: Text('Submit'),
              ),

              SizedBox(height: 16), // Spazio tra i pulsanti

              // Pulsante per navigare alla pagina di login
              TextButton(
                onPressed: _navigateToLogin, // Chiamata alla funzione di navigazione a login
                child: Text('Already have an account? Login'),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}