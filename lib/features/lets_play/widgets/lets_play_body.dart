import 'package:flutter/material.dart';

import '../../../shared/widgets/image_button.dart';

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

  static const _disclaimerStyle = TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w400, fontSize: 20);

  Widget _outlinedText(String text) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: _disclaimerStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = const Color(0xFF006000),
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: _disclaimerStyle.copyWith(color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // ── Top: logo (fixed) ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Image.asset('assets/logo.png', width: screenWidth / 2),
        ),

        // ── Middle: splash_logo stretches to fill remaining space ─────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Image.asset('assets/splash_logo.png', width: double.infinity, fit: BoxFit.cover),
            ),
          ),
        ),

        // ── Bottom: button + disclaimer (fixed) ───────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 50, left: 30, right: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageButton(label: "LET'S PLAY", onPressed: onPlayPressed, height: 78),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _outlinedText('By tapping "Let\'s Play" you confirm that you 18+ and accept'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _outlinedText('our '),
                  TextButton(
                    onPressed: onTermsPressed,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _outlinedText('Terms'),
                  ),
                  _outlinedText(' & '),
                  TextButton(
                    onPressed: onPrivacyPressed,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _outlinedText('Privacy Policy'),
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
