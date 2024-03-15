import 'package:aishshreya/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    Key? key,
    required this.controller,
    required this.title,
    this.hint,
    this.validateMsg,
    this.validate = false,
    this.enabled = true,
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
    this.fillColor = K.themeColorSecondary,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  final TextEditingController controller;
  final String title;
  final String? hint;
  final String? validateMsg;
  final bool validate;
  final bool enabled;
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
  final Color fillColor;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onFieldSubmitted;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(showTitle) Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(title, style: const TextStyle(fontSize: 15)),
        ),
        if(showTitle) const SizedBox(height: 5),
        TextFormField(
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
          enabled: enabled,
          decoration: InputDecoration(
            isDense: isDense,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xffF2F2F2)),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: const Color(0xffF4F5F7)),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            hintText: hint ?? '${title/*.toLowerCase()*/}',
            filled: true,
            fillColor: fillColor,//K.disabledColor,
            prefixIcon: icon,
            suffixIcon: suffixIcon,
          ),
          onFieldSubmitted: onFieldSubmitted,
          textCapitalization: textCapitalization,
        ),
      ],
    );
  }
}
