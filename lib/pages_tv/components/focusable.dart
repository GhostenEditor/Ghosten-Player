import 'package:flutter/material.dart';

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

class _FocusableState extends State<Focusable> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: widget.selected ?? false
            ? (widget.selectedBackgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest)
            : (widget.backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow),
        shape: RoundedRectangleBorder(
          side: _focused ? BorderSide(width: 4, color: Theme.of(context).colorScheme.inverseSurface, strokeAlign: 2) : BorderSide.none,
          borderRadius: BorderRadius.circular(6),
        ),
        child: InkWell(
          autofocus: widget.autofocus ?? false,
          onFocusChange: (f) {
            if (_focused != f) setState(() => _focused = f);
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
