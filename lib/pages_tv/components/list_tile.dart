import 'package:flutter/material.dart';

class TVListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final bool? autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final bool selected;

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
  });

  @override
  State<TVListTile> createState() => _TVListTileState();
}

class _TVListTileState extends State<TVListTile> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
      autofocus: widget.autofocus ?? false,
      selected: widget.selected,
      selectedColor: Colors.black,
      selectedTileColor: focused ? Theme.of(context).colorScheme.inverseSurface : Theme.of(context).colorScheme.onSurfaceVariant,
      visualDensity: VisualDensity.compact,
      iconColor: focused
          ? Colors.black
          : widget.onTap == null
              ? Colors.grey
              : null,
      textColor: focused
          ? Colors.black
          : widget.onTap == null
              ? Colors.grey
              : null,
      tileColor: focused ? Theme.of(context).colorScheme.inverseSurface : null,
      onTap: widget.onTap,
      focusNode: widget.focusNode,
      onFocusChange: (f) {
        if (focused != f) setState(() => focused = f);
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

  @override
  State<TVRadioListTile<T>> createState() => _TVRadioListTileState<T>();
}

class _TVRadioListTileState<T> extends State<TVRadioListTile<T>> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return RadioListTile(
      value: widget.value,
      groupValue: widget.groupValue,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
      autofocus: widget.autofocus ?? false,
      selected: widget.selected,
      selectedTileColor: focused ? Theme.of(context).colorScheme.inverseSurface : Theme.of(context).colorScheme.onSurfaceVariant,
      visualDensity: VisualDensity.compact,
      tileColor: focused ? Theme.of(context).colorScheme.inverseSurface : null,
      focusNode: widget.focusNode,
      onFocusChange: (f) {
        if (focused != f) setState(() => focused = f);
        if (widget.onFocusChange != null) widget.onFocusChange!(f);
      },
      title: widget.title != null
          ? DefaultTextStyle(
              style: TextStyle(color: focused ? Colors.black : null),
              child: widget.title!,
            )
          : null,
      subtitle: widget.subtitle != null ? Opacity(opacity: 0.75, child: widget.subtitle) : null,
      onChanged: widget.onChanged,
    );
  }
}
