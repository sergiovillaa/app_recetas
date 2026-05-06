import 'package:flutter/material.dart';
import 'package:proyecto_recetas/models/recipe.dart';
import 'package:proyecto_recetas/screens/create_recipe_screen.dart';
import 'package:proyecto_recetas/screens/favorites_screen.dart';
import 'package:proyecto_recetas/screens/feed_screen.dart';
import 'package:proyecto_recetas/screens/leaderboard_screen.dart';
import 'package:proyecto_recetas/screens/profile_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int currentPageIndex = 0;
  final List<Recipe> _favoriteRecipes = [];

  void _toggleRecipeFavorite(Recipe recipe) {
    final isExistingFavorite = _favoriteRecipes.indexWhere((r) => r.id == recipe.id) != -1;

    setState(() {
      if (isExistingFavorite) {
        _favoriteRecipes.removeWhere((r) => r.id == recipe.id);
      } else {
        _favoriteRecipes.add(recipe);
      }
    });
  }

  bool _isRecipeFavorite(Recipe recipe) {
    return _favoriteRecipes.any((r) => r.id == recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        FeedScreen(
          onToggleFavorite: _toggleRecipeFavorite,
          isFavorite: _isRecipeFavorite,
        ),
        const CreateRecipeScreen(),
        FavoritesScreen(
          favorites: _favoriteRecipes,
          onToggleFavorite: _toggleRecipeFavorite,
          isFavorite: _isRecipeFavorite,
        ),
        const LeaderboardScreen(),
        const ProfileScreen(),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.rss_feed),
            icon: Icon(Icons.rss_feed_outlined),
            label: 'Feed',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.add_circle),
            icon: Icon(Icons.add_circle_outline),
            label: 'Crear',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.star),
            icon: Icon(Icons.star_border),
            label: 'Favoritos',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.emoji_events),
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Ranking',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
