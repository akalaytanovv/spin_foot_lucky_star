import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/widgets/app_background.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.message});

  final String? message;

  static const _borderColor = Color(0xFF00FF26);
  static const _gradientStart = Color(0xFF1C510B);
  static const _gradientEnd = Color(0xFF051900);

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [_gradientStart, _gradientEnd],
              ),
              border: Border.all(color: _borderColor, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Text(
                  'PLEASE WAIT',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.puritan(fontWeight: FontWeight.w700, fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(33),
                  child: SizedBox(width: 175, height: 175, child: Image.asset('assets/tech.png', fit: BoxFit.cover)),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'The good news: once we\u2019re back, every user will receive a special loylty bonus. Hang tight, we\u2019re almost there!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.puritan(fontWeight: FontWeight.w400, fontSize: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
