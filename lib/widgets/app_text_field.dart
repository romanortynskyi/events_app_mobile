import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final void Function(String) onChanged;
  final String? Function(String?) validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? borderRadius;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function()? onTap;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.onChanged,
    required this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius,
    this.controller,
    this.focusNode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        focusNode: focusNode,
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: LightThemeColors.hint),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: LightThemeColors.darkGrey),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
          ),
          fillColor: LightThemeColors.grey,
          filled: true,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
