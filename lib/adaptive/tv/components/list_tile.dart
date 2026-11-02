import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart' hide ListTile;

import '_fluid_focusable.dart';

class ListTile extends StatefulWidget {
  const ListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.autofocus = true,
    this.enabled = true,
    this.focusNode,
    this.onFocusChange,
    this.selected = false,
    this.dense,
    this.minLeadingWidth,
    this.leadingAndTrailingTextStyle,
    this.titleTextStyle,
    this.contentPadding,
    this.selectedColor,
    this.selectedTileColor,
    this.onLongPress,
    this.minTileHeight,
    this.isThreeLine,
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
  final bool enabled;
  final bool? dense;
  final double? minLeadingWidth;
  final TextStyle? leadingAndTrailingTextStyle;
  final TextStyle? titleTextStyle;
  final EdgeInsetsGeometry? contentPadding;
  final Color? selectedColor;
  final Color? selectedTileColor;
  final GestureLongPressCallback? onLongPress;
  final double? minTileHeight;
  final bool? isThreeLine;

  @override
  State<ListTile> createState() => _ListTileState();
}

class _ListTileState extends State<ListTile> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'ListTile');

  @override
  void dispose() {
    super.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listTile = m.ListTile(
      dense: widget.dense,
      selected: widget.selected,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      focusNode: _focusNode,
      onFocusChange: widget.onFocusChange,
      title: widget.title,
      minLeadingWidth: widget.minLeadingWidth,
      selectedColor: widget.selectedColor,
      selectedTileColor: widget.selectedTileColor ?? Theme.of(context).colorScheme.secondaryContainer,
      leadingAndTrailingTextStyle: widget.leadingAndTrailingTextStyle,
      titleTextStyle: widget.titleTextStyle,
      contentPadding: widget.contentPadding,
      subtitle: widget.subtitle,
      leading: widget.leading,
      trailing: widget.trailing,
      minTileHeight: widget.minTileHeight,
      isThreeLine: widget.isThreeLine,
    );
    return widget.onTap != null
        ? FluidFocusable(focusNode: _focusNode, backgroundColor: Colors.transparent, child: listTile)
        : listTile;
  }
}
