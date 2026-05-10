import 'dart:io';

import 'package:avataaars/avataaars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _pickedImage;
  var _avatar = Avataaar.random().toSvg();

  String? _uid;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _load();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!mounted) {
      return;
    }

    if (doc.exists) {
      final data = doc.data();
      final birthday = data?['birthday'];
      final parsedBirthday = birthday is Timestamp ? birthday : null;
      final usernameValue = data?['username'];
      final avatarSvg = data?['avatarSVG'];

      setState(() {
        _usernameController.text = usernameValue is String ? usernameValue : '';
        _selectedDate = parsedBirthday?.toDate() ?? DateTime.now();
        _avatar = (avatarSvg is String && avatarSvg.isNotEmpty)
            ? avatarSvg
            : Avataaar.random().toSvg();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final uid = _uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesion para editar tu perfil.'),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'username': _usernameController.text.trim().isNotEmpty
          ? _usernameController.text.trim()
          : null,
      'birthday': Timestamp.fromDate(_selectedDate),
      'avatarSVG': _avatar,
    }, SetOptions(merge: true));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    Navigator.pop(context, _pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: Text('No hay una sesion activa.')),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                : SvgPicture.string(_avatar, width: 200, height: 200),
            ElevatedButton(
              onPressed: () async {
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );

                if (image != null) {
                  setState(() {
                    _pickedImage = File(image.path);
                  });
                }
              },
              child: const Text('Seleccionar imagen'),
            ),
            _pickedImage != null
                ? ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _pickedImage = null;
                      });
                    },
                    child: Text("Avatar"),
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _avatar = Avataaar.random().toSvg();
                      });
                    },
                    child: Text("Generar avatar"),
                  ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('FECHA DE NACIMIENTO:'),
            SizedBox(
              height: 250,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Guardar cambios'),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
