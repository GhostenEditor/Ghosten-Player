import 'package:flutter/material.dart';

class MobileBuilder<T> extends StatefulWidget {
  const MobileBuilder({super.key, required this.builder, this.child});

  final Widget? Function(BuildContext context, bool isMobile, T? child) builder;
  final T? child;

  @override
  State<MobileBuilder<T>> createState() => _MobileBuilderState();
}

class _MobileBuilderState<T> extends State<MobileBuilder<T>> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.aspectRatio < 1;
    return widget.builder(context, isMobile, widget.child) ?? const SizedBox();
  }
}
