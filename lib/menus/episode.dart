import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/tmdb_uri.dart';
import '../cards/cards.dart';
import '../extensions/extensions.dart';
import '../providers/function.dart';
import 'abstract.dart';

class EpisodeMenu extends Menu {
  const EpisodeMenu(this.item);

  final TVEpisode item;

  @override
  List<Widget> build(BuildContext context) {
    final FunctionConfig function = context.read<FunctionConfig>();
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return [
      if (function.menuShortcuts) ...[
        EpisodeCard(
          item: item,
          size: Size(
            theme.episodeCardTheme.minWidth!,
            theme.episodeCardTheme.minWidth! / theme.episodeCardTheme.aspectRatio!,
          ),
        ),
        const Divider(),
        buildPlayAction(context, item.id, .episode),
        buildCastAction(context, item.id, .episode),
        const Divider(),
        buildWatchedAction(context, item, MediaType.episode),
        buildFavoriteAction(context, item, MediaType.episode),
        const Divider(),
      ],
      if (function.menuSetSkipTime) ...[
        buildSkipFromStartAction(context, item, MediaType.episode, item.skipIntro),
        buildSkipFromEndAction(context, item, MediaType.episode, item.skipEnding),
        const Divider(),
      ],
      buildEditMetadataAction(context, item, .episode),
      if (item.fileId != null && function.menuSubtitle) buildSubtitleAction(context, item.fileId!),
      if (item.fileId != null && function.menuDownload) buildDownloadAction(context, item.downloaded),
      if (item.scraper.id != null)
        buildHomeAction(
          context,
          ImdbUri(MediaType.episode, item.scraper.id!, season: item.season, episode: item.episode).toUri(),
        ),
      const Divider(),
      if (item.fileId != null) buildDeleteAction(context, () => Api.tvEpisodeDeleteById(item.id)),
    ];
  }
}
