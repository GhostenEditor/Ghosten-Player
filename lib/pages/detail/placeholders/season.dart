import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/async_image.dart';
import '../../../components/placeholder.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../components/theme_builder.dart';
import '../components/overview.dart';

class SeasonPlaceholder extends StatelessWidget {
  const SeasonPlaceholder({super.key, this.item});

  final TVSeason? item;

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      item?.themeColor,
      builder:
          (context) => Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              title:
                  item == null
                      ? const SizedBox()
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item!.seriesTitle} ${item!.title ?? ''}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          DefaultTextStyle(
                            style: Theme.of(context).textTheme.labelSmall!,
                            overflow: TextOverflow.ellipsis,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.seasonNumber(item!.season),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const WidgetSpan(child: SizedBox(width: 10)),
                                  if (item!.episodeCount != null) ...[
                                    TextSpan(text: item!.episodes.length.toString()),
                                    const TextSpan(text: ' / '),
                                    TextSpan(text: AppLocalizations.of(context)!.episodeCount(item!.episodeCount!)),
                                  ] else
                                    TextSpan(text: AppLocalizations.of(context)!.episodeCount(item!.episodes.length)),
                                  const WidgetSpan(child: SizedBox(width: 20)),
                                  if (item!.airDate != null) TextSpan(text: item!.airDate?.format()),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              actions: [
                const IconButton(onPressed: null, icon: Icon(Icons.more_vert_rounded)),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),
            body: CustomScrollView(
              slivers: [
                SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item?.poster != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: AsyncImage(
                                  item!.poster!,
                                  width: 100,
                                  height: 150,
                                  radius: BorderRadius.circular(4),
                                  viewable: true,
                                ),
                              )
                            else
                              const SizedBox(),
                            Expanded(child: OverviewSection(text: item?.overview, trimLines: 7)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverSafeArea(
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final childAspectRatio =
                            constraints.crossAxisExtent / (constraints.crossAxisExtent / 616).ceil() / 120;
                        return SliverGrid.builder(
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 600,
                            childAspectRatio: childAspectRatio,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 16,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return GPlaceholder(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 16,
                                children: [
                                  const Flexible(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.all(4),
                                      child: AspectRatio(aspectRatio: 16 / 9, child: GPlaceholderImage()),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Expanded(child: GPlaceholderRect(height: 18)),
                                            IconButton(
                                              onPressed: null,
                                              icon: const Icon(Icons.more_vert_rounded),
                                              style: IconButton.styleFrom(
                                                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                                padding: EdgeInsets.zero,
                                                iconSize: 16,
                                                minimumSize: const Size.square(36),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Row(
                                          spacing: 6,
                                          children: [
                                            GPlaceholderRect(width: 24, height: 12),
                                            GPlaceholderRect(width: 36, height: 12),
                                            GPlaceholderRect(width: 36, height: 12),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 4,
                                          children: List.generate(
                                            3,
                                            (index) => FractionallySizedBox(
                                              widthFactor: Random().nextDouble() * 0.2 + 0.7,
                                              child: Container(height: 12, decoration: GPlaceholderDecoration.lite),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SliverSafeArea(top: false, sliver: SliverToBoxAdapter()),
              ],
            ),
          ),
    );
  }
}
