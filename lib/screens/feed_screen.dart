import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_recetas/models/recipe.dart';
import 'package:proyecto_recetas/screens/recipe_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  final void Function(Recipe recipe) onToggleFavorite;
  final bool Function(Recipe recipe) isFavorite;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String searchQuery = '';

  void _handleLike(String recipeId) {
    FirebaseFirestore.instance.collection('recipes').doc(recipeId).update({
      'likes': FieldValue.increment(1),
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchBar(
              hintText: 'Buscar receta o categoría...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('recipes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];

                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final title = (data['title'] ?? '').toString().toLowerCase();

                  final type = (data['type'] ?? '').toString().toLowerCase();

                  return title.contains(searchQuery) ||
                      type.contains(searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron recetas.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final recipe = Recipe.fromJson(data, doc.id);
                      final isFav = widget.isFavorite(recipe);

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
                              IconButton(
                                onPressed: () =>
                                    widget.onToggleFavorite(recipe),
                                icon: Icon(
                                  isFav ? Icons.star : Icons.star_border,
                                ),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
