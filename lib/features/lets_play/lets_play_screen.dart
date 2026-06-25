import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../services/audio_service.dart';

class LetsPlayScreen extends StatefulWidget {
  const LetsPlayScreen({super.key});

  @override
  State<LetsPlayScreen> createState() => _LetsPlayScreenState();
}

class _LetsPlayScreenState extends State<LetsPlayScreen> {
  @override
  void initState() {
    super.initState();
    AudioService.instance.playBackground('audio/background.mp3');
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
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
                ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/game'), child: const Text("Let's Play")),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: Constants.termsUrl.isNotEmpty ? () => _launchUrl(Constants.termsUrl) : null,
                      child: const Text('Terms of Use'),
                    ),
                    const Text('·'),
                    TextButton(
                      onPressed: Constants.privacyUrl.isNotEmpty ? () => _launchUrl(Constants.privacyUrl) : null,
                      child: const Text('Privacy Policy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
