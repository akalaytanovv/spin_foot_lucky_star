import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings_provider.dart';
import 'switch_row.dart';

class ToggleCard extends StatelessWidget {
  const ToggleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Stack(
      children: [
        Positioned.fill(child: Image.asset('assets/card_bg_small.png', fit: BoxFit.fill)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SwitchRow(
                label: 'Vibrations',
                value: settings.vibrationEnabled,
                onChanged: (v) => context.read<SettingsProvider>().setVibrationEnabled(v),
              ),
              const SizedBox(height: 22),
              const SwitchRow(label: 'Notifications', value: false, onChanged: null),
            ],
          ),
        ),
      ],
    );
  }
}
