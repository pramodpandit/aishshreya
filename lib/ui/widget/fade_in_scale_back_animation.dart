import 'package:flutter/material.dart';

class FadeInScaleBackAnimation extends StatelessWidget {
  final bool show;
  final Widget child;
  final Curve curve;
  const FadeInScaleBackAnimation({Key? key, required this.show, required this.child, this.curve = Curves.easeInOutBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: show ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      // curve: Curves.easeInOutExpo,
      curve: curve,
      child: AnimatedScale(
        scale: show ? 1 : 0.95,
        duration: const Duration(milliseconds: 500),
        curve: curve,
        child: child,
      ),
    );
  }
}
