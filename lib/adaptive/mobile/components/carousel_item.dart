import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/components.dart ';
import '../../../previews/previews.dart';
import '../../../subtitles/recommendation.dart';

class CarouselItem extends StatelessWidget {
  const CarouselItem({super.key, this.item, this.onPressed});

  final MediaRecommendation? item;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double imageHeight = max(min(size.width / 4, 240.0), 140.0);
    final double imageWidth = imageHeight * 0.667;
    final MediaRecommendation? item = this.item;
    return item != null
        ? GestureDetector(
            onTap: onPressed,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ThemeBuilder(
                    item.themeColor,
                    builder: (context) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: size.width / 30,
                      children: [
                        if (item.poster != null)
                          AsyncImage(
                            item.poster!,
                            width: imageWidth,
                            height: imageHeight,
                            radius: const BorderRadius.all(Radius.circular(6)),
                          )
                        else
                          const SizedBox(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 2,
                            children: [
                              DefaultTextStyle(
                                style: Theme.of(context).textTheme.labelSmall!,
                                overflow: TextOverflow.ellipsis,
                                child: Text.rich(
                                  TextSpan(
                                    children: item.genres
                                        .map(
                                          (genre) => TextSpan(
                                            text: '${genre.name} ',
                                            style: Theme.of(context).textTheme.labelSmall,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                              DefaultTextStyle(
                                style: Theme.of(context).textTheme.titleMedium!,
                                overflow: TextOverflow.ellipsis,
                                child: Text(item.displayTitle()),
                              ),
                              RecommendationSubtitle(
                                item: item,
                                style: Theme.of(context).textTheme.labelSmall,
                                iconSize: 14,
                              ),
                              if (item.overview != null)
                                DefaultTextStyle(
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(0xB3)),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  child: Text(item.overview!),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : const _CarouselPlaceholder();
  }
}

class _CarouselPlaceholder extends StatelessWidget {
  const _CarouselPlaceholder();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double imageHeight = max(min(size.width / 4, 240.0), 140.0);
    final double imageWidth = imageHeight * 0.667;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double height = min(max(constraints.maxWidth / 2, 200.0), size.height * 0.7);
        return SizedBox(
          height: height,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: size.width / 30,
                        children: [
                          PlaceholderImage(width: imageWidth, height: imageHeight),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  spacing: 4,
                                  children: List.generate(5, (index) => const PlaceholderRRect(width: 24, height: 12)),
                                ),
                                const SizedBox(height: 6),
                                const FractionallySizedBox(widthFactor: 0.6, child: PlaceholderRRect(height: 20)),
                                const SizedBox(height: 6),
                                const Row(
                                  children: [
                                    PlaceholderRRect(width: 40, height: 12),
                                    SizedBox(width: 12),
                                    PlaceholderRRect(width: 12, height: 12),
                                    SizedBox(width: 4),
                                    PlaceholderRRect(width: 20, height: 12),
                                    SizedBox(width: 12),
                                    PlaceholderRRect(width: 36, height: 12),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: List.generate(
                                    4,
                                    (index) => FractionallySizedBox(
                                      widthFactor: Random().nextDouble() * 0.2 + 0.7,
                                      child: const PlaceholderRRect(height: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

@AppPreview(group: 'Carousel Item (Mobile)', name: 'Default', size: Size(600, 260))
Widget carouselItemPreview() {
  return Material(
    child: CarouselItem(
      item: MediaRecommendation.fromJson([
        0,
        'Title',
        'Subtitle',
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam luctus, ipsum in vulputate fermentum, ipsum sapien aliquam metus, pulvinar mollis lorem erat sed nisl. Sed sollicitudin erat velit, non scelerisque elit ullamcorper sed. Aliquam augue orci, sagittis in tristique non, varius sit amet urna. Nunc id hendrerit erat, sed tristique nisl. Nulla ac urna cursus, consequat sapien sed, blandit orci. Nam massa arcu, hendrerit et pretium at, auctor nec urna. Proin sit amet libero sit amet mi pretium imperdiet ac non nisl. Quisque ut turpis pulvinar, euismod augue vel, pellentesque mi. Phasellus tincidunt lacinia pulvinar. Integer volutpat convallis purus a auctor. In rutrum accumsan euismod.',
        'https://picsum.photos/id/236/200/300',
        null,
        null,
        8,
        0,
        null,
        'Ended',
        [2009, 199],
        [],
        [null, null],
      ]),
    ),
  );
}

@AppPreview(group: 'Carousel Item (Mobile)', name: 'Loading', size: Size(600, 260))
Widget carouselItemLoadingPreview() {
  return const CarouselItem();
}
