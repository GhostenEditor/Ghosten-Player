import 'package:flutter/material.dart';

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

class _TVListTileState extends State<TVListTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: widget.dense,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
      autofocus: widget.autofocus ?? false,
      selected: widget.selected,
      selectedColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      selectedTileColor:
          _focused ? Theme.of(context).colorScheme.inverseSurface : Theme.of(context).colorScheme.onSurfaceVariant,
      visualDensity: VisualDensity.compact,
      iconColor:
          _focused
              ? Theme.of(context).colorScheme.surfaceContainerLowest
              : widget.onTap == null
              ? Colors.grey
              : null,
      textColor:
          _focused
              ? Theme.of(context).colorScheme.surfaceContainerLowest
              : widget.onTap == null
              ? Colors.grey
              : null,
      tileColor: _focused ? Theme.of(context).colorScheme.inverseSurface : null,
      onTap: widget.onTap,
      focusNode: widget.focusNode,
      onFocusChange: (f) {
        if (_focused != f) setState(() => _focused = f);
        if (widget.onFocusChange != null) widget.onFocusChange!(f);
      },
      title: widget.title,
      subtitle: widget.subtitle != null ? Opacity(opacity: 0.75, child: widget.subtitle) : null,
      leading: widget.leading,
      trailing: widget.trailing,
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
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      value: widget.value,
      groupValue: widget.groupValue,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
      autofocus: widget.autofocus ?? false,
      selected: widget.selected,
      selectedTileColor:
          _focused ? Theme.of(context).colorScheme.inverseSurface : Theme.of(context).colorScheme.onSurfaceVariant,
      visualDensity: VisualDensity.compact,
      tileColor: _focused ? Theme.of(context).colorScheme.inverseSurface : null,
      focusNode: widget.focusNode,
      onFocusChange: (f) {
        if (_focused != f) setState(() => _focused = f);
        if (widget.onFocusChange != null) widget.onFocusChange!(f);
      },
      title:
          widget.title != null
              ? DefaultTextStyle(
                style: TextStyle(
                  color:
                      _focused
                          ? Theme.of(context).colorScheme.surfaceContainerLowest
                          : Theme.of(context).colorScheme.onSurface,
                ),
                child: widget.title!,
              )
              : null,
      subtitle: widget.subtitle != null ? Opacity(opacity: 0.75, child: widget.subtitle) : null,
      onChanged: widget.onChanged,
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
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: widget.value,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
      autofocus: widget.autofocus ?? false,
      selected: widget.selected,
      selectedTileColor:
          _focused ? Theme.of(context).colorScheme.inverseSurface : Theme.of(context).colorScheme.onSurfaceVariant,
      visualDensity: VisualDensity.compact,
      tileColor: _focused ? Theme.of(context).colorScheme.inverseSurface : null,
      focusNode: widget.focusNode,
      onFocusChange: (f) {
        if (_focused != f) setState(() => _focused = f);
        if (widget.onFocusChange != null) widget.onFocusChange!(f);
      },
      title:
          widget.title != null
              ? DefaultTextStyle(
                style: TextStyle(
                  color:
                      _focused
                          ? Theme.of(context).colorScheme.surfaceContainerLowest
                          : Theme.of(context).colorScheme.onSurface,
                ),
                child: widget.title!,
              )
              : null,
      subtitle: widget.subtitle != null ? Opacity(opacity: 0.75, child: widget.subtitle) : null,
      onChanged: widget.onChanged,
    );
  }
}
