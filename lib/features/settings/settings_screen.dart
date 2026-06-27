import 'package:flutter/material.dart';

import '../../shared/widgets/app_background.dart';
import 'widgets/sound_card.dart';
import 'widgets/toggle_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      appBar: AppBar(
        title: const Text('SETTINGS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 40, right: 40, top: MediaQuery.of(context).padding.top + kToolbarHeight + 10),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [SoundCard(), ToggleCard()],
        ),
      ),
    );
  }
}
