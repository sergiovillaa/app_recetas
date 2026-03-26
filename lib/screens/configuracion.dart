import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {

  String _theme = 'Sistema';
  bool _notifications = true;
  bool _wifiOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de la app'),
      ),

      body: ListView(
        children: [

          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Tema'),
            subtitle: Text(_theme),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showThemeDialog,
          ),

          SwitchListTile(
            title: const Text('Notificaciones'),
            subtitle: const Text('Activar notificaciones de la app'),
            value: _notifications,
            onChanged: (value) {
              setState(() {
                _notifications = value;
              });
            },
          ),

          const Divider(),

          SwitchListTile(
            title: const Text('Solo WiFi'),
            subtitle: const Text('Descargar contenido solo con WiFi'),
            value: _wifiOnly,
            onChanged: (value) {
              setState(() {
                _wifiOnly = value;
              });
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text('Buscar actualizaciones'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App actualizada')),
              );
            },
          ),

          /// 📱 VERSION
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Versión'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  /// 🎨 DIALOGO DE TEMA
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _themeOption('Claro'),
              _themeOption('Oscuro'),
              _themeOption('Sistema'),
            ],
          ),
        );
      },
    );
  }

  Widget _themeOption(String theme) {
    return RadioListTile(
      title: Text(theme),
      value: theme,
      groupValue: _theme,
      onChanged: (value) {
        setState(() {
          _theme = value!;
        });
        Navigator.pop(context);
      },
    );
  }
}