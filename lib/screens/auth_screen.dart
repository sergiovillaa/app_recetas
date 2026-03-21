import 'package:flutter/material.dart';
import 'package:proyecto_recetas/screens/signup_screen.dart';
import 'package:proyecto_recetas/screens/tabs.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  void _goToApp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TabsScreen()),
    );
  }

  void _goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Correo',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contrasena',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _goToApp(context),
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _goToSignup(context),
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
