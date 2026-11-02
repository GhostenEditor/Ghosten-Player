import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../menus/abstract.dart';
import 'list_tile.dart';

enum ActionSide { start, end }

class ActionListTile extends StatefulWidget {
  const ActionListTile({
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

  final bool autofocus;
  final bool selected;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final Menu actions;
  final ActionSide actionSide;

  @override
  State<ActionListTile> createState() => _ActionListTileState();
}

class _ActionListTileState extends State<ActionListTile> with SingleTickerProviderStateMixin {
  final _actionsFocusNode = FocusNode();
  final _focusNode = FocusNode();
  late final _controller = SlidableController(this);
  bool _focused = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _actionsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ListTile> actions = widget.actions.build(context).cast<ListTile>();
    return Focus(
      skipTraversal: true,
      onFocusChange: (f) {
        if (!f) {
          _controller.close(duration: const Duration(milliseconds: 400));
        }
        if (_focused != f) {
          setState(() => _focused = f);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Slidable(
            controller: _controller,
            startActionPane: actions.isNotEmpty && widget.actionSide == ActionSide.start
                ? ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: (56 * actions.length) / constraints.maxWidth,
                    children: actions.reversed.map(_buildAction).toList(),
                  )
                : null,
            endActionPane: actions.isNotEmpty && widget.actionSide == ActionSide.end
                ? ActionPane(
                    extentRatio: (56 * actions.length) / constraints.maxWidth,
                    motion: const BehindMotion(),
                    children: actions.map(_buildAction).toList(),
                  )
                : null,
            child: Actions(
              actions: {
                DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
                  onInvoke: (indent) {
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
                  },
                ),
              },
              child: Stack(
                alignment: switch (widget.actionSide) {
                  ActionSide.start => Alignment.centerLeft,
                  ActionSide.end => Alignment.centerRight,
                },
                children: [
                  ListTile(
                    autofocus: widget.autofocus,
                    title: widget.title,
                    subtitle: widget.subtitle,
                    leading: widget.leading,
                    trailing: widget.trailing,
                    selected: widget.selected || _focused,
                    onTap:
                        widget.onTap ??
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
                  if (_focused && actions.isNotEmpty) const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAction(ListTile action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        child: IconButton.filledTonal(
          icon: action.leading!,
          onPressed: action.enabled
              ? () {
                  action.onTap?.call();
                  _controller.close(duration: const Duration(milliseconds: 400));
                }
              : null,
        ),
      ),
    );
  }
}
