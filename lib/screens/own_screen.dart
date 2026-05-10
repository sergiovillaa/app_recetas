import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_recetas/models/recipe.dart';
import 'package:proyecto_recetas/screens/recipe_screen.dart';
import 'package:proyecto_recetas/screens/edit_recipe_screen.dart';

class OwnRecipesScreen extends StatefulWidget {
  const OwnRecipesScreen({super.key});

  @override
  State<OwnRecipesScreen> createState() => _OwnRecipesScreenState();
}

class _OwnRecipesScreenState extends State<OwnRecipesScreen> {
  late final Future<String?> _authorFuture;

  @override
  void initState() {
    super.initState();
    _authorFuture = _loadAuthor();
  }

  Future<String?> _loadAuthor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = userDoc.data();
    final username = data?['username'];

    if (username is String && username.trim().isNotEmpty) {
      return username.trim();
    }

    return 'Anonimo';
  }

  void _handleLike(String recipeId) {
    FirebaseFirestore.instance.collection('recipes').doc(recipeId).update({
      'likes': FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis recetas')),
      body: FutureBuilder<String?>(
        future: _authorFuture,
        builder: (context, authorSnapshot) {
          if (authorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authorSnapshot.hasError) {
            return Center(child: Text('Error: ${authorSnapshot.error}'));
          }

          final author = authorSnapshot.data;
          if (author == null) {
            return const Center(
              child: Text('Debes iniciar sesion para ver tus recetas.'),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('recipes')
                .where('author', isEqualTo: author)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(child: Text('No has publicado recetas.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final recipe = Recipe.fromJson(data, doc.id);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(recipe.title),
                      subtitle: Text('${recipe.type}  -  ${recipe.author}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _handleLike(recipe.id),
                            icon: const Icon(Icons.thumb_up_outlined),
                          ),
                          Text('${recipe.likes}'),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditRecipeScreen(recipeId: recipe.id),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar receta'),
                                  content: const Text(
                                    'Estas seguro de que deseas eliminar esta receta?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('recipes')
                                    .doc(recipe.id)
                                    .delete();
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailScreen(recipeId: recipe.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
