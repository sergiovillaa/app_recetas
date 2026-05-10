import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditRecipeScreen extends StatefulWidget {
  final String recipeId;

  const EditRecipeScreen({super.key, required this.recipeId});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  String _type = 'Desayuno';
  String _difficulty = 'Facil';

  bool _isVegan = false;
  bool _isVegetarian = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  List<TextEditingController> _ingredients = [];
  List<TextEditingController> _steps = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _imageController.dispose();
    for (final controller in _ingredients) {
      controller.dispose();
    }
    for (final controller in _steps) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadRecipe() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .get();
      if (!doc.exists) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La receta no existe')),
        );
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        _nameController.text = (data['title'] ?? '').toString();
        _descriptionController.text = (data['description'] ?? '').toString();

        final typeVal = data['type'];
        if (['Desayuno', 'Comida', 'Cena', 'Postre', 'Snack'].contains(typeVal)) {
          _type = typeVal;
        } else {
          _type = 'Desayuno';
        }

        final difficultyVal = data['difficulty'];
        if (['Facil', 'Media', 'Dificil', 'Fácil', 'Difícil'].contains(difficultyVal)) {
          _difficulty = difficultyVal == 'Fácil'
              ? 'Facil'
              : difficultyVal == 'Difícil'
                  ? 'Dificil'
                  : difficultyVal;
        } else {
          _difficulty = 'Facil';
        }

        _durationController.text = data['duration']?.toString() ?? '';
        _imageController.text = (data['image'] ?? '').toString();
        _isVegan = data['isVegan'] ?? false;
        _isVegetarian = data['isVegetarian'] ?? false;

        final ingredients = data['ingredients'];
        if (ingredients is List) {
          _ingredients = ingredients
              .map((e) => TextEditingController(text: e.toString()))
              .toList();
        }
        if (_ingredients.isEmpty) {
          _ingredients.add(TextEditingController());
        }

        final steps = data['steps'];
        if (steps is List) {
          _steps = steps
              .map((e) => TextEditingController(text: e.toString()))
              .toList();
        }
        if (_steps.isEmpty) {
          _steps.add(TextEditingController());
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar la receta: $e')),
      );
    }
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

    final recipeUpdate = {
      'title': _nameController.text,
      'description': _descriptionController.text,
      'type': _type,
      'difficulty': _difficulty,
      'duration': _durationController.text,
      'isVegan': _isVegan,
      'isVegetarian': _isVegetarian,
      'image': _imageController.text,
      'ingredients': _ingredients
          .map((e) => e.text)
          .where((e) => e.isNotEmpty)
          .toList(),
      'steps': _steps.map((e) => e.text).where((e) => e.isNotEmpty).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .update(recipeUpdate);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receta actualizada exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar receta')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar receta')),
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
              decoration: const InputDecoration(labelText: 'Descripcion'),
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
                DropdownMenuItem(value: 'Facil', child: Text('Facil')),
                DropdownMenuItem(value: 'Media', child: Text('Media')),
                DropdownMenuItem(value: 'Dificil', child: Text('Dificil')),
              ],
              onChanged: (value) => setState(() => _difficulty = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duracion (minutos)',
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
            const Text(
              'Ingredientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._ingredients.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        decoration:
                            const InputDecoration(labelText: 'Ingrediente'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _ingredients.removeAt(i);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            TextButton(
              onPressed: _addIngredient,
              child: const Text('+ Agregar ingrediente'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pasos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._steps.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        decoration:
                            InputDecoration(labelText: 'Paso ${i + 1}'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _steps.removeAt(i);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            TextButton(
              onPressed: _addStep,
              child: const Text('+ Agregar paso'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Guardar cambios', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
