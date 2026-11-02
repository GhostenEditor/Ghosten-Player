import 'package:flutter/material.dart';

import '_fluid_focusable.dart';

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
  final _focusNode = FocusNode(debugLabel: 'Focusable');
  late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (intent) => widget.onTap?.call()),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (intent) => widget.onTap?.call()),
  };

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FluidFocusable(
        focusNode: _focusNode,
        selected: widget.selected,
        backgroundColor: widget.backgroundColor,
        selectedBackgroundColor: widget.selectedBackgroundColor,
        child: Actions(
          actions: _actionMap,
          child: Focus(
            focusNode: _focusNode,
            autofocus: widget.autofocus ?? false,
            onFocusChange: widget.onFocusChange,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
