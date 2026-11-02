import 'package:flutter/material.dart';

import '../../../components/components.dart ';
import '../../../previews/previews.dart';

class ImageCard extends StatelessWidget {
  const ImageCard({
    super.key,
    this.src,
    this.fit,
    this.onTap,
    this.title,
    this.subtitle,
    this.width,
    this.height,
    this.padding,
    this.placeholder,
    this.floating,
    this.onLongPress,
    this.direction = .vertical,
    this.autofocus = false,
    this.backgroundColor,
  });

  final String? src;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget? title;
  final Widget? subtitle;
  final EdgeInsets? padding;
  final Widget? floating;
  final Widget? placeholder;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final Axis direction;
  final bool autofocus;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final double? innerWidth = width != null ? width! - 8 : null;
    final double? innerHeight = height != null ? height! - 8 : null;
    final image = Stack(
      children: [
        if (src != null)
          AsyncImage(
            src!,
            width: innerWidth,
            height: innerHeight,
            fit: fit ?? BoxFit.cover,
            padding: padding ?? EdgeInsets.zero,
            radius: const BorderRadius.all(Radius.circular(8)),
            ink: true,
          )
        else
          Ink(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer,
            ),
            width: innerWidth,
            height: innerHeight,
            child: IconTheme(
              data: IconThemeData(color: Theme.of(context).colorScheme.surfaceContainerHighest, size: 50),
              child: placeholder ?? const Icon(Icons.image_outlined),
            ),
          ),
        ?floating,
      ],
    );
    final text = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 2,
        children: [
          if (title != null)
            DefaultTextStyle(
              style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              child: title!,
            ),
          if (subtitle != null)
            DefaultTextStyle(
              style: Theme.of(context).textTheme.labelSmall!
                  .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(0xAA)),
              overflow: TextOverflow.ellipsis,
              child: subtitle!,
            ),
        ],
      ),
    );
    return Align(
      alignment: .topLeft,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: switch (direction) {
              Axis.horizontal => SizedBox(
                height: innerHeight,
                child: Row(
                  spacing: 4,
                  crossAxisAlignment: .start,
                  children: [
                    image,
                    Expanded(child: text),
                  ],
                ),
              ),
              Axis.vertical => SizedBox(
                width: innerWidth,
                child: Column(spacing: 4, mainAxisSize: MainAxisSize.min, children: [image, text]),
              ),
            },
          ),
        ),
      ),
    );
  }
}

class ImageCardPlaceholder extends StatelessWidget {
  const ImageCardPlaceholder({super.key, this.size});

  final Size? size;

  @override
  Widget build(BuildContext context) {
    final double? innerWidth = size != null ? size!.width - 8 : null;
    final double? innerHeight = size != null ? size!.height - 8 : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: size?.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            PlaceholderImage(width: innerWidth, height: innerHeight),
            const FractionallySizedBox(
              widthFactor: 0.9,
              child: PlaceholderRRect(height: 13, borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
            const SizedBox(height: 2),
            const FractionallySizedBox(
              widthFactor: 0.6,
              child: PlaceholderRRect(height: 10, borderRadius: BorderRadius.all(Radius.circular(3))),
            ),
          ],
        ),
      ),
    );
  }
}

@AppPreview(group: 'Image Card (Mobile)', name: 'Default')
Widget imageCardDefaultPreview() {
  return ImageCard(
    src: 'https://picsum.photos/200/300',
    title: const Text('Title'),
    subtitle: const Text('Subtitle'),
    width: 128,
    height: 188,
    onTap: () {},
  );
}

@AppPreview(group: 'Image Card (Mobile)', name: 'Horizontal', size: Size.fromWidth(400))
Widget imageCardHorizontalPreview() {
  return ImageCard(
    src: 'https://picsum.photos/188/109',
    title: const Text('Title'),
    subtitle: const Text(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam luctus, ipsum in vulputate fermentum, ipsum sapien aliquam metus, pulvinar mollis lorem erat sed nisl.',
    ),
    width: 188,
    height: 109,
    direction: .horizontal,
    onTap: () {},
  );
}

@AppPreview(group: 'Image Card (Mobile)', name: 'No Image')
Widget imageCardNoImagePreview() {
  return ImageCard(title: const Text('Title'), subtitle: const Text('Subtitle'), width: 128, height: 188, onTap: () {});
}

@AppPreview(group: 'Image Card (Mobile)', name: 'Placeholder')
Widget imageCardPlaceholderPreview() {
  return const ImageCardPlaceholder(size: Size(128, 188));
}
