import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/tmdb_uri.dart';
import '../cards/cards.dart';
import '../extensions/extensions.dart';
import '../providers/function.dart';
import 'abstract.dart';

class SeasonMenu extends Menu {
  const SeasonMenu(this.item);

  final TVSeason item;

  @override
  List<Widget> build(BuildContext context) {
    final FunctionConfig function = context.read<FunctionConfig>();
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return [
      if (function.menuShortcuts) ...[
        SeasonCard(item: item, size: theme.seasonCardTheme.minSize, direction: .horizontal),
        const Divider(),
        buildPlayAction(context, item.id, .season),
        buildCastAction(context, item.id, .season),
        const Divider(),
        buildWatchedAction(context, item, MediaType.season),
        buildFavoriteAction(context, item, MediaType.season),
        const Divider(),
      ],
      if (function.menuSetSkipTime) ...[
        buildSkipFromStartAction(context, item, MediaType.season, item.skipIntro),
        buildSkipFromEndAction(context, item, MediaType.season, item.skipEnding),
        const Divider(),
      ],
      buildEditMetadataAction(context, item, .season),
      if (item.scraper.id != null)
        buildHomeAction(context, ImdbUri(MediaType.season, item.scraper.id!, season: item.season).toUri()),
      const Divider(),
      buildDeleteAction(context, () => Api.tvSeasonDeleteById(item.id)),
    ];
  }
}
