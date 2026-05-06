import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  String _type = 'Desayuno';
  String _difficulty = 'Fácil';

  bool _isVegan = false;
  bool _isVegetarian = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  List<TextEditingController> _ingredients = [];
  List<TextEditingController> _steps = [];

  @override
  void initState() {
    super.initState();
    _ingredients.add(TextEditingController());
    _steps.add(TextEditingController());
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(TextEditingController());
    });
  }

  void _addStep() {
    setState(() {
      _steps.add(TextEditingController());
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final authorName = userDoc.data()?['username'] ?? 'Anónimo';

    final recipe = {
      "title": _nameController.text,
      "description": _descriptionController.text,
      "type": _type,
      "difficulty": _difficulty,
      "duration": _durationController.text,
      "isVegan": _isVegan,
      "isVegetarian": _isVegetarian,
      "image": _imageController.text,
      "ingredients": _ingredients.map((e) => e.text).toList(),
      "steps": _steps.map((e) => e.text).toList(),
      "author": authorName,
      "likes": 0,
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('recipes').add(recipe);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receta guardada exitosamente')),
      );

      // Limpiar formulario
      _formKey.currentState!.reset();
      _nameController.clear();
      _descriptionController.clear();
      _durationController.clear();
      _imageController.clear();
      setState(() {
        _isVegan = false;
        _isVegetarian = false;
        _ingredients = [TextEditingController()];
        _steps = [TextEditingController()];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear receta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: const [
                DropdownMenuItem(value: 'Desayuno', child: Text('Desayuno')),
                DropdownMenuItem(value: 'Comida', child: Text('Comida')),
                DropdownMenuItem(value: 'Cena', child: Text('Cena')),
                DropdownMenuItem(value: 'Postre', child: Text('Postre')),
                DropdownMenuItem(value: 'Snack', child: Text('Snack')),
              ],
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: const InputDecoration(labelText: 'Dificultad'),
              items: const [
                DropdownMenuItem(value: 'Fácil', child: Text('Fácil')),
                DropdownMenuItem(value: 'Media', child: Text('Media')),
                DropdownMenuItem(value: 'Difícil', child: Text('Difícil')),
              ],
              onChanged: (value) => setState(() => _difficulty = value!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duración (minutos)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'URL de imagen'),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Vegano'),
              value: _isVegan,
              onChanged: (value) {
                setState(() {
                  _isVegan = value;
                  if (_isVegan) _isVegetarian = true;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Vegetariano'),
              value: _isVegetarian,
              onChanged: (value) {
                setState(() {
                  _isVegetarian = value;
                  if (!_isVegetarian) _isVegan = false;
                });
              },
            ),

            const SizedBox(height: 24),
            const Text('Ingredientes', style: TextStyle(fontSize: 18)),

            ..._ingredients.map(
              (controller) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Ingrediente'),
                ),
              ),
            ),

            TextButton(
              onPressed: _addIngredient,
              child: const Text('+ Agregar ingrediente'),
            ),

            const SizedBox(height: 24),
            const Text('Pasos', style: TextStyle(fontSize: 18)),

            ..._steps.asMap().entries.map((entry) {
              int i = entry.key;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  controller: entry.value,
                  decoration: InputDecoration(labelText: 'Paso ${i + 1}'),
                ),
              );
            }),

            TextButton(
              onPressed: _addStep,
              child: const Text('+ Agregar paso'),
            ),

            const SizedBox(height: 24),

            FilledButton(onPressed: _submit, child: const Text('Publicar')),
          ],
        ),
      ),
    );
  }
}
