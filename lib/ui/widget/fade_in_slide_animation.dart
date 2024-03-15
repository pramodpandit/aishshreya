import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class FadeInSlideAnimation extends StatelessWidget {
  final Widget child;
  final int position;
  final Duration duration;
  final Duration? delay, curveDelay, curveDuration;
  final double verticalOffset, horizontalOffset;
  final Curve curve;

  const FadeInSlideAnimation(
      {Key? key,
      required this.child,
      this.position = 0,
      this.duration = const Duration(milliseconds: 375),
      this.delay,
      this.curveDelay,
      this.curveDuration,
      this.verticalOffset = 0.0,
      this.horizontalOffset = 0.0,
      this.curve = Curves.ease})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: position,
      duration: duration,
      delay: delay,
      child: SlideAnimation(
        curve: curve,
        verticalOffset: verticalOffset,
        horizontalOffset: horizontalOffset,
        duration: duration,
        delay: curveDelay,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}
