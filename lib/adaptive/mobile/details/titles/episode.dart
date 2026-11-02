import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../../subtitles/episode.dart';

class EpisodeTitle extends StatelessWidget {
  const EpisodeTitle({super.key, required this.item});

  final TVEpisode item;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: Column(
          spacing: 4,
          children: [
            Text(
              '${item.episode}. ${item.displayTitle()}',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            if (item.seriesTitle != null)
              Text(item.seriesTitle!, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            EpisodeSubtitle(item: item, style: Theme.of(context).textTheme.labelSmall, iconSize: 14),
          ],
        ),
      ),
    );
  }
}
