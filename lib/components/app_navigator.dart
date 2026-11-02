import 'package:flutter/material.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({
    super.key,
    this.navigatorKey,
    this.onGenerateRoute,
    this.initialRoute,
    this.onUnknownRoute,
    this.requestFocus = false,
    this.routeDirectionalTraversalEdgeBehavior = kDefaultRouteDirectionalTraversalEdgeBehavior,
  });

  final GlobalKey<NavigatorState>? navigatorKey;
  final RouteFactory? onGenerateRoute;
  final String? initialRoute;
  final RouteFactory? onUnknownRoute;
  final bool requestFocus;
  final TraversalEdgeBehavior routeDirectionalTraversalEdgeBehavior;

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  Navigator? _navigator;

  @override
  Widget build(BuildContext context) {
    _navigator ??= Navigator(
      key: widget.navigatorKey,
      requestFocus: widget.requestFocus,
      initialRoute: widget.initialRoute,
      onGenerateRoute: widget.onGenerateRoute,
      onUnknownRoute: widget.onUnknownRoute,
      routeDirectionalTraversalEdgeBehavior: widget.routeDirectionalTraversalEdgeBehavior,
    );
    return NavigatorPopHandler(
      onPopWithResult: (_) => widget.navigatorKey?.currentState?.maybePop(),
      child: _navigator!,
    );
  }
}
