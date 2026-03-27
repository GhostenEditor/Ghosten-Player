import 'package:flutter/material.dart';

import '../../../components/gap.dart';
import '../../components/focusable_image.dart';

class MediaGridItem extends StatefulWidget {
  const MediaGridItem({
    super.key,
    this.onTap,
    this.imageUrl,
    this.title,
    this.subtitle,
    this.imageWidth,
    this.imageHeight,
    this.autofocus,
    this.placeholderIcon = Icons.image_not_supported_outlined,
    this.floating,
    this.padding,
  });

  final String? imageUrl;
  final Widget? title;
  final Widget? subtitle;
  final double? imageWidth;
  final double? imageHeight;
  final bool? autofocus;
  final GestureTapCallback? onTap;
  final IconData placeholderIcon;
  final Widget? floating;
  final EdgeInsetsGeometry? padding;

  @override
  State<MediaGridItem> createState() => MediaGridItemState();
}

class MediaGridItemState extends State<MediaGridItem> {
  final ValueNotifier<bool> _focused = ValueNotifier(false);

  @override
  void dispose() {
    _focused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FocusableImage(
          key: ValueKey(widget.imageUrl),
          autofocus: widget.autofocus,
          width: widget.imageWidth,
          height: widget.imageHeight,
          poster: widget.imageUrl,
          onTap: widget.onTap,
          placeholderIcon: widget.placeholderIcon,
          onFocusChange: (f) => _focused.value = f,
        ),
        Gap.vSM,
        if (widget.title != null)
          ListenableBuilder(
            listenable: _focused,
            builder: (context, child) {
              return DefaultTextStyle(
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _focused.value ? null : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
                child: child!,
              );
            },
            child: widget.title,
          ),
        if (widget.subtitle != null)
          DefaultTextStyle(
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
            child: widget.subtitle!,
          ),
      ],
    );
    if (widget.floating != null) {
      return Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: Stack(children: [child, IgnorePointer(child: widget.floating)]),
      );
    } else {
      return Padding(padding: widget.padding ?? EdgeInsets.zero, child: child);
    }
  }
}
