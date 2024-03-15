import 'package:flutter/material.dart';

class Shimmer extends StatelessWidget {
  final double height, width, borderRadius;
  final double radius;
  final bool _isCircle;

  const Shimmer.rectangle({
    Key? key,
    required this.height,
    required this.width,
    this.borderRadius = 5,
  }) : radius=0, _isCircle = false, super(key: key);

  const Shimmer.circle({
    Key? key,
    required this.radius,
  }) : height=0, width=0, borderRadius=0, _isCircle = true, super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget shimmer = Image.asset('assets/images/loading_shimmer.gif', fit: BoxFit.cover,);
    return Container(
      height: _isCircle ? radius*2 : height,
      width: _isCircle ? radius*2 : width,
      decoration: BoxDecoration(
        shape: _isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: _isCircle ? null : BorderRadius.circular(borderRadius),
      ),
      child: _isCircle ? ClipOval(
          child: shimmer
      ) : ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: shimmer,
      ),
    );
  }
}

class CustomPlaceholder extends StatelessWidget {
  final double height, width, borderRadius;
  final double radius;
  final bool _isCircle;

  const CustomPlaceholder.rectangle({
    Key? key,
    required this.height,
    required this.width,
    this.borderRadius = 5,
  }) : radius=0, _isCircle = false, super(key: key);

  const CustomPlaceholder.circle({
    Key? key,
    required this.radius,
  }) : height=0, width=0, borderRadius=0, _isCircle = true, super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget shimmer = Image.asset('assets/images/loading_shimmer.gif', fit: BoxFit.cover,);
    return Container(
      height: _isCircle ? radius*2 : height,
      width: _isCircle ? radius*2 : width,
      decoration: BoxDecoration(
        shape: _isCircle ? BoxShape.circle : BoxShape.rectangle,
        color: Colors.white,
        borderRadius: _isCircle ? null : BorderRadius.circular(borderRadius),
      ),
    );
  }
}