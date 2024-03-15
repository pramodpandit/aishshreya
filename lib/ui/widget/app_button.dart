import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppButton extends StatelessWidget {
  final String title;
  final String? image;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color color, textColor;
  final Size size;
  final bool loading;
  final EdgeInsetsGeometry margin;
  final bool _withBorder;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  const AppButton({
    Key? key,
    required this.title,
    required this.onTap,
    this.borderColor,
    this.color = K.themeColorPrimary,
    this.size = const Size(double.infinity, 50),
    this.textColor = Colors.white,
    this.loading = false,
    this.margin = const EdgeInsets.all(5.0),
    this.image,
    this.gradient,
    this.boxShadow,
  }) : _withBorder = false, super(key: key);

  const AppButton.withBorder({
    Key? key,
    required this.title,
    required this.onTap,
    this.image,
    this.color = Colors.white,
    this.size = const Size(double.infinity, 50),
    this.textColor = Colors.white,
    this.loading = false,
    this.margin = const EdgeInsets.all(5.0),
    this.borderColor = K.themeColorSecondary,
    this.gradient,
    this.boxShadow,
  }) : _withBorder = true, super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: BouncingWidget(
        onPressed: () {
          if (!loading) {
            onTap();
          }
        },
        scaleFactor: 0.5,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            color: color,
            gradient: gradient,
            border: _withBorder ? Border.all(color: borderColor!, width: 1) : borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: boxShadow,
          ),
          alignment: Alignment.center,
          child: loading
              ? Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: LoadingAnimationWidget.hexagonDots(
                    color: textColor,
                    size: 30,
                  ),
                )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(image!=null) Image.asset(image!, height: 20, width: 20,),
                  if(image!=null) const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
        ),
      ),
    );
  }
}
