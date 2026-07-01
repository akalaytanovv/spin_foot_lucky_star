import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_router.dart';
import '../../core/constants.dart';
import '../../shared/widgets/app_background.dart';
import 'widgets/lets_play_body.dart';

class LetsPlayScreen extends StatelessWidget {
  const LetsPlayScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: LetsPlayBody(
          onPlayPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.game),
          onTermsPressed: Constants.termsUrl.isNotEmpty ? () => _launchUrl(context, Constants.termsUrl) : null,
          onPrivacyPressed: Constants.privacyUrl.isNotEmpty ? () => _launchUrl(context, Constants.privacyUrl) : null,
        ),
      ),
    );
  }
}
