import 'package:flutter/material.dart';

class BallWidget extends StatefulWidget {
  final bool isRunning;

  const BallWidget({super.key, required this.isRunning});

  @override
  State<BallWidget> createState() => _BallWidgetState();
}

class _BallWidgetState extends State<BallWidget> {
  static const _frames = [
    'assets/ball_dynamic_1.png',
    'assets/ball_dynamic_2.png',
    'assets/ball_dynamic_3.png',
  ];
  static const _frameDuration = Duration(milliseconds: 70);

  // Native size of the dynamic sprite asset (full canvas with effects).
  static const double _dynamicW = 282;
  static const double _dynamicH = 292;
  // Scale applied to the container (1.0 = native size).
  static const double _scale = 0.7;

  static const double _containerW = _dynamicW * _scale;
  static const double _containerH = _dynamicH * _scale;
  // Native size of the static ball asset relative to the dynamic canvas.
  static const double _staticRatioW = 198 / _dynamicW;
  static const double _staticRatioH = 200 / _dynamicH;
  static const double _staticW = _containerW * _staticRatioW;
  static const double _staticH = _containerH * _staticRatioH;

  int _frameIndex = 0;
  late final ValueNotifier<int> _frameNotifier;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _frameNotifier = ValueNotifier(0);
    if (widget.isRunning) _startAnimation();
  }

  @override
  void didUpdateWidget(BallWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _frameIndex = 0;
      _startAnimation();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _stopAnimation();
    }
  }

  void _startAnimation() {
    if (_animating) return;
    _animating = true;
    _scheduleNext();
  }

  void _scheduleNext() {
    if (!_animating || !mounted) return;
    Future.delayed(_frameDuration, () {
      if (!_animating || !mounted) return;
      _frameIndex = (_frameIndex + 1) % _frames.length;
      _frameNotifier.value = _frameIndex;
      _scheduleNext();
    });
  }

  void _stopAnimation() {
    _animating = false;
  }

  @override
  void dispose() {
    _animating = false;
    _frameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _containerW,
      height: _containerH,
      child: widget.isRunning
          ? ValueListenableBuilder<int>(
              valueListenable: _frameNotifier,
              builder: (_, idx, __) =>
                  Image.asset(_frames[idx], width: _containerW, height: _containerH, fit: BoxFit.fill),
            )
          : Center(
              child: Image.asset('assets/ball_static.png', width: _staticW, height: _staticH),
            ),
    );
  }
}
