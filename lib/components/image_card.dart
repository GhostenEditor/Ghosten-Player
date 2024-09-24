import 'package:flutter/material.dart';

import 'async_image.dart';
import 'focus_card.dart';

class ImageCard extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final ValueChanged<bool>? onFocusChange;
  final double? scale;
  final bool autofocus;
  final String? image;
  final double? width;
  final double? height;
  final double iconSize;

  const ImageCard({
    super.key,
    required this.child,
    this.onTap,
    this.onFocusChange,
    this.scale,
    this.autofocus = false,
    required this.image,
    this.width,
    this.height,
    this.iconSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    return FocusCard(
      scale: scale,
      autofocus: autofocus,
      onTap: onTap,
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: image != null
                  ? AsyncImage(image!, ink: true)
                  : Container(
                      color: Theme.of(context).colorScheme.primary.withAlpha(0x11),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: iconSize,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    )),
          Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ],
      ),
    );
  }
}
