import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../../subtitles/season.dart';

class SeasonTitle extends StatelessWidget {
  const SeasonTitle({super.key, required this.item});

  final TVSeason item;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Column(
          spacing: 4,
          children: [
            Text(
              item.title ?? '',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            Text(item.seriesTitle ?? '', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            SeasonSubtitle(item: item, style: Theme.of(context).textTheme.labelSmall, iconSize: 14),
          ],
        ),
      ),
    );
  }
}
