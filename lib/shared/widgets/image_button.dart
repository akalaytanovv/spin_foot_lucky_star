import 'package:flutter/material.dart';

/// A button that uses [assets/button.png] as its visual background.
///
/// States:
/// - Active: full opacity, label centered, press-scale animation on tap.
/// - Loading ([isLoading] = true): semi-transparent, spinner replaces label.
/// - Disabled ([onPressed] = null): semi-transparent, label still shown, no tap.
class ImageButton extends StatefulWidget {
  final String label;

  /// When null the button is disabled and absorbs no taps.
  final VoidCallback? onPressed;

  /// Shows a spinner in place of the label.
  final bool isLoading;

  /// Logical height of the button. Width always stretches to fill its parent.
  final double height;

  /// Style applied to the label text.
  /// Defaults to [ImageButton.defaultLabelStyle].
  final TextStyle? labelStyle;

  /// Default label style: black, w700, 36 sp.
  static const TextStyle defaultLabelStyle = TextStyle(
    color: Colors.black,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  const ImageButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.labelStyle,
  });

  @override
  State<ImageButton> createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  bool get _isDisabled => widget.isLoading || widget.onPressed == null;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
      value: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.forward();
  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        widget.labelStyle ?? ImageButton.defaultLabelStyle;

    return GestureDetector(
      onTapDown: _isDisabled ? null : _onTapDown,
      onTapUp: _isDisabled ? null : _onTapUp,
      onTapCancel: _isDisabled ? null : _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _isDisabled ? 0.5 : 1.0,
          child: SizedBox(
            width: double.infinity,
            height: widget.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/button.png',
                    fit: BoxFit.fill,
                  ),
                ),
                if (widget.isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                else
                  Text(
                    widget.label.toUpperCase(),
                    style: effectiveStyle,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
