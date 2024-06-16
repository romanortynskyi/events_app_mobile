import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class AppTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final void Function(String) onChanged;
  final String? Function(String?) validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? borderRadius;
  final TextInputType? keyboardType;
  final int? maxLines;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final Color? backgroundColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? placeholderColor;
  final TextInputAction? textInputAction;
  final String? initialValue;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.onChanged,
    required this.validator,
    this.keyboardType,
    this.maxLines,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius,
    this.controller,
    this.focusNode,
    this.backgroundColor,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.placeholderColor,
    this.textInputAction,
    this.initialValue,
    this.onTap,
    this.onSubmitted,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      keyboardType: keyboardType,
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      validator: validator,
      obscureText: obscureText,
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: placeholderColor ?? LightThemeColors.hint),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: enabledBorderColor ?? Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: focusedBorderColor ?? LightThemeColors.darkGrey),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
        ),
        fillColor: backgroundColor ?? LightThemeColors.grey,
        filled: true,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
