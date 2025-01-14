import 'package:flutter/material.dart';

class TVFilledButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Widget? icon;
  final bool? autofocus;
  final FocusNode? focusNode;

  const TVFilledButton({
    super.key,
    required this.onPressed,
    this.child,
    this.icon,
    this.autofocus,
    this.focusNode,
  });

  factory TVFilledButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    Widget? icon,
    required Widget label,
  }) {
    return TVFilledButton(
      key: key,
      onPressed: onPressed,
      icon: icon,
      child: label,
    );
  }

  @override
  State<TVFilledButton> createState() => _TVFilledButtonState();
}

class _TVFilledButtonState extends State<TVFilledButton> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.inverseSurface,
      shape: StadiumBorder(
        side: focused ? BorderSide(width: 2, color: Theme.of(context).colorScheme.inverseSurface, strokeAlign: 3) : BorderSide.none,
      ),
      textStyle: const TextStyle(color: Colors.black),
      child: InkWell(
        autofocus: widget.autofocus ?? false,
        onFocusChange: (f) {
          if (focused != f) {
            setState(() => focused = f);
          }
        },
        focusNode: widget.focusNode,
        customBorder: const StadiumBorder(),
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: widget.icon == null
              ? widget.child
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconTheme.merge(data: const IconThemeData(color: Colors.black), child: widget.icon!),
                    const SizedBox(width: 6),
                    if (widget.child != null) widget.child!,
                  ],
                ),
        ),
      ),
    );
  }
}
