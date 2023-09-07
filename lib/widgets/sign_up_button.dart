import 'package:events_app_mobile/consts/light_theme_colors.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';

class SignUpButton extends StatelessWidget {
  final Function() onPressed;

  const SignUpButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Not a member?',
          style: TextStyle(color: LightThemeColors.text),
        ),
        const SizedBox(width: 5),
        TouchableOpacity(
          onTap: onPressed,
          child: Text(
            'Sign up',
            style: TextStyle(color: LightThemeColors.primary),
          ),
        ),
      ],
    );
  }
}
