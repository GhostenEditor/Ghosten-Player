import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../../cards/cards.dart';
import '../../../../components/components.dart';
import '../../../../extensions/extensions.dart';
import '../../../../l10n/app_localizations.dart';

class NextToPlaySection extends StatelessWidget {
  const NextToPlaySection({super.key, this.item});

  final TVEpisode? item;

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return SliverHorizontalList(
      allowHalf: true,
      header: Text(AppLocalizations.of(context)!.titlePlaylist),
      cardStyle: theme.episodeCardTheme,
      itemCount: item != null ? 1 : 0,
      itemBuilder: (context, index, size) => EpisodeWatchNowCard(item: item!, size: size),
    );
  }
}
