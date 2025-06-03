import 'package:flutter/material.dart';

class TVTextButton extends StatefulWidget {
  const TVTextButton({super.key, required this.onPressed, required this.child, this.autofocus = false});

  final VoidCallback? onPressed;
  final Widget child;
  final bool autofocus;

  @override
  State<TVTextButton> createState() => _TVTextButtonState();
}

class _TVTextButtonState extends State<TVTextButton> {
  bool _focused = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focused != _focusNode.hasFocus) {
        setState(() {
          _focused = _focusNode.hasFocus;
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
    return TextButton(
      autofocus: widget.autofocus,
      focusNode: _focusNode,
      onPressed: widget.onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        side:
            _focused ? BorderSide(width: 2, color: Theme.of(context).colorScheme.inverseSurface, strokeAlign: 2) : null,
        visualDensity: VisualDensity.compact,
      ),
      child: widget.child,
    );
  }
}
