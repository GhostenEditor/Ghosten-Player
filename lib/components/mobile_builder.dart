import 'package:flutter/material.dart';

class MobileBuilder<T> extends StatefulWidget {
  final Widget? Function(BuildContext context, bool isMobile, T? child) builder;
  final T? child;

  const MobileBuilder({super.key, required this.builder, this.child});

  @override
  State<MobileBuilder<T>> createState() => _MobileBuilderState();
}

class _MobileBuilderState<T> extends State<MobileBuilder<T>> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return widget.builder(context, isMobile, widget.child) ?? const SizedBox();
  }
}
