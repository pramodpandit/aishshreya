import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextFieldTwo extends StatelessWidget {
  const AppTextFieldTwo({
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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        //contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        hintText: hint ?? '${title/*.toLowerCase()*/}',
        label: showTitle ? Text(title, style: const TextStyle(fontSize: 15)) : null,
        filled: true,
        fillColor: const Color(0xffF4F5F7),//K.disabledColor,
        prefixIcon: icon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
