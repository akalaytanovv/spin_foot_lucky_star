import 'package:flutter/material.dart';

import '../../../services/ad_service.dart';

Future<void> showWatchClaimDialog(BuildContext context, {required VoidCallback onComplete}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _WatchClaimDialog(onComplete: onComplete),
  );
}

class _WatchClaimDialog extends StatefulWidget {
  const _WatchClaimDialog({required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<_WatchClaimDialog> createState() => _WatchClaimDialogState();
}

class _WatchClaimDialogState extends State<_WatchClaimDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  bool _isClaimingAd = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    if (_isClaimingAd) {
      AdService.instance.cancelAdSession();
    }
    _pulse.dispose();
    super.dispose();
  }

  void _complete() {
    Navigator.of(context).pop();
    widget.onComplete();
  }

  void _claimSkip() {
    if (_isClaimingAd) {
      AdService.instance.cancelAdSession();
    }
    _complete();
  }

  void _claimWithAd() {
    if (_isClaimingAd) return;

    if (!AdService.instance.isReady) {
      _complete();
      return;
    }

    setState(() => _isClaimingAd = true);

    AdService.instance.showRewarded(
      onRewarded: () {
        if (!mounted) return;
        _complete();
      },
      onAdFinished: () {
        if (!mounted) return;
        setState(() => _isClaimingAd = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C6040), Color(0xFF133D04)],
          ),
          border: Border.all(color: const Color(0xFFA9FF09), width: 2),
          boxShadow: [
            BoxShadow(color: const Color(0xFFFFCC00).withValues(alpha: 0.5), blurRadius: 24, spreadRadius: 2),
            BoxShadow(color: const Color(0xFFFFCC00).withValues(alpha: 0.25), blurRadius: 48),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32).copyWith(bottom: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your prize is ready!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFE5B4),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 8, color: Color(0xFFFFCC00))],
              ),
            ),
            const SizedBox(height: 28),
            ScaleTransition(
              scale: _isClaimingAd ? const AlwaysStoppedAnimation(1.0) : _scale,
              child: _ClaimButton(onTap: _isClaimingAd ? null : _claimWithAd, isLoading: _isClaimingAd),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _claimSkip,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.onTap, this.isLoading = false});

  final VoidCallback? onTap;
  final bool isLoading;

  static const _contentWidth = 196.0;
  static const _contentHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 2)],
        ),
        child: SizedBox(
          width: _contentWidth,
          height: _contentHeight,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Watch & Claim',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
