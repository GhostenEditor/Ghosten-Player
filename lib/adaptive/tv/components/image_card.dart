import 'package:flutter/material.dart';

import '../../../components/components.dart ';
import '../../../previews/previews.dart';
import '_focusable.dart';

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
    this.direction,
    this.onLongPress,
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
  final Axis? direction;
  final bool autofocus;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final image = Focusable(
      width: width,
      height: height,
      onTap: onTap,
      autofocus: autofocus,
      backgroundColor: backgroundColor,
      child: Stack(
        children: [
          if (src != null)
            AsyncImage(
              src!,
              width: width,
              height: height,
              fit: fit ?? BoxFit.cover,
              padding: padding ?? EdgeInsets.zero,
              radius: const BorderRadius.all(Radius.circular(8)),
              ink: true,
            )
          else
            IconTheme(
              data: IconThemeData(color: Theme.of(context).colorScheme.surfaceContainerHighest, size: 60),
              child: Center(child: placeholder ?? const Icon(Icons.image_outlined)),
            ),
          ?floating,
        ],
      ),
    );
    final text = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            DefaultTextStyle(
              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              child: title!,
            ),
          if (subtitle != null)
            DefaultTextStyle(
              style: Theme.of(context).textTheme.labelSmall!,
              overflow: TextOverflow.ellipsis,
              child: subtitle!,
            ),
        ],
      ),
    );
    return switch (direction ?? .vertical) {
      Axis.horizontal => Row(
        spacing: 16,
        crossAxisAlignment: .start,
        children: [
          image,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                if (title != null)
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    child: title!,
                  ),
                if (subtitle != null)
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.labelSmall!,
                    overflow: TextOverflow.ellipsis,
                    child: subtitle!,
                  ),
              ],
            ),
          ),
        ],
      ),
      Axis.vertical => SizedBox(
        width: width,
        child: Column(spacing: 8, mainAxisSize: MainAxisSize.min, children: [image, text]),
      ),
    };
  }
}

class ImageCardPlaceholder extends StatelessWidget {
  const ImageCardPlaceholder({super.key, this.size});

  final Size? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size?.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          PlaceholderImage(width: size?.width, height: size?.height),
          const FractionallySizedBox(
            widthFactor: 0.9,
            child: PlaceholderRRect(height: 16, borderRadius: BorderRadius.all(Radius.circular(6))),
          ),
          const FractionallySizedBox(
            widthFactor: 0.6,
            child: PlaceholderRRect(height: 10, borderRadius: BorderRadius.all(Radius.circular(4))),
          ),
        ],
      ),
    );
  }
}

@AppPreview(group: 'Image Card (TV)', name: 'Default')
Widget imageCardDefaultPreview() {
  return const ImageCard(
    src: 'https://picsum.photos/200/300',
    title: Text('Title'),
    subtitle: Text('Subtitle'),
    width: 200,
    height: 300,
    autofocus: true,
  );
}

@AppPreview(group: 'Image Card (TV)', name: 'Horizontal', size: Size.fromWidth(500))
Widget imageCardHorizontalPreview() {
  return const ImageCard(
    src: 'https://picsum.photos/240/135',
    title: Text('Title'),
    subtitle: Text(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam luctus, ipsum in vulputate fermentum, ipsum sapien aliquam metus, pulvinar mollis lorem erat sed nisl.',
    ),
    width: 240,
    height: 135,
    autofocus: true,
    direction: .horizontal,
  );
}

@AppPreview(group: 'Image Card (TV)', name: 'No Image')
Widget imageCardNoImagePreview() {
  return const ImageCard(title: Text('Title'), subtitle: Text('Subtitle'), width: 200, height: 300);
}

@AppPreview(group: 'Image Card (TV)', name: 'Placeholder')
Widget imageCardPlaceholderPreview() {
  return const ImageCardPlaceholder(size: Size(200, 300));
}
