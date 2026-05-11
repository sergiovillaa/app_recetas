import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  int currentStep = 0;
  List<dynamic> steps = [];
  bool listening = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("es-MX");
    await flutterTts.setSpeechRate(0.45);
  }

  Future<void> _speakStep() async {
    if (steps.isEmpty || currentStep >= steps.length) return;

    await flutterTts.awaitSpeakCompletion(true);

    await flutterTts.speak("Paso ${currentStep + 1}. ${steps[currentStep]}");

    await Future.delayed(const Duration(seconds: 1));

    _listenForNext();
  }

  Future<void> _listenForNext() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        print("Status: $status");

        // Si dejó de escuchar, vuelve a activarse
        if (status == "done" && listening) {
          _listenForNext();
        }
      },
      onError: (error) {
        print("Error: $error");

        if (listening) {
          Future.delayed(const Duration(seconds: 1), () {
            _listenForNext();
          });
        }
      },
    );

    if (available) {
      setState(() => listening = true);

      speech.listen(
        localeId: "es_MX",
        listenMode: stt.ListenMode.confirmation,
        partialResults: true,
        cancelOnError: false,
        listenFor: const Duration(minutes: 10),
        pauseFor: const Duration(seconds: 30),
        onResult: (result) {
          String spoken = result.recognizedWords.toLowerCase();

          print("Escuchado: $spoken");

          if (spoken.contains("siguiente")) {
            speech.stop();
            _nextStep();
          }
        },
      );
    }
  }

  Future<void> _nextStep() async {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
        listening = false;
      });

      await _speakStep();
    } else {
      await flutterTts.speak("Receta terminada. Buen provecho.");
      setState(() => listening = false);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de receta')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _speakStep,
        icon: const Icon(Icons.record_voice_over),
        label: const Text("Modo cocina"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .doc(widget.recipeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Receta no encontrada'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          steps = data['steps'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Imagen
              if (data['image'] != null && (data['image'] as String).isNotEmpty)
                Image.memory(base64Decode(data['image'])),

              // ClipRRect(
              //   borderRadius: BorderRadius.circular(12),
              //   child: Image.network(
              //     data['image'],
              //     height: 220,
              //     width: double.infinity,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              const SizedBox(height: 16),

              // Título
              Text(
                data['title'] ?? 'Sin título',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

              // Autor
              Text(
                "Autor: ${data['author'] ?? 'Anónimo'}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 16),

              // Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
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

              const SizedBox(height: 20),

              // Indicador modo cocina
              if (listening)
                const Card(
                  color: Colors.greenAccent,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Escuchando... di 'siguiente'",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const Divider(height: 32),

              // Descripción
              Text(
                "Descripción",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(data['description'] ?? ''),

              const Divider(height: 32),

              // Ingredientes
              Text(
                "Ingredientes",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),

              ...(data['ingredients'] as List<dynamic>? ?? []).map(
                (ingredient) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(ingredient),
                  ),
                ),
              ),

              const Divider(height: 32),

              // Pasos
              Text("Pasos", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),

              ...(steps).asMap().entries.map(
                (entry) => Card(
                  color: currentStep == entry.key
                      ? Colors.orange.shade100
                      : null,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(child: Text("${entry.key + 1}")),
                    title: Text(entry.value),
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
