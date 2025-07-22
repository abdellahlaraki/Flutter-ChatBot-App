import 'package:demo_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbService = DatabaseService();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final user = await _dbService.login(_emailController.text, _passwordController.text);
      if (mounted) { 
        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email ou mot de passe incorrect.')),
          );
        }
      }
    }
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      final newUser = User(email: _emailController.text, password: _passwordController.text);
      final result = await _dbService.signUp(newUser);
      if (mounted) {
        if (result != -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inscription réussie ! Veuillez vous connecter.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cet email est déjà utilisé.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ChatBot App', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer un email' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer un mot de passe' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Connexion'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _signUp,
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Inscription'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}