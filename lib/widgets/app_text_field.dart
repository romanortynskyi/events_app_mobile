import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final void Function(String) onChanged;
  final String? Function(String?) validator;
  final IconButton? suffixIcon;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.onChanged,
    required this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        onChanged: onChanged,
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: LightThemeColors.hint),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFC8C7C8)),
          ),
          fillColor: const Color(0xFFECEBEC),
          filled: true,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
