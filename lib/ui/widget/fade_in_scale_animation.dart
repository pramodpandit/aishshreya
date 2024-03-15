import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class FadeInScaleAnimation extends StatelessWidget {
  final Widget child;
  final int position;
  final Duration duration;
  final Duration? delay, curveDelay;
  final double scale;
  final Curve curve;

  const FadeInScaleAnimation(
      {Key? key,
        required this.child,
        this.position = 0,
        this.duration = const Duration(milliseconds: 375),
        this.delay,
        this.curveDelay,
        this.scale = 0.0,
        this.curve = Curves.ease})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: position,
      duration: duration,
      delay: delay,
      child: ScaleAnimation(
        curve: curve,
        scale: scale,
        duration: duration,
        delay: curveDelay,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}
