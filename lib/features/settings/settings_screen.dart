import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Sound'),
            value: settings.soundEnabled,
            onChanged: (v) => context.read<SettingsProvider>().setSoundEnabled(v),
          ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            value: settings.fxEnabled,
            onChanged: (v) => context.read<SettingsProvider>().setFxEnabled(v),
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            value: settings.vibrationEnabled,
            onChanged: (v) => context.read<SettingsProvider>().setVibrationEnabled(v),
          ),
          const Divider(),
          ListTile(
            title: const Text('Terms of Use'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launchUrl(context, Constants.termsUrl),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _launchUrl(context, Constants.privacyUrl),
          ),
        ],
      ),
    );
  }
}
