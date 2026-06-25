import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../services/audio_service.dart';
import 'widgets/lets_play_body.dart';

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
          child: LetsPlayBody(
            onPlayPressed: () => Navigator.pushNamed(context, '/game'),
            onTermsPressed: Constants.termsUrl.isNotEmpty ? () => _launchUrl(Constants.termsUrl) : null,
            onPrivacyPressed: Constants.privacyUrl.isNotEmpty ? () => _launchUrl(Constants.privacyUrl) : null,
          ),
        ),
      ),
    );
  }
}
