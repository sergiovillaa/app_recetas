import 'package:flutter/material.dart';
import 'package:proyecto_recetas/models/recipe.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  final List<Recipe> favorites;
  final void Function(Recipe recipe) onToggleFavorite;
  final bool Function(Recipe recipe) isFavorite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text('Aun no tienes recetas favoritas'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final recipe = favorites[index];
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
