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
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // ── Top: logo (fixed) ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Image.asset(
            'assets/logo.png',
            width: screenWidth / 2,
          ),
        ),

        // ── Middle: splash_logo stretches to fill remaining space ─────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Image.asset(
                'assets/splash_logo.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // ── Bottom: button + disclaimer (fixed) ───────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 32, left: 36, right: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPlayPressed,
                  child: const Text("Let's Play"),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'By tapping "Let\'s Play" you confirm that you 18+ and',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('our ', style: TextStyle(fontSize: 12)),
                  TextButton(
                    onPressed: onTermsPressed,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Terms'),
                  ),
                  const Text(' & ', style: TextStyle(fontSize: 12)),
                  TextButton(
                    onPressed: onPrivacyPressed,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Privacy Policy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
