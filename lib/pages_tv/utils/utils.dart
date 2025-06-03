import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FadeInPageRoute<T> extends PageRoute<T> {
  FadeInPageRoute({required this.builder, super.settings});

  @override
  final Duration transitionDuration = const Duration(milliseconds: 650);

  @override
  final Duration reverseTransitionDuration = const Duration(milliseconds: 650);

  @override
  final bool opaque = true;

  @override
  final bool barrierDismissible = false;

  @override
  final Color? barrierColor = null;

  @override
  final String? barrierLabel = null;

  @override
  final bool maintainState = true;

  final WidgetBuilder builder;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      fillColor: Colors.transparent,
      child: child,
    );
  }
}

Future<T?> navigateToSlideLeft<T extends Object?>(BuildContext context, Widget page) {
  return Navigator.of(context).push(FadeInPageRoute(builder: (context) => page));
}
