import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'focusable.dart';

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
  bool _focused = false;
  late final _animation = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  final _animationController = StreamController<bool>();
  late final _animationStream =
      _animationController.stream.switchMap((s) {
        if (s) {
          return Stream.fromFuture(Future.delayed(const Duration(milliseconds: 200))).map((_) => true);
        } else {
          return Stream.value(false);
        }
      }).distinct();
  StreamSubscription<bool>? _animationSubscription;

  @override
  void initState() {
    super.initState();
    _animationSubscription = _animationStream.listen((flag) {
      if (flag) {
        _animation.repeat();
      } else {
        _animation.stop();
      }
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    _animationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListTile(
          dense: widget.dense,
          shape: GradientRoundedRectangleBorder(
            side: _focused ? const BorderSide(width: 4, strokeAlign: 2) : BorderSide.none,
            gradient: SweepGradient(
              colors: const [
                Color(0xff7068f8),
                Color(0xffb090d5),
                Color(0xffd0b1ef),
                Color(0xff0966d6),
                Color(0xff95d1f7),
                Color(0xff91def1),
                Color(0xff7068f8),
              ],
              transform: GradientRotation(2 * pi * _animation.value),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          autofocus: widget.autofocus ?? false,
          visualDensity: VisualDensity.compact,
          onTap: widget.onTap,
          focusNode: widget.focusNode,
          onFocusChange: (f) {
            if (_focused != f) {
              _animationController.add(f);
              setState(() => _focused = f);
            }
            if (widget.onFocusChange != null) widget.onFocusChange!(f);
          },
          title: widget.title,
          subtitle: widget.subtitle != null ? Opacity(opacity: 0.75, child: widget.subtitle) : null,
          leading: widget.leading,
          trailing: widget.trailing,
        );
      },
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
