import 'package:flutter/material.dart';

import '../../components/async_image.dart';

class FocusableImage extends StatefulWidget {
  final String? poster;
  final double? width;
  final double? height;
  final bool? autofocus;
  final bool? selected;
  final IconData placeholderIcon;
  final BoxFit fit;
  final EdgeInsets padding;
  final GestureTapCallback? onTap;
  final ValueChanged<bool>? onFocusChange;
  final Map<String, String>? httpHeaders;

  const FocusableImage({
    super.key,
    this.poster,
    this.onTap,
    this.width,
    this.height,
    this.autofocus,
    this.placeholderIcon = Icons.image_not_supported_outlined,
    this.onFocusChange,
    this.fit = BoxFit.cover,
    this.padding = EdgeInsets.zero,
    this.selected,
    this.httpHeaders,
  });

  @override
  State<FocusableImage> createState() => _FocusableImageState();
}

class _FocusableImageState extends State<FocusableImage> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: widget.selected == true ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          side: focused ? BorderSide(width: 4, color: Theme.of(context).colorScheme.inverseSurface, strokeAlign: 2) : BorderSide.none,
          borderRadius: BorderRadius.circular(6),
        ),
        child: InkWell(
          autofocus: widget.autofocus ?? false,
          onFocusChange: (f) {
            if (focused != f) setState(() => focused = f);
            if (widget.onFocusChange != null) widget.onFocusChange!(f);
          },
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          onTap: widget.onTap,
          child: widget.poster != null
              ? AsyncImage(
                  widget.poster!,
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit,
                  padding: widget.padding,
                  httpHeaders: widget.httpHeaders,
                  ink: true,
                  radius: BorderRadius.circular(6),
                )
              : Center(child: Icon(widget.placeholderIcon, size: 50, color: Theme.of(context).colorScheme.surfaceContainerHigh)),
        ),
      ),
    );
  }
}
