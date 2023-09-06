import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String imgSrc;
  final void Function() onPressed;

  const SocialButton({
    super.key,
    required this.imgSrc,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TouchableOpacity(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[200],
          ),
          child: Image.asset(
            imgSrc,
            height: 40,
          ),
        ));
  }
}
