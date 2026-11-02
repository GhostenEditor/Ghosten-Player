import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../../subtitles/series.dart';

class SeriesTitle extends StatelessWidget {
  const SeriesTitle({super.key, required this.item});

  final TVSeries item;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Column(
          spacing: 4,
          children: [
            Text(
              item.displayTitle(),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SeriesSubtitle(item: item, iconSize: 14, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
