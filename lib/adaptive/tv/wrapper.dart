import 'package:flutter/material.dart';
import 'package:scaled_app/scaled_app.dart';

class PageWrapper extends StatelessWidget {
  const PageWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: ReadingOrderTraversalPolicy(
        requestFocusCallback: (node, {alignmentPolicy, alignment, duration, curve}) {
          node.requestFocus();
          Scrollable.ensureVisible(
            node.context!,
            alignment: 0.8,
            duration: duration ?? const Duration(milliseconds: 400),
            curve: curve ?? Curves.easeOut,
          );
        },
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).scale().copyWith(devicePixelRatio: MediaQuery.of(context).devicePixelRatio),
        child: child,
      ),
    );
  }
}
