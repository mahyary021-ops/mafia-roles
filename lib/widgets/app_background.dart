import 'package:flutter/material.dart';

/// Wraps a screen's body with the club logo shown faintly in the
/// background, behind the real content. Used on every screen so the app
/// has a consistent branded look.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.45,
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
