import 'dart:ui';

import 'package:flutter/material.dart';

import 'async_image.dart';

class BlurredBackground extends StatefulWidget {
  final String background;

  const BlurredBackground({super.key, required this.background});

  @override
  State<BlurredBackground> createState() => _BlurredBackgroundState();
}

class _BlurredBackgroundState extends State<BlurredBackground> with SingleTickerProviderStateMixin {
  late final size = MediaQuery.of(context).size;
  final blurSize = 50.0;
  final scaleSize = 3;
  Offset offset = Offset.zero;
  Offset vector = const Offset(2, 2);

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform(
        transform: transform(),
        child: child,
      ),
      child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: blurSize, sigmaY: blurSize), child: AsyncImage(widget.background)),
    );
  }

  Matrix4 transform() {
    assert(scaleSize >= 2);
    if (offset.dx < 0 || offset.dx > size.width * (scaleSize - 1)) {
      vector = Offset(-vector.dx, vector.dy);
    }
    if (offset.dy < 0 || offset.dy > size.height * (scaleSize - 1)) {
      vector = Offset(vector.dx, -vector.dy);
    }
    offset += vector;
    return Matrix4.translationValues(-offset.dx, -offset.dy, 0).scaled(scaleSize.toDouble(), scaleSize.toDouble(), 1.0);
  }
}
