import 'package:events_app_mobile/consts/enums/button_type.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final ButtonType type;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final String text;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    int alpha = isDisabled ? 120 : 255;

    Widget child = Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: type == ButtonType.primary
            ? Color.fromARGB(alpha, 125, 96, 200)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: type == ButtonType.primary ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );

    return isDisabled
        ? GestureDetector(
            onTap: onPressed,
            child: child,
          )
        : TouchableOpacity(
            onTap: onPressed,
            child: child,
          );
  }
}
