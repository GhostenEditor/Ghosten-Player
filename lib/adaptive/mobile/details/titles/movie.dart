import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../../subtitles/movie.dart';

class MovieTitle extends StatelessWidget {
  const MovieTitle({super.key, required this.item});

  final Movie item;

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
            MovieSubtitle(item: item, style: Theme.of(context).textTheme.labelSmall, iconSize: 14),
          ],
        ),
      ),
    );
  }
}
