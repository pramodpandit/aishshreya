import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/utils/constants.dart';

class AppDropdown extends StatefulWidget {
  AppDropdown({
    Key? key,
    required this.items,
    required this.onChanged,
    this.selectedItemBuilder,
    required this.value,
    required this.hintText,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.itemHeight,
    this.focusColor,
    this.focusNode,
    this.dropdownColor,
    this.decoration,
    this.onSaved,
    this.validator,
    this.loading,
  }) : super(key: key);

  final ValueChanged onChanged;
  final List<DropdownMenuItem<String>>? items;
  final DropdownButtonBuilder? selectedItemBuilder;
  String? value;
  final String hintText;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final double? itemHeight;
  final Color? focusColor;
  final FocusNode? focusNode;
  final Color? dropdownColor;
  final InputDecoration? decoration;
  final FormFieldSetter? onSaved;
  final FormFieldValidator? validator;
  final String? icon;
  final ValueNotifier<bool>? loading;

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  final bool isDense = true;

  final bool isExpanded = false;

  final bool autofocus = false;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      hint: Text(widget.hintText),
      value: widget.value,
      validator: widget.validator,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9.5,
        ),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      icon: widget.loading == null
          ? const Icon(Icons.keyboard_arrow_down)
          : ValueListenableBuilder(
          valueListenable: widget.loading!,
          builder: (context, bool value, child) {
            return value
                ? LoadingAnimationWidget.dotsTriangle(color: K.themeColorPrimary, size: 15)
                : const Icon(Icons.keyboard_arrow_down);
          }),
      onChanged: (value) {
        setState(() {
          widget.value = value;
        });
        if (widget.onChanged != null) widget.onChanged(value);
      },
      items: widget.items,
    );
  }
}
