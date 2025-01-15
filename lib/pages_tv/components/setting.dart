import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'icon_button.dart';
import 'list_tile.dart';

class ButtonSettingItem extends StatelessWidget {
  final bool selected;
  final bool autofocus;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final GestureTapCallback? onTap;

  const ButtonSettingItem({
    super.key,
    required this.title,
    this.autofocus = false,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return TVListTile(
      autofocus: autofocus,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      selected: selected,
    );
  }
}

enum ActionSide { start, end }

class SlidableSettingItem extends StatefulWidget {
  final bool autofocus;
  final bool selected;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final List<TVIconButton> actions;
  final ActionSide actionSide;

  const SlidableSettingItem({
    super.key,
    required this.title,
    this.autofocus = false,
    this.selected = false,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.actionSide = ActionSide.end,
    required this.actions,
  });

  @override
  State<SlidableSettingItem> createState() => _SlidableSettingItemState();
}

class _SlidableSettingItemState extends State<SlidableSettingItem> with SingleTickerProviderStateMixin {
  final _actionsFocusNode = FocusNode();
  final _focusNode = FocusNode();
  late final _controller = SlidableController(this);
  bool focused = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _actionsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      skipTraversal: true,
      onFocusChange: (f) {
        if (!f) {
          _controller.close(duration: const Duration(milliseconds: 400));
        }
        if (focused != f) {
          setState(() => focused = f);
        }
      },
      child: Slidable(
        controller: _controller,
        startActionPane: widget.actionSide == ActionSide.start
            ? ActionPane(
                motion: const BehindMotion(),
                extentRatio: widget.actions.length * 0.16,
                children: widget.actions.map((action) => Padding(padding: const EdgeInsets.only(right: 4), child: action)).toList(),
              )
            : null,
        endActionPane: widget.actionSide == ActionSide.end
            ? ActionPane(
                extentRatio: widget.actions.length * 0.16,
                motion: const BehindMotion(),
                children: widget.actions.map((action) => Padding(padding: const EdgeInsets.only(left: 4), child: action)).toList(),
              )
            : null,
        child: Material(
          type: MaterialType.transparency,
          child: Actions(
            actions: {
              DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(onInvoke: (indent) {
                switch (indent.direction) {
                  case TraversalDirection.left:
                    if (_controller.direction.value == 0 && widget.actionSide == ActionSide.start) {
                      _controller.openStartActionPane(duration: const Duration(milliseconds: 400));
                      return null;
                    }
                  case TraversalDirection.right:
                    if (_controller.direction.value == 0 && widget.actionSide == ActionSide.end) {
                      _controller.openEndActionPane(duration: const Duration(milliseconds: 400));
                      return null;
                    }
                  case TraversalDirection.up:
                  case TraversalDirection.down:
                }
                FocusManager.instance.primaryFocus?.focusInDirection(indent.direction);
                return null;
              }),
            },
            child: Stack(
              alignment: switch (widget.actionSide) {
                ActionSide.start => Alignment.centerLeft,
                ActionSide.end => Alignment.centerRight,
              },
              children: [
                TVListTile(
                  autofocus: widget.autofocus,
                  title: widget.title,
                  subtitle: widget.subtitle,
                  leading: widget.leading,
                  trailing: widget.trailing,
                  selected: widget.selected || focused,
                  onTap: widget.onTap ??
                      () {
                        if (_controller.direction.value == 0) {
                          switch (widget.actionSide) {
                            case ActionSide.start:
                              _controller.openStartActionPane(duration: const Duration(milliseconds: 400));

                            case ActionSide.end:
                              _controller.openEndActionPane(duration: const Duration(milliseconds: 400));
                          }
                        } else {
                          _controller.close(duration: const Duration(milliseconds: 400));
                        }
                      },
                  focusNode: _focusNode,
                ),
                if (focused) Icon(Icons.more_vert_rounded, color: Colors.grey, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RadioSettingItem<T> extends StatelessWidget {
  final bool autofocus;
  final Widget title;
  final Widget? leading;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  const RadioSettingItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.groupValue,
    this.autofocus = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return TVRadioListTile(
      autofocus: autofocus,
      title: title,
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}

class SwitchSettingItem extends StatelessWidget {
  final bool autofocus;
  final Widget title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SwitchSettingItem({
    super.key,
    required this.title,
    required this.onChanged,
    this.autofocus = false,
    this.value = false,
  });

  @override
  Widget build(BuildContext context) {
    return TVListTile(
      autofocus: autofocus,
      title: title,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class IconButtonSettingItem extends StatelessWidget {
  final bool autofocus;
  final Widget icon;
  final VoidCallback? onPressed;

  const IconButtonSettingItem({
    super.key,
    required this.icon,
    this.autofocus = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TVIconButton.filledTonal(
        autofocus: autofocus,
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }
}

class StepperSettingItem extends StatelessWidget {
  final Widget title;
  final int value;
  final int? max;
  final int? min;
  final int step;
  final ValueChanged<int>? onChanged;

  const StepperSettingItem({
    super.key,
    required this.title,
    this.max,
    this.min,
    this.step = 1,
    this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TVListTile(
      title: title,
      trailing: Focus(
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent || event is KeyRepeatEvent) {
            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowLeft:
                if (min == null || value > min! && onChanged != null) {
                  onChanged!(clamp(value - step));
                }
                return KeyEventResult.handled;
              case LogicalKeyboardKey.arrowRight:
                if (max == null || value < max! && onChanged != null) {
                  onChanged!(clamp(value + step));
                }
                return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(1000)),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: min == null || value > min! ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              SizedBox(
                width: 20,
                child: Text(value.toString(), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: max == null || value < max! ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int clamp(int v) {
    if (max != null) {
      v = v < max! ? v : max!;
    }
    if (min != null) {
      v = v > min! ? v : min!;
    }
    return v;
  }
}

class DividerSettingItem extends StatelessWidget {
  const DividerSettingItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(indent: 16, endIndent: 16);
  }
}

class GapSettingItem extends StatelessWidget {
  final double? height;

  const GapSettingItem({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

class SettingPage extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingPage({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 18),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(color: Color(0xff111212), height: 1),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
