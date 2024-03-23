import 'package:flutter/material.dart';

class TouchableOpacity extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration = const Duration(milliseconds: 50);
  final double opacity = 0.5;

  const TouchableOpacity({super.key, required this.child, required this.onTap});

  @override
  // ignore: library_private_types_in_public_api
  _TouchableOpacityState createState() => _TouchableOpacityState();
}

class _TouchableOpacityState extends State<TouchableOpacity> {
  bool _isDown = false;

  @override
  void initState() {
    super.initState();
    setState(() => _isDown = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isDown = true),
      onTapUp: (_) => setState(() => _isDown = false),
      onTapCancel: () => setState(() => _isDown = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        duration: widget.duration,
        opacity: _isDown ? widget.opacity : 1,
        child: widget.child,
      ),
    );
  }
}
