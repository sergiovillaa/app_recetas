import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

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
        bool isDark =
            AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;
        return AlertDialog(
          title: const Text('Tema'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Expanded(child: Text('Modo oscuro')),
                  Switch(
                    value: isDark,
                    onChanged: (value) {
                      setDialogState(() {
                        isDark = value;
                      });
                      setState(() {
                        _theme = value ? 'Oscuro' : 'Claro';
                      });
                      if (value) {
                        AdaptiveTheme.of(context).setDark();
                      } else {
                        AdaptiveTheme.of(context).setLight();
                      }
                    },
                  ),
                ],
              );
            },
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


