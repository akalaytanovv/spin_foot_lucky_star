import 'package:flutter/material.dart';

class LetsPlayBody extends StatelessWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback? onTermsPressed;
  final VoidCallback? onPrivacyPressed;

  const LetsPlayBody({
    super.key,
    required this.onPlayPressed,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Spin Foot Lucky Star',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: onPlayPressed,
            child: const Text("Let's Play"),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: onTermsPressed,
                child: const Text('Terms of Use'),
              ),
              const Text('·'),
              TextButton(
                onPressed: onPrivacyPressed,
                child: const Text('Privacy Policy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
