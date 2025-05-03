import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldFocus extends StatelessWidget {
  const TextFieldFocus({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(skipTraversal: true, onKeyEvent: _onKeyEvent, child: child);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.arrowRight:
          FocusManager.instance.primaryFocus?.nextFocus();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.arrowLeft:
          FocusManager.instance.primaryFocus?.previousFocus();
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
