import 'package:flutter/material.dart';
import 'package:proyecto_recetas/models/recipe.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({
    super.key,
    required this.recipes,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  final List<Recipe> recipes;
  final void Function(Recipe recipe) onToggleFavorite;
  final bool Function(Recipe recipe) isFavorite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          final isFav = isFavorite(recipe);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(recipe.title),
              subtitle: Text('${recipe.type}  •  ${recipe.author}'),
              trailing: IconButton(
                onPressed: () => onToggleFavorite(recipe),
                icon: Icon(isFav ? Icons.star : Icons.star_border),
              ),
            ),
          );
        },
      ),
    );
  }
}
