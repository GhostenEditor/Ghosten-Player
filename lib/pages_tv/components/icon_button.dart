import 'package:flutter/material.dart';

enum _IconButtonVariant { standard, filled, filledTonal, outlined }

class TVIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final bool autofocus;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;
  final _IconButtonVariant _variant;

  const TVIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.autofocus = false,
    this.visualDensity,
    this.padding,
    this.minimumSize,
  }) : _variant = _IconButtonVariant.standard;

  const TVIconButton.filledTonal({
    super.key,
    required this.onPressed,
    required this.icon,
    this.autofocus = false,
    this.visualDensity,
    this.padding,
    this.minimumSize,
  }) : _variant = _IconButtonVariant.filledTonal;

  @override
  State<TVIconButton> createState() => _TVIconButtonState();
}

class _TVIconButtonState extends State<TVIconButton> {
  bool focused = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (focused != _focusNode.hasFocus) {
        setState(() {
          focused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = IconButton.styleFrom(
      side: focused ? BorderSide(width: 4, color: Theme.of(context).colorScheme.inverseSurface, strokeAlign: 2) : null,
      minimumSize: widget.minimumSize,
    );
    switch (widget._variant) {
      case _IconButtonVariant.standard:
        return IconButton(
          onPressed: widget.onPressed,
          icon: widget.icon,
          autofocus: widget.autofocus,
          style: style,
          focusNode: _focusNode,
          padding: widget.padding,
          visualDensity: widget.visualDensity,
        );
      case _IconButtonVariant.filled:
        return IconButton.filled(
          onPressed: widget.onPressed,
          icon: widget.icon,
          autofocus: widget.autofocus,
          style: style,
          focusNode: _focusNode,
          padding: widget.padding,
          visualDensity: widget.visualDensity,
        );
      case _IconButtonVariant.filledTonal:
        return IconButton.filledTonal(
          onPressed: widget.onPressed,
          icon: widget.icon,
          autofocus: widget.autofocus,
          style: style,
          focusNode: _focusNode,
          padding: widget.padding,
          visualDensity: widget.visualDensity,
        );
      case _IconButtonVariant.outlined:
        return IconButton.outlined(
          onPressed: widget.onPressed,
          icon: widget.icon,
          autofocus: widget.autofocus,
          style: style,
          focusNode: _focusNode,
          padding: widget.padding,
          visualDensity: widget.visualDensity,
        );
    }
  }
}
