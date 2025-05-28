import 'dart:math';

import 'package:flutter/material.dart';

class PlayingIcon extends StatefulWidget {
  const PlayingIcon({super.key, this.color = Colors.white, this.size = 16});

  final Color? color;
  final double size;

  @override
  State<PlayingIcon> createState() => _PlayingIconState();
}

class _PlayingIconState extends State<PlayingIcon> with SingleTickerProviderStateMixin {
  late final animation = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  final count = 4;
  final speed = 4;
  late final array = List.generate(count, (_) => (Random().nextDouble(), Random().nextDouble()));

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = widget.size / (count + 1) / (count - 1);
    final width = widget.size / (count + 1);
    final decoration = BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(widget.size / 16));
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: animation,
          builder:
              (context, child) => Row(
                mainAxisSize: MainAxisSize.min,
                spacing: spacing,
                crossAxisAlignment: CrossAxisAlignment.end,
                children:
                    array
                        .map(
                          (entry) => Container(decoration: decoration, width: width, height: h(1 + entry.$1, entry.$2)),
                        )
                        .toList(),
              ),
        ),
      ),
    );
  }

  double h(double a, double b) {
    return ((sin(
                      ((animation.lastElapsedDuration?.inMilliseconds ?? 0) / Duration.millisecondsPerSecond * a + b) *
                          speed,
                    ) +
                    1) *
                0.35 +
            0.3) *
        widget.size;
  }
}
