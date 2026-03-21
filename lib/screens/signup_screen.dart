import 'package:flutter/material.dart';
import 'package:proyecto_recetas/screens/tabs.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  void _goToApp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TabsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nombre de usuario',
              ),
            ),
            const SizedBox(height: 16),
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
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
