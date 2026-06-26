import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.appBar, this.resizeToAvoidBottomInset = true});

  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.png', fit: BoxFit.cover),
          child,
        ],
      ),
    );
  }
}
