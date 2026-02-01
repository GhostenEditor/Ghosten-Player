
import 'package:flutter/material.dart';

import 'fluid_focusable.dart';

class TVListTile extends StatefulWidget {
  const TVListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.autofocus,
    this.focusNode,
    this.onFocusChange,
    this.selected = false,
    this.dense,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final bool? autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final bool selected;
  final bool? dense;

  @override
  State<TVListTile> createState() => _TVListTileState();
}

class _TVListTileState extends State<TVListTile> with SingleTickerProviderStateMixin {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FluidFocusable(
      focusNode: widget.focusNode ?? _focusNode,
      backgroundColor: Colors.transparent,
      child: ListTile(
        dense: widget.dense,
        selected: widget.selected,
        selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
        enabled: widget.onTap != null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        autofocus: widget.autofocus ?? false,
        visualDensity: VisualDensity.compact,
        onTap: widget.onTap,
        focusNode: widget.focusNode ?? _focusNode,
        onFocusChange: widget.onFocusChange,
        title: widget.title,
        subtitle: widget.subtitle != null ? Opacity(opacity: 0.75, child: widget.subtitle) : null,
        leading: widget.leading,
        trailing: widget.trailing,
      ),
    );
  }
}

class TVRadioListTile<T> extends StatefulWidget {
  const TVRadioListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.autofocus,
    this.focusNode,
    this.onFocusChange,
    this.selected = false,
    required this.value,
    this.groupValue,
    this.onChanged,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final bool? autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final bool selected;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  @override
  State<TVRadioListTile<T>> createState() => _TVRadioListTileState<T>();
}

class _TVRadioListTileState<T> extends State<TVRadioListTile<T>> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FluidFocusable(
      focusNode: widget.focusNode ?? _focusNode,
      backgroundColor: Colors.transparent,
      child: RadioListTile(
        value: widget.value,
        groupValue: widget.groupValue,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
        autofocus: widget.autofocus ?? false,
        selected: widget.selected,
        visualDensity: VisualDensity.compact,
        focusNode: widget.focusNode ?? _focusNode,
        onFocusChange: widget.onFocusChange,
        title: widget.title,
        subtitle: widget.subtitle != null ? Opacity(opacity: 0.75, child: widget.subtitle) : null,
        onChanged: widget.onChanged,
      ),
    );
  }
}

class TVSwitchListTile<T> extends StatefulWidget {
  const TVSwitchListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.autofocus,
    this.focusNode,
    this.onFocusChange,
    this.selected = false,
    required this.value,
    this.onChanged,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final bool? autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final bool selected;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  State<TVSwitchListTile<T>> createState() => _TVSwitchListTileState<T>();
}

class _TVSwitchListTileState<T> extends State<TVSwitchListTile<T>> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FluidFocusable(
      focusNode: widget.focusNode ?? _focusNode,
      backgroundColor: Colors.transparent,
      child: SwitchListTile(
        value: widget.value,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
        autofocus: widget.autofocus ?? false,
        selected: widget.selected,
        visualDensity: VisualDensity.compact,
        focusNode: widget.focusNode ?? _focusNode,
        onFocusChange: widget.onFocusChange,
        title: widget.title,
        subtitle: widget.subtitle != null ? Opacity(opacity: 0.75, child: widget.subtitle) : null,
        onChanged: widget.onChanged,
      ),
    );
  }
}
