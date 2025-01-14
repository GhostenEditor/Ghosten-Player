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
            onPop();
          }
        },
        child: child);
  }
}
