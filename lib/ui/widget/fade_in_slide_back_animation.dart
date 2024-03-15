import 'package:flutter/material.dart';

class FadeInSlideBackAnimation extends StatelessWidget {
  final bool show;
  final Widget child;
  final Curve curve;
  final Offset fadingOffset;
  const FadeInSlideBackAnimation({Key? key, required this.show, required this.child, this.curve = Curves.easeInOutBack, this.fadingOffset = const Offset(-0.5, 0), }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: show ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      // curve: Curves.easeInOutExpo,
      curve: curve,
      child: AnimatedSlide(
        offset: show ? const Offset(0, 0) : fadingOffset,
        duration: const Duration(milliseconds: 500),
        curve: curve,
        child: child,
      ),
    );
  }
}

class FadeSlideInOutAnimation extends StatelessWidget {
  final bool forward;
  final Widget child;
  final Curve curve;
  final Offset fadingOffset;
  const FadeSlideInOutAnimation({Key? key, required this.forward, required this.child, this.curve = Curves.easeInOut, this.fadingOffset = const Offset(-0.5, 0), }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //entry
        AnimatedOpacity(
          opacity: forward ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          // curve: Curves.easeInOutExpo,
          curve: curve,
          child: AnimatedSlide(
            offset: forward ? const Offset(0, 0) : Offset(0, 2),
            duration: const Duration(milliseconds: 500),
            curve: curve,
            child: child,
          ),
        ),
        //exit
        AnimatedOpacity(
          opacity: forward ? 0 : 1,
          duration: const Duration(milliseconds: 500),
          // curve: Curves.easeInOutExpo,
          curve: curve,
          child: AnimatedSlide(
            offset: forward ? Offset(0, -2) : const Offset(0, 0),
            duration: const Duration(milliseconds: 500),
            curve: curve,
            child: child,
          ),
        ),
      ],
    );
  }
}

