// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart' hide RadioListTile;

import '_fluid_focusable.dart';

class RadioListTile<T> extends StatefulWidget {
  const RadioListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
    this.selected = false,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.dense,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final bool selected;
  final bool? dense;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  @override
  State<RadioListTile<T>> createState() => _RadioListTileState<T>();
}

class _RadioListTileState<T> extends State<RadioListTile<T>> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  @override
  void dispose() {
    super.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FluidFocusable(
      focusNode: _focusNode,
      backgroundColor: Colors.transparent,
      child: m.RadioListTile(
        value: widget.value,
        autofocus: widget.autofocus,
        selected: widget.selected,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        groupValue: widget.groupValue,
        dense: widget.dense,
        onFocusChange: widget.onFocusChange,
        title: widget.title,
        subtitle: widget.subtitle,
      ),
    );
  }
}
