import 'package:flutter/material.dart';

class WatchClaimOverlay extends StatefulWidget {
  const WatchClaimOverlay({
    super.key,
    required this.onClaim,
    required this.onSkip,
    this.isClaiming = false,
  });

  final VoidCallback onClaim;
  final VoidCallback onSkip;
  final bool isClaiming;

  @override
  State<WatchClaimOverlay> createState() => _WatchClaimOverlayState();
}

class _WatchClaimOverlayState extends State<WatchClaimOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your prize is ready!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ScaleTransition(
            scale: widget.isClaiming ? const AlwaysStoppedAnimation(1.0) : _scale,
            child: _ClaimButton(
              onTap: widget.isClaiming ? null : widget.onClaim,
              isLoading: widget.isClaiming,
            ),
          ),
          if (!widget.isClaiming) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: widget.onSkip,
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
        ],
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.onTap, this.isLoading = false});

  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLoading ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                const Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                isLoading ? 'Loading ad...' : 'Watch & Claim',
                style: const TextStyle(
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
    );
  }
}
