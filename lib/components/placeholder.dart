import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GPlaceholder extends StatelessWidget {
  const GPlaceholder({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerLow,
      highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: IgnorePointer(child: child),
    );
  }
}

class GPlaceholderDecoration {
  static const base = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), color: Colors.white);
  static const lite = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), color: Colors.white60);
}

class GPlaceholderRect extends StatelessWidget {
  const GPlaceholderRect({super.key, this.width, this.height, this.padding});

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SizedBox(width: width, height: height, child: const DecoratedBox(decoration: GPlaceholderDecoration.lite)),
    );
  }
}

class GPlaceholderImage extends StatelessWidget {
  const GPlaceholderImage({super.key, this.width, this.height, this.padding});

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SizedBox(
        width: width,
        height: height,
        child: const DecoratedBox(decoration: GPlaceholderDecoration.lite, child: Icon(Icons.image_outlined, size: 56)),
      ),
    );
  }
}
