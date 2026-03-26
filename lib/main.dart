import 'package:flutter/material.dart';
import 'package:proyecto_recetas/screens/auth_screen.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light(useMaterial3: true),
      dark: ThemeData.dark(useMaterial3: true),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'App Recetas',
        theme: theme,
        darkTheme: darkTheme,
        home: const AuthScreen(),
      ),
    );
  }
}
