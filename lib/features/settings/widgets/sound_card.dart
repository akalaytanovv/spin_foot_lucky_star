import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings_provider.dart';
import 'volume_slider.dart';

class SoundCard extends StatelessWidget {
  const SoundCard({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/card_bg_medium.png', fit: BoxFit.fill),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VolumeSlider(
                label: 'Sound',
                value: settings.soundVolume,
                onChanged: (v) =>
                    context.read<SettingsProvider>().setSoundVolume(v),
              ),
              const SizedBox(height: 25),
              VolumeSlider(
                label: 'Music',
                value: settings.musicVolume,
                onChanged: (v) =>
                    context.read<SettingsProvider>().setMusicVolume(v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
