import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart' hide TextFormField;
import 'package:flutter/services.dart';

class TextFormField extends StatefulWidget {
  const TextFormField({
    super.key,
    this.maxLines = 1,
    this.validator,
    this.autofocus = false,
    this.obscureText = false,
    required this.controller,
    this.keyboardType,
    this.onTap,
    this.decoration,
    this.onChanged,
    this.onEditingComplete,
    this.minLines,
    this.onTapOutside,
  });

  final InputDecoration? decoration;
  final int? minLines;
  final int? maxLines;
  final FormFieldValidator<String?>? validator;
  final bool obscureText;
  final bool autofocus;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final GestureTapCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final TapRegionCallback? onTapOutside;

  @override
  State<TextFormField> createState() => TextFormFieldState();
}

class TextFormFieldState extends State<TextFormField> with SingleTickerProviderStateMixin {
  bool _readOnly = true;
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _readOnly,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        setState(() => _readOnly = true);
      },
      child: Focus(
        skipTraversal: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (_readOnly && (event is KeyDownEvent || event is KeyRepeatEvent)) {
            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowDown:
                FocusManager.instance.primaryFocus?.nextFocus();
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowUp:
                FocusManager.instance.primaryFocus?.previousFocus();
                return KeyEventResult.handled;
              case LogicalKeyboardKey.enter:
                setState(() => _readOnly = false);
                return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: m.TextFormField(
          autofocus: widget.autofocus,
          focusNode: _focusNode,
          controller: widget.controller,
          decoration: InputDecoration(
            isDense: true,
            labelText: widget.decoration?.labelText,
            helperText: widget.decoration?.helperText,
            hintText: widget.decoration?.hintText,
            prefixIcon: widget.decoration?.prefixIcon,
            suffixIcon: widget.decoration?.suffixIcon,
            focusedBorder: const GradientUnderlineInputBorder(
              borderSide: BorderSide(width: 4, color: Colors.transparent),
              gradient: LinearGradient(
                colors: [
                  Color(0xff7068f8),
                  Color(0xffb090d5),
                  Color(0xffece1f6),
                  Color(0xff0966d6),
                  Color(0xff95d1f7),
                  Color(0xffe6f6ff),
                  Color(0xff7068f8),
                ],
              ),
            ),
          ),
          onTap: widget.onTap,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          obscureText: widget.obscureText,
          validator: widget.validator,
          readOnly: _readOnly,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          onEditingComplete: () {
            setState(() => _readOnly = true);
            widget.onEditingComplete?.call();
          },
        ),
      ),
    );
  }
}

class GradientUnderlineInputBorder extends UnderlineInputBorder {
  const GradientUnderlineInputBorder({required this.gradient, super.borderSide, super.borderRadius});

  final Gradient gradient;

  @override
  UnderlineInputBorder scale(double t) {
    return GradientUnderlineInputBorder(
      gradient: gradient,
      borderSide: borderSide.scale(t),
      borderRadius: borderRadius * t,
    );
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    if (borderSide.style == BorderStyle.none) {
      return;
    }

    final alignInsideOffset = Offset(0, borderSide.width / 2);
    canvas.drawLine(
      rect.bottomLeft - alignInsideOffset,
      rect.bottomRight - alignInsideOffset,
      borderSide.copyWith(color: Colors.white).toPaint()..shader = gradient.createShader(rect),
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is GradientUnderlineInputBorder) {
      return GradientUnderlineInputBorder(
        gradient: Gradient.lerp(gradient, a.gradient, t)!,
        borderSide: BorderSide.lerp(borderSide, a.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, a.borderRadius, t)!,
      );
    }
    if (a is UnderlineInputBorder) {
      return GradientUnderlineInputBorder(
        gradient: gradient,
        borderSide: BorderSide.lerp(borderSide, a.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, a.borderRadius, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is GradientUnderlineInputBorder) {
      return GradientUnderlineInputBorder(
        gradient: Gradient.lerp(gradient, b.gradient, t)!,
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
      );
    }
    if (b is UnderlineInputBorder) {
      return GradientUnderlineInputBorder(
        gradient: gradient,
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
      );
    }
    return super.lerpTo(b, t);
  }
}
