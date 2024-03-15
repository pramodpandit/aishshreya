import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AppTextField3 extends StatelessWidget {
  const AppTextField3({
    Key? key,
    required this.controller,
    required this.title,
    this.hint,
    this.validateMsg,
    this.validate = false,
    this.validator,
    this.obscureText = false,
    this.icon,
    this.maxLines = 1,
    this.suffixIcon,
    this.keyboardType,
    this.inputAction,
    this.isDense = true,
    this.readOnly = false,
    this.showTitle = true,
    this.inputFormatters,
    this.onChanged,
    this.onFieldSubmitted,
  }) : super(key: key);

  final TextEditingController controller;
  final String title;
  final String? hint;
  final String? validateMsg;
  final bool validate;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final int maxLines;
  final Widget? icon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? inputAction;
  final bool isDense;
  final bool readOnly;
  final bool showTitle;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            offset: Offset(2,2),
            blurRadius: 5,
          ),
        ]
      ),
      child: Builder(
        builder: (context) {
          Widget child = TextFormField(
            controller: controller,
            validator: validate
                ? (validator ?? ((value) => value!.isEmpty ? (validateMsg ?? 'Please Enter $title') : null))
                : null,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            textInputAction: inputAction,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            decoration: InputDecoration(
              isDense: isDense,
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              hintText: hint ?? '${title/*.toLowerCase()*/}',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: icon,
              suffixIcon: suffixIcon,
            ),
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,

            // onEditingComplete: ,
          );
          if(kIsWeb) {
            return child;
          } else {
            return ClipSmoothRect(
              radius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 1,
              ),
              child: child,
            );
          }

        }
      ),
    );
  }
}
