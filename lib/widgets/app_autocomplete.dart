import 'dart:async';
import 'package:events_app_mobile/widgets/app_text_field.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppAutocomplete<T extends Object> extends StatelessWidget {
  final FutureOr<Iterable<T>> Function(TextEditingValue) optionsBuilder;
  final void Function(T)? onSelected;
  final String hintText;
  final Widget Function(
    BuildContext context,
    void Function(T) onAutoCompleteSelect,
    Iterable<T> options,
  ) optionsViewBuilder;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final Widget? prefixIcon;
  final double? borderRadius;

  const AppAutocomplete({
    super.key,
    required this.hintText,
    required this.optionsBuilder,
    required this.onSelected,
    required this.optionsViewBuilder,
    required this.textEditingController,
    required this.focusNode,
    this.prefixIcon,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete(
      textEditingController: textEditingController,
      focusNode: focusNode,
      optionsBuilder: optionsBuilder,
      optionsViewBuilder: optionsViewBuilder,
      onSelected: onSelected,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return AppTextField(
          borderRadius: borderRadius,
          prefixIcon: prefixIcon,
          suffixIcon: textEditingController.value.text.isNotEmpty
              ? TouchableOpacity(
                  child: const Icon(Icons.close),
                  onTap: () => textEditingController.clear(),
                )
              : null,
          focusNode: focusNode,
          onTap: onFieldSubmitted,
          controller: textEditingController,
          hintText: hintText,
          obscureText: false,
          onChanged: (value) {
            textEditingController.text = value;
          },
          validator: (value) {
            return null;
          },
        );
      },
    );
  }
}
