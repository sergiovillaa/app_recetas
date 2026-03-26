import 'package:flutter/material.dart';
import 'package:proyecto_recetas/screens/configuracion.dart'; 
import 'package:avataaars/avataaars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';// ajusta la ruta si es necesario


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var avatar = Avataaar.random();
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Editar perfil')),
              );
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 20),
            SvgPicture.string(avatar.toSvg(), width: 200, height: 200),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  avatar = Avataaar.random();
                });
              },
              child: Text("Generar"),
            ),
            const SizedBox(height: 12),
            const Text(
              'Carlos Eduardo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const Text(
              'carlos@email.com',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _StatItem(title: 'Recetas', value: '24'),
                  _StatItem(title: 'likes', value: '180'),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text("FECHA DE NACIMIENTO:"),
            SizedBox(
              height: 250,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selectedDate,
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    selectedDate = newDate;
                  });
                },
              ),
            ),



            const SizedBox(height: 20),
            const Divider(),


            _OptionTile(
              icon: Icons.book,
              title: 'Mis recetas',
              onTap: () {},
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
              onTap: () {},
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

  const _StatItem({
    required this.title,
    required this.value,
  });

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