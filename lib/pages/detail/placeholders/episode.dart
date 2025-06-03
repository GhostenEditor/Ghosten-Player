import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/async_image.dart';
import '../../../components/placeholder.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../components/image_card.dart';
import '../../components/theme_builder.dart';
import '../components/overview.dart';

class EpisodePlaceholder extends StatelessWidget {
  const EpisodePlaceholder({super.key, this.item});

  final TVEpisode? item;

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      item?.themeColor,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title:
                item != null
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item!.episode}. ${item!.displayTitle()}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.labelSmall!,
                          overflow: TextOverflow.ellipsis,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: item!.seriesTitle),
                                const WidgetSpan(child: SizedBox(width: 6)),
                                TextSpan(text: AppLocalizations.of(context)!.seasonNumber(item!.season)),
                                const WidgetSpan(child: SizedBox(width: 10)),
                                if (item!.airDate != null)
                                  TextSpan(text: item!.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                    : const SizedBox(),
            actions: [
              const IconButton(onPressed: null, icon: Icon(Icons.more_vert_rounded)),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverSafeArea(
                sliver: SliverList.list(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child:
                          item != null
                              ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item?.poster != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: AsyncImage(
                                        item!.poster!,
                                        width: 160,
                                        radius: BorderRadius.circular(4),
                                        viewable: true,
                                      ),
                                    ),
                                  Expanded(child: OverviewSection(text: item?.overview, trimLines: 6)),
                                ],
                              )
                              : GPlaceholder(
                                child: IgnorePointer(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const GPlaceholderImage(
                                        padding: EdgeInsets.only(right: 16),
                                        width: 160,
                                        height: 90,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 7,
                                          children: List.generate(
                                            6,
                                            (index) => FractionallySizedBox(
                                              widthFactor: Random().nextDouble() * 0.2 + 0.7,
                                              child: Container(height: 12, decoration: GPlaceholderDecoration.base),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                    ),
                    GPlaceholder(
                      child: IgnorePointer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const GPlaceholderRect(width: 100, height: 24, padding: EdgeInsets.all(16)),
                            SizedBox(
                              height: 150 + 50,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                scrollDirection: Axis.horizontal,
                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                itemCount: 10,
                                itemBuilder: (context, index) => const ImageCardPlaceholder(width: 100, height: 150),
                              ),
                            ),
                          ],
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
  }
}
