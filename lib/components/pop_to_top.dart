import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PopToTop extends StatelessWidget {
  final Widget child;
  final ScrollController controller;
  final VoidCallback onPop;

  const PopToTop({
    super.key,
    required this.child,
    required this.controller,
    required this.onPop,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            if (kIsAndroidTV && controller.offset > 1000) {
              controller.animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
              final node = FocusScope.of(context).traversalChildren.firstOrNull;
              node?.requestFocus();
            } else {
              onPop();
            }
          }
        },
        child: child);
  }
}
