import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/tmdb_uri.dart';
import '../adaptive/adaptive.dart';
import '../cards/cards.dart';
import '../extensions/extensions.dart';
import '../providers/function.dart';
import 'abstract.dart';

class MovieMenu extends Menu {
  const MovieMenu(this.item);

  final Movie item;

  @override
  List<Widget> build(BuildContext context) {
    final FunctionConfig function = context.read<FunctionConfig>();
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return [
      if (function.menuShortcuts) ...[
        MovieCard(item: item, size: theme.movieCardTheme.minSize, direction: .horizontal),
        const Divider(),
        buildPlayAction(context, item.id, .movie),
        buildCastAction(context, item.id, .movie),
        const Divider(),
        buildWatchedAction(context, item, MediaType.movie),
        buildFavoriteAction(context, item, MediaType.movie),
        const Divider(),
      ],
      if (function.menuSaveInfo)
        ListTile(
          enabled: false,
          // onTap: () => showNotification(context, Api.movieRenameById(item.id)),
          title: Text(AppLocalizations.of(context)!.buttonSaveMediaInfoToDriver),
          leading: const Icon(Icons.save_outlined),
        ),
      if (function.menuScrape) ...[buildScrapeAction(context, item), const Divider()],
      buildEditMetadataAction(context, item, .movie),
      if (item.fileId != null && function.menuSubtitle) buildSubtitleAction(context, item.fileId!),
      if (item.fileId != null && function.menuDownload) buildDownloadAction(context, item.downloaded),
      if (item.scraper.id != null) buildHomeAction(context, ImdbUri(MediaType.series, item.scraper.id!).toUri()),
      const Divider(),
      if (item.fileId != null) buildDeleteAction(context, () => Api.movieDeleteById(item.id)),
    ];
  }
}
