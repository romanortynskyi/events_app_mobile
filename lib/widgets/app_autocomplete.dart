import 'dart:async';
import 'package:events_app_mobile/widgets/app_text_field.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppAutocomplete extends StatelessWidget {
  final Color? backgroundColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? placeholderColor;
  final FutureOr<Iterable<String>> Function(TextEditingValue) optionsBuilder;
  final String hintText;
  final Widget Function(
    BuildContext context,
    void Function(String) onAutoCompleteSelect,
    Iterable<String> options,
  ) optionsViewBuilder;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final Widget? prefixIcon;
  final double? borderRadius;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final void Function(String) onSelected;

  const AppAutocomplete({
    super.key,
    required this.hintText,
    required this.optionsBuilder,
    required this.optionsViewBuilder,
    required this.textEditingController,
    required this.focusNode,
    required this.onSelected,
    this.prefixIcon,
    this.borderRadius,
    this.backgroundColor,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.placeholderColor,
    this.maxLines,
    this.textInputAction,
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
          backgroundColor: backgroundColor,
          textInputAction: textInputAction,
          enabledBorderColor: enabledBorderColor,
          focusedBorderColor: focusedBorderColor,
          placeholderColor: placeholderColor,
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
          maxLines: maxLines,
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
