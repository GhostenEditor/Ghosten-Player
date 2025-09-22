import 'dart:math';

import 'package:flutter/material.dart';

import '../../components/async_image.dart';
import '../../components/placeholder.dart';

class ImageCard extends StatelessWidget {
  const ImageCard(
    this.src, {
    super.key,
    this.fit = BoxFit.cover,
    this.onTap,
    this.title,
    this.subtitle,
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.noImageIcon = Icons.image_not_supported_outlined,
    this.floating,
  });

  final String? src;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? title;
  final Widget? subtitle;
  final EdgeInsets padding;
  final Widget? floating;
  final IconData noImageIcon;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: constraints.copyWith(maxWidth: width, minWidth: width),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              ConstrainedBox(
                constraints: constraints.deflate(const EdgeInsets.symmetric(vertical: 21)).copyWith(minHeight: 0),
                child: Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: width ?? double.infinity,
                          height: height ?? double.infinity,
                          child:
                              src != null
                                  ? AsyncImage(
                                    src!,
                                    width: width,
                                    height: height,
                                    fit: fit,
                                    padding: padding,
                                    radius: BorderRadius.circular(6),
                                    ink: true,
                                  )
                                  : Icon(
                                    noImageIcon,
                                    size: 50,
                                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                                  ),
                        ),
                        if (floating != null) floating!,
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: onTap,
                customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (title != null)
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.titleSmall!,
                          overflow: TextOverflow.ellipsis,
                          child: title!,
                        ),
                      if (subtitle != null)
                        DefaultTextStyle(
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                          overflow: TextOverflow.ellipsis,
                          child: subtitle!,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ImageCardPlaceholder extends StatelessWidget {
  const ImageCardPlaceholder({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          GPlaceholderImage(width: width, height: height),
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Container(
              height: 16,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white60),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: Container(
              height: 10,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageCardWide extends StatelessWidget {
  const ImageCardWide(
    this.src, {
    super.key,
    this.onTap,
    this.title,
    this.subtitle,
    this.description,
    this.width,
    this.height,
    this.floating,
  });

  final String? src;
  final double? width;
  final double? height;
  final Widget? title;
  final Widget? subtitle;
  final Widget? description;
  final Widget? floating;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: constraints.copyWith(maxHeight: height, minHeight: height),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              ConstrainedBox(
                constraints: constraints
                    .deflate(const EdgeInsets.symmetric(vertical: 21))
                    .copyWith(maxWidth: width, minWidth: width),
                child: Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    child: Stack(
                      children: [
                        if (src != null)
                          AsyncImage(src!, width: width, height: height, radius: BorderRadius.circular(6), ink: true)
                        else
                          SizedBox(
                            width: width,
                            height: height,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 50,
                              color: Theme.of(context).colorScheme.surfaceContainerLow,
                            ),
                          ),
                        if (floating != null) floating!,
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (title != null)
                          DefaultTextStyle(
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            child: title!,
                          ),
                        if (subtitle != null)
                          DefaultTextStyle(
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                            child: subtitle!,
                          ),
                        if (description != null)
                          DefaultTextStyle(
                            style: Theme.of(context).textTheme.bodyMedium!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            child: description!,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ImageCardWidePlaceholder extends StatelessWidget {
  const ImageCardWidePlaceholder({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: constraints.copyWith(maxHeight: height, minHeight: height),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              ConstrainedBox(
                constraints: constraints
                    .deflate(const EdgeInsets.symmetric(vertical: 21))
                    .copyWith(maxWidth: width, minWidth: width),
                child: Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  clipBehavior: Clip.antiAlias,
                  child: GPlaceholderImage(width: width, height: height),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.6,
                        child: Container(height: 20, decoration: GPlaceholderDecoration.base),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(width: 40, height: 12, decoration: GPlaceholderDecoration.base),
                          const SizedBox(width: 4),
                          Container(width: 20, height: 12, decoration: GPlaceholderDecoration.base),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: List.generate(
                          3,
                          (index) => FractionallySizedBox(
                            widthFactor: Random().nextDouble() * 0.2 + 0.7,
                            child: const GPlaceholderRect(height: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
