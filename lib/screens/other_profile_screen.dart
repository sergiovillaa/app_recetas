import 'dart:io';
import 'package:flutter/material.dart';
import 'package:proyecto_recetas/screens/configuracion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avataaars/avataaars.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proyecto_recetas/screens/auth_screen.dart';
import 'package:proyecto_recetas/screens/own_screen.dart';

class OtherProfileScreen extends StatefulWidget {
  final String authorId;
  const OtherProfileScreen({super.key, required this.authorId});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  var avatar = Avataaar.random();
  File? _pickedImage;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: () async {

        //     },
        //   ),
        // ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Username
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('username', isEqualTo: widget.authorId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text(
                    'Cargando...',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  );
                }
                final userDoc = snapshot.data!.docs.first;
                final data = userDoc.data() as Map<String, dynamic>;
                //final data = snapshot.data!.data() as Map<String, dynamic>?;

                final username =
                    (data['username'] != null &&
                        (data['username'] as String).isNotEmpty)
                    ? data['username']
                    : 'Usuario sin nombre';
                final email =
                    (data['email'] != null &&
                        (data['email'] as String).isNotEmpty)
                    ? data['email']
                    : 'Usuario sin email';
                final Timestamp ts = data['birthday'];
                final DateTime date = ts.toDate();
                final formatted = "${date.day}/${date.month}/${date.year}";
                final avatarSvg = data['avatarSVG'];
                var avatar = (avatarSvg is String && avatarSvg.isNotEmpty)
                    ? avatarSvg
                    : Avataaar.random().toSvg();
                return Column(
                  children: [
                    _pickedImage != null
                        ? Image.file(
                            _pickedImage!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : SvgPicture.string(avatar, width: 200, height: 200),

                    const SizedBox(height: 12),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(email, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('recipes')
                          .where('author', isEqualTo: username)
                          .get(),
                      builder: (context, recipeSnapshot) {
                        if (!recipeSnapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs = recipeSnapshot.data!.docs;
                        final totalRecipes = docs.length;

                        int totalLikes = 0;

                        for (var doc in docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          totalLikes += (data['likes'] ?? 0) as int;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                title: 'Recetas',
                                value: totalRecipes.toString(),
                              ),
                              _StatItem(
                                title: 'Likes',
                                value: totalLikes.toString(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Fecha de nacimiento: $formatted",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(),

            _OptionTile(
              icon: Icons.book,
              title: 'Sus recetas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OwnRecipesScreen(authorId: widget.authorId),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(title),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
