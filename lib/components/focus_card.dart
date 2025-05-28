import 'package:flutter/material.dart';

class FocusCard<T> extends StatefulWidget {
  const FocusCard({
    super.key,
    required this.child,
    this.onTap,
    this.autofocus = false,
    this.width,
    this.height,
    this.itemBuilder,
    this.itemLongPressBuilder,
  });

  final Widget child;

  final GestureTapCallback? onTap;
  final PopupMenuItemBuilder<T>? itemBuilder;
  final PopupMenuItemBuilder<T>? itemLongPressBuilder;
  final double? width;
  final double? height;

  final bool autofocus;

  @override
  State<FocusCard<T>> createState() => _FocusCardState<T>();
}

class _FocusCardState<T> extends State<FocusCard<T>> {
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final child = Container(
      margin: Theme.of(context).cardTheme.margin ?? const EdgeInsets.all(4.0),
      width: widget.width,
      height: widget.height,
      child: Material(
        type: MaterialType.card,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        shadowColor: Theme.of(context).cardTheme.shadowColor,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          focusNode: _focusNode,
          onTap: widget.itemBuilder == null ? widget.onTap : () => _onTap(context, widget.itemBuilder!),
          onLongPress: widget.itemLongPressBuilder == null ? null : () => _onTap(context, widget.itemLongPressBuilder!),
          autofocus: widget.autofocus,
          focusColor: Colors.transparent,
          customBorder: Theme.of(context).cardTheme.shape,
          child: widget.child,
        ),
      ),
    );
    return child;
  }

  void _onTap(BuildContext context, PopupMenuItemBuilder<T> builder) {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + Offset.zero, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final List<PopupMenuEntry<T>> items = builder(context);
    showMenu(context: context, position: position, items: items);
  }
}
