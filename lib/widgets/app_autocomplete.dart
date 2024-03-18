import 'dart:async';
import 'package:events_app_mobile/widgets/app_text_field.dart';
import 'package:events_app_mobile/widgets/touchable_opacity.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppAutocomplete<T extends Object> extends StatelessWidget {
  final Color? backgroundColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? placeholderColor;
  final FutureOr<Iterable<T>> Function(TextEditingValue) optionsBuilder;
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
  final int? maxLines;
  final TextInputAction? textInputAction;
  final void Function(T) onSelected;
  final void Function(String) onSubmitted;

  const AppAutocomplete({
    super.key,
    required this.hintText,
    required this.optionsBuilder,
    required this.optionsViewBuilder,
    required this.textEditingController,
    required this.focusNode,
    required this.onSelected,
    required this.onSubmitted,
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
    return RawAutocomplete<T>(
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
          onSubmitted: onSubmitted,
          validator: (value) {
            return null;
          },
        );
      },
    );
  }
}
