import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/components.dart ';
import '../../../l10n/app_localizations.dart';
import '../../../previews/previews.dart';
import '../../../utils/utils.dart';

class CarouselItem extends StatelessWidget {
  const CarouselItem({super.key, this.item, this.onPressed});

  final MediaRecommendation? item;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final MediaRecommendation? item = this.item;
    return item != null
        ? ThemeBuilder(
            item.themeColor,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 100,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 6,
                        children: [
                          DefaultTextStyle(
                            style: Theme.of(context).textTheme.labelSmall!,
                            child: Row(spacing: 8, children: item.genres.map((genre) => Text(genre.name)).toList()),
                          ),
                          DefaultTextStyle(
                            style: Theme.of(context).textTheme.displaySmall!,
                            child: Text(item.displayTitle()),
                          ),
                          DefaultTextStyle(
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                            child: Row(
                              spacing: 16,
                              children: [
                                Text(item.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                                Row(
                                  spacing: 4,
                                  children: [
                                    Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 14),
                                    Text(
                                      item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown,
                                    ),
                                  ],
                                ),
                                Text(AppLocalizations.of(context)!.seriesStatus(item.status.name)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (item.overview != null)
                            DefaultTextStyle(
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(0xB3)),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              child: Text(item.overview!),
                            ),
                          const SizedBox(height: 18),
                          Focus(
                            skipTraversal: true,
                            child: FilledButton.icon(
                              onPressed: onPressed,
                              label: Text(AppLocalizations.of(context)!.buttonWatchNow),
                              icon: const Icon(Icons.play_arrow_rounded),
                            ),
                            onFocusChange: (f) {
                              if (f) {
                                Scrollable.ensureVisible(
                                  FocusManager.instance.primaryFocus!.context!,
                                  alignment: 1,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 192,
                      height: 288,
                      child: item.poster != null
                          ? AsyncImage(
                              item.poster!,
                              width: 192,
                              height: 288,
                              radius: BorderRadius.circular(8),
                              errorWidget: (context, _, _) => Card(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.error.withAlpha(0x33),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              );
            },
          )
        : const _CarouselPlaceholder();
  }
}

class _CarouselPlaceholder extends StatelessWidget {
  const _CarouselPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, right: 48, bottom: 32),
      child: SizedBox(
        height: 392,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(spacing: 8, children: List.generate(5, (index) => const PlaceholderRRect(width: 36, height: 12))),
                  const SizedBox(height: 6),
                  const FractionallySizedBox(widthFactor: 0.6, child: PlaceholderRRect(height: 42)),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      PlaceholderRRect(width: 60, height: 12),
                      SizedBox(width: 20),
                      PlaceholderRRect(width: 14, height: 14),
                      SizedBox(width: 4),
                      PlaceholderRRect(width: 20, height: 12),
                      SizedBox(width: 20),
                      PlaceholderRRect(width: 36, height: 12),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 7,
                    children: List.generate(
                      4,
                      (index) => FractionallySizedBox(
                        widthFactor: Random().nextDouble() * 0.2 + 0.7,
                        child: const PlaceholderRRect(height: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const PlaceholderRRect(width: 140, height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
                ],
              ),
            ),
            const PlaceholderImage(width: 192, height: 288),
          ],
        ),
      ),
    );
  }
}

@AppPreview(group: 'Carousel Item (TV)', name: 'Default', size: Size(800, 400))
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
      onPressed: () {},
    ),
  );
}

@AppPreview(group: 'Carousel Item (TV)', name: 'Loading', size: Size(800, 400))
Widget carouselItemLoadingPreview() {
  return const CarouselItem();
}
