import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avataaars/avataaars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

final TextEditingController _usernameController = TextEditingController();
DateTime selectedDate = DateTime.now();
final uid = FirebaseAuth.instance.currentUser!.uid;

class _EditProfileScreenState extends State<EditProfileScreen> {
  var avatar = Avataaar.random();
  File? _pickedImage;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Editar perfil')));
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
            ElevatedButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );

                if (image != null) {
                  setState(() {
                    _pickedImage = File(image.path);
                  });
                }
              },
              child: const Text("Seleccionar imagen"),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     setState(() {
            //       avatar = Avataaar.random();
            //     });
            //   },
            //   child: Text("Generar"),
            // ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Nombre de usuario",
                  border: OutlineInputBorder(),
                ),
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
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({
                      "username": _usernameController.text.isNotEmpty
                          ? _usernameController.text
                          : null,
                      "birthday": Timestamp.fromDate(selectedDate),
                    });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil actualizado')),
                );
                Navigator.pop(
                  context,
                  _pickedImage,
                ); // cerrar pantalla después de guardar
              },
              child: const Text("Guardar cambios"),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}

Future<void> load() async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  if (doc.exists) {
    final data = doc.data()!;
    _usernameController.text = data['username'] ?? '';
    selectedDate = (data['birthday'] as Timestamp?)?.toDate() ?? DateTime.now();
  }
}
