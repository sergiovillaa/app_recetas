import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_recetas/models/recipe.dart';
import 'package:proyecto_recetas/screens/recipe_screen.dart';

final uid = FirebaseAuth.instance.currentUser!.uid;
var autor;

class OwnRecipesScreen extends StatelessWidget {
  const OwnRecipesScreen({super.key});

  void _handleLike(String recipeId) {
    FirebaseFirestore.instance.collection('recipes').doc(recipeId).update({
      'likes': FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    loadUser();
    return Scaffold(
      appBar: AppBar(title: const Text('Mis recetas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .where('author', isEqualTo: autor)
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
                  subtitle: Text('${recipe.type}     ${recipe.author}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _handleLike(recipe.id),
                        icon: const Icon(Icons.thumb_up_outlined),
                      ),
                      Text('${recipe.likes}'),
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
      ),
    );
  }
}

Future<void> loadUser() async {
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  autor = userDoc.data()?['username'] ?? 'Anónimo';
}
