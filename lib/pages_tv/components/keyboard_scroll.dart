import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardScroll extends StatefulWidget {
  const KeyboardScroll({
    super.key,
    required this.child,
    required this.controller,
    this.autofocus = false,
    this.onFocusChange,
  });

  final Widget child;
  final ScrollController controller;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;

  @override
  State<KeyboardScroll> createState() => _KeyboardScrollState();
}

class _KeyboardScrollState extends State<KeyboardScroll> {
  late final _controller = widget.controller;
  double _cachedOffset = 0;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: widget.onFocusChange,
      onKeyEvent: _onKeyEvent,
      child: widget.child,
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          _cachedOffset = (_cachedOffset - 100).clamp(
            _controller.position.minScrollExtent,
            _controller.position.maxScrollExtent,
          );
          if (_cachedOffset != _controller.offset) {
            _controller.animateTo(_cachedOffset, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
            return KeyEventResult.handled;
          }
        case LogicalKeyboardKey.arrowDown:
          _cachedOffset = (_cachedOffset + 100).clamp(
            _controller.position.minScrollExtent,
            _controller.position.maxScrollExtent,
          );
          if (_cachedOffset != _controller.offset) {
            _controller.animateTo(_cachedOffset, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
            return KeyEventResult.handled;
          }
      }
    }
    return KeyEventResult.ignored;
  }
}
