import 'package:flutter/material.dart';

class WidgetUtils {
  static Size getSize(GlobalKey key) {
    final RenderObject? renderObject = key.currentContext?.findRenderObject();

    if (renderObject != null) {
      return (renderObject as RenderBox).size;
    }

    return const Size(0, 0);
  }

  static Offset? getOffset(GlobalKey key) {
    final RenderObject? renderObject = key.currentContext?.findRenderObject();

    if (renderObject != null) {
      final offset = (renderObject as RenderBox).localToGlobal(Offset.zero);

      return offset;
    }

    return const Offset(0, 0);
  }
}
