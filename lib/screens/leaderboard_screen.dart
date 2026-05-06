import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_recetas/models/recipe.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Future<void> _refresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ranking'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Top Recetas', icon: Icon(Icons.food_bank)),
              Tab(text: 'Top Autores', icon: Icon(Icons.people)),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(child: Text('No hay recetas publicadas.'));
            }

            final recipes = docs.map((doc) {
              return Recipe.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();

            // Ordenar recetas por likes
            final topRecipes = List<Recipe>.from(recipes)
              ..sort((a, b) => b.likes.compareTo(a.likes));

            // Calcular likes por autor
            final Map<String, int> authorLikes = {};
            for (var recipe in recipes) {
              authorLikes[recipe.author] =
                  (authorLikes[recipe.author] ?? 0) + recipe.likes;
            }

            final topAuthors = authorLikes.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return TabBarView(
              children: [
                // TAB 1: Top Recetas
                RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: topRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = topRecipes[index];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text('#${index + 1}')),
                          title: Text(recipe.title),
                          subtitle: Text('Autor: ${recipe.author}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.thumb_up,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.likes}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // TAB 2: Top Autores
                RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: topAuthors.length,
                    itemBuilder: (context, index) {
                      final author = topAuthors[index];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber,
                            child: Text('#${index + 1}'),
                          ),
                          title: Text(author.key),
                          subtitle: const Text('Likes Totales'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.favorite,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${author.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
