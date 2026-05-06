import 'dart:io';
import 'package:flutter/material.dart';
import 'package:proyecto_recetas/screens/configuracion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avataaars/avataaars.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proyecto_recetas/screens/edit_profile_screen.dart';
import 'package:proyecto_recetas/screens/auth_screen.dart';
import 'package:proyecto_recetas/screens/own_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var avatar = Avataaar.random();
  File? _pickedImage;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final picked = await Navigator.push<File?>(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );

              if (picked != null) {
                setState(() {
                  _pickedImage = picked;
                });
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            _pickedImage != null
                ? Image.file(
                    _pickedImage!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : SvgPicture.string(avatar.toSvg(), width: 200, height: 200),

            const SizedBox(height: 12),

            // Username
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text(
                    'Cargando...',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;

                final username =
                    (data?['username'] != null &&
                        (data?['username'] as String).isNotEmpty)
                    ? data!['username']
                    : 'Usuario sin nombre';

                return Text(
                  username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            Text(
              FirebaseAuth.instance.currentUser?.email ?? 'Sin correo',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Estadísticas dinámicas usando username
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  );
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                final username = userData?['username'];

                if (username == null) {
                  return const Text('Usuario no encontrado');
                }

                return FutureBuilder<QuerySnapshot>(
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
                );
              },
            ),

            const SizedBox(height: 20),

            // Fecha de nacimiento
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("Cargando fecha...");
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;

                if (data == null || data['birthday'] == null) {
                  return const Text(
                    "Fecha de nacimiento no configurada",
                    style: TextStyle(color: Colors.grey),
                  );
                }

                final Timestamp ts = data['birthday'];
                final DateTime date = ts.toDate();

                final formatted = "${date.day}/${date.month}/${date.year}";

                return Text(
                  "Fecha de nacimiento: $formatted",
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(),

            _OptionTile(
              icon: Icons.book,
              title: 'Mis recetas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OwnRecipesScreen(),
                  ),
                );
              },
            ),

            _OptionTile(
              icon: Icons.settings,
              title: 'Configuración',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppSettingsScreen(),
                  ),
                );
              },
            ),

            _OptionTile(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              onTap: () async {
                await FirebaseAuth.instance.signOut();

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthGate()),
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
