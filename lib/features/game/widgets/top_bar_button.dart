import 'package:flutter/material.dart';

class TopBarButton extends StatelessWidget {
  final String asset;
  final String tooltip;
  final VoidCallback onPressed;

  const TopBarButton({
    super.key,
    required this.asset,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Image.asset(asset, width: 40, height: 40, fit: BoxFit.contain),
      ),
    );
  }
}
