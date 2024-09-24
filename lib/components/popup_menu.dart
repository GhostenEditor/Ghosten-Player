import 'package:flutter/material.dart';

class PopupMenuItem<T> extends PopupMenuEntry<T> {
  final T? value;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final bool autofocus;
  final bool enabled;

  const PopupMenuItem({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.value,
    this.onTap,
    this.autofocus = false,
    this.enabled = true,
    this.height = kMinInteractiveDimension,
  });

  @override
  State<PopupMenuItem<T>> createState() => _PopupMenuItemState();

  @override
  final double height;

  @override
  bool represents(T? value) => value == this.value;
}

class _PopupMenuItemState<T, W extends PopupMenuItem<T>> extends State<W> {
  @protected
  void handleTap() {
    Navigator.pop<T>(context, widget.value);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: widget.title,
      trailing: widget.trailing,
      leading: widget.leading,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      onTap: handleTap,
    );
  }
}
