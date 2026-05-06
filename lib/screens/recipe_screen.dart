import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de receta')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .doc(recipeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Receta no encontrada'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Imagen destacada
              if (data['image'] != null && (data['image'] as String).isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    data['image'],
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 16),
              Text(
                data['title'] ?? 'Sin título',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                "Autor: ${data['author'] ?? 'Anónimo'}",
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text("Tipo: ${data['type'] ?? ''}")),
                  Chip(label: Text("Dificultad: ${data['difficulty'] ?? ''}")),
                  Chip(label: Text("Duración: ${data['duration'] ?? ''} min")),
                  if (data['isVegan'] == true)
                    const Chip(label: Text("Vegano")),
                  if (data['isVegetarian'] == true)
                    const Chip(label: Text("Vegetariano")),
                ],
              ),

              const Divider(height: 32),

              Text(
                "Descripción",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                data['description'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const Divider(height: 32),

              Text(
                "Ingredientes",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...(data['ingredients'] as List<dynamic>? ?? []).map(
                (ing) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      ing,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),

              const Divider(height: 32),

              Text("Pasos", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...(data['steps'] as List<dynamic>? ?? []).asMap().entries.map(
                (entry) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(child: Text("${entry.key + 1}")),
                    title: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
