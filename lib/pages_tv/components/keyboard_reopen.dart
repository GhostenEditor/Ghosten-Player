import 'package:flutter/material.dart';

class KeyboardReopen extends StatelessWidget {
  const KeyboardReopen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (indent) {
            final context = FocusManager.instance.primaryFocus?.context;
            final state = context?.findAncestorStateOfType<EditableTextState>();
            state?.requestKeyboard();
            return null;
          },
        ),
      },
      child: child,
    );
  }
}
