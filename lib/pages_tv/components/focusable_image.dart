import 'package:flutter/material.dart';

import '../../components/async_image.dart';
import 'focusable.dart';

class FocusableImage extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Focusable(
      width: width,
      height: height,
      selected: selected,
      autofocus: autofocus,
      onTap: onTap,
      onFocusChange: onFocusChange,
      child:
          poster != null
              ? AsyncImage(
                poster!,
                width: width,
                height: height,
                fit: fit,
                padding: padding,
                httpHeaders: httpHeaders,
                ink: true,
                radius: BorderRadius.circular(6),
              )
              : Center(
                child: Icon(placeholderIcon, size: 50, color: Theme.of(context).colorScheme.surfaceContainerHigh),
              ),
    );
  }
}
