import 'package:flutter/material.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  String _type = 'Desayuno';
  bool _isVegan = false;
  bool _isVegetarian = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear receta'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Nombre de la receta',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(
              labelText: 'Tipo de comida',
            ),
            items: const [
              DropdownMenuItem(value: 'Desayuno', child: Text('Desayuno')),
              DropdownMenuItem(value: 'Comida', child: Text('Comida')),
              DropdownMenuItem(value: 'Cena', child: Text('Cena')),
              DropdownMenuItem(value: 'Postre', child: Text('Postre')),
              DropdownMenuItem(value: 'Snack', child: Text('Snack')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _type = value;
              });
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Vegano'),
            value: _isVegan,
            onChanged: (value) {
              setState(() {
                _isVegan = value;
                if (_isVegan) {
                  _isVegetarian = true;
                }
              });
            },
          ),
          SwitchListTile(
            title: const Text('Vegetariano'),
            value: _isVegetarian,
            onChanged: (value) {
              setState(() {
                _isVegetarian = value;
                if (!_isVegetarian) {
                  _isVegan = false;
                }
              });
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receta guardada')),
              );
            },
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }
}
