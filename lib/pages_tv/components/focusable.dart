import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class Focusable extends StatefulWidget {
  const Focusable({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.autofocus,
    this.onFocusChange,
    this.selected,
    this.backgroundColor,
    this.selectedBackgroundColor,
  });

  final Widget child;
  final double? width;
  final double? height;
  final bool? autofocus;
  final bool? selected;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final GestureTapCallback? onTap;
  final ValueChanged<bool>? onFocusChange;

  @override
  State<Focusable> createState() => _FocusableState();
}

class _FocusableState extends State<Focusable> with SingleTickerProviderStateMixin {
  bool _focused = false;
  late final _animation = AnimationController(vsync: this, duration: const Duration(seconds: 8));
  final _animationController = StreamController<bool>();
  late final _animationStream =
      _animationController.stream.switchMap((s) {
        if (s) {
          return Stream.fromFuture(Future.delayed(const Duration(milliseconds: 200))).map((_) => true);
        } else {
          return Stream.value(false);
        }
      }).distinct();
  StreamSubscription<bool>? _animationSubscription;

  @override
  void initState() {
    super.initState();
    _animationSubscription = _animationStream.listen((flag) {
      if (flag) {
        _animation.repeat();
      } else {
        _animation.stop();
      }
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    _animationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Material(
            color:
                widget.selected ?? false
                    ? (widget.selectedBackgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest)
                    : (widget.backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow),
            shape: GradientRoundedRectangleBorder(
              side: _focused ? const BorderSide(width: 4, strokeAlign: 2) : BorderSide.none,
              gradient: SweepGradient(
                colors: const [
                  Color(0xff7068f8),
                  Color(0xffb090d5),
                  Color(0xffece1f6),
                  Color(0xff0966d6),
                  Color(0xff95d1f7),
                  Color(0xffe6f6ff),
                  Color(0xff7068f8),
                ],
                transform: GradientRotation(2 * pi * _animation.value),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: child,
          );
        },
        child: InkWell(
          autofocus: widget.autofocus ?? false,
          onFocusChange: (f) {
            if (_focused != f) {
              _animationController.add(f);
              setState(() => _focused = f);
            }
            if (widget.onFocusChange != null) widget.onFocusChange!(f);
          },
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          onTap: widget.onTap,
          child: widget.child,
        ),
      ),
    );
  }
}

class GradientRoundedRectangleBorder extends RoundedRectangleBorder {
  const GradientRoundedRectangleBorder({super.side, super.borderRadius, required this.gradient});

  final Gradient gradient;

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is GradientRoundedRectangleBorder) {
      if (a.side == BorderSide.none) {
        final g =
            Gradient.lerp(SweepGradient(colors: List.filled(gradient.colors.length, Colors.transparent)), gradient, t)!;
        return GradientRoundedRectangleBorder(
          side: BorderSide.lerp(a.side, side, t),
          borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t)!,
          gradient: g,
        );
      }
      if (a.gradient is SweepGradient) {
        return GradientRoundedRectangleBorder(side: side, borderRadius: borderRadius, gradient: gradient);
      }
    }
    return super.lerpFrom(a, t);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        if (side.width == 0.0) {
          canvas.drawRRect(borderRadius.resolve(textDirection).toRRect(rect), side.toPaint());
        } else {
          final Paint paint =
              Paint()
                ..color = side.color
                ..shader = gradient.createShader(rect);
          final RRect borderRect = borderRadius.resolve(textDirection).toRRect(rect);
          final RRect inner = borderRect.deflate(side.strokeInset);
          final RRect outer = borderRect.inflate(side.strokeOutset);
          canvas.drawDRRect(outer, inner, paint);
        }
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GradientRoundedRectangleBorder &&
        other.side == side &&
        other.borderRadius == borderRadius &&
        other.gradient == gradient;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius, gradient);
}
