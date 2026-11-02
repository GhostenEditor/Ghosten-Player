import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile;

import '../../../l10n/app_localizations.dart';
import '../../../menus/episode.dart';
import '../../../subtitles/episode.dart';
import '../../../utils/utils.dart';
import '../../../view_models/view_models.dart';
import '../components/list_tile.dart';
import 'components/cast_crew.dart';
import 'components/overview.dart';
import 'components/scaffold.dart';

class EpisodePage extends StatefulWidget {
  const EpisodePage({super.key});

  @override
  State<EpisodePage> createState() => _EpisodePageState();
}

class _EpisodePageState extends State<EpisodePage> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final ValueNotifier<bool> _showSide = ValueNotifier(false);

  @override
  void dispose() {
    _showSide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer<EpisodeViewModel, TVEpisode>(
      useScaffold: true,
      builder: (context, item, _) => DetailScaffold(
        item: item,
        navigatorKey: _navigatorKey,
        showSide: _showSide,
        menus: EpisodeMenu(item),
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.displayTitle(),
              style: Theme.of(context).textTheme.displaySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: EpisodeSubtitle(
                    item: item,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                    iconSize: 14,
                  ),
                ),
                if (item.watched)
                  IconButton.filled(
                    icon: const Icon(Icons.check_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(minimumSize: const Size.square(32)),
                    onPressed: () async {
                      await Api.markWatched(MediaType.episode, item.id, !item.watched);
                      if (context.mounted) {
                        setState(() {});
                      }
                    },
                  )
                else
                  IconButton.filledTonal(
                    icon: const Icon(Icons.check_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(minimumSize: const Size.square(32)),
                    onPressed: () async {
                      await Api.markWatched(MediaType.episode, item.id, !item.watched);
                      if (context.mounted) {
                        setState(() {});
                      }
                    },
                  ),
                if (item.favorite)
                  IconButton.filled(
                    icon: const Icon(Icons.favorite_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(minimumSize: const Size.square(32)),
                    onPressed: () async {
                      await Api.markFavorite(MediaType.episode, item.id, !item.favorite);
                      if (context.mounted) {
                        setState(() {});
                      }
                    },
                  )
                else
                  IconButton.filledTonal(
                    icon: const Icon(Icons.favorite_outline_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(minimumSize: const Size.square(32)),
                    onPressed: () async {
                      await Api.markFavorite(MediaType.episode, item.id, !item.favorite);
                      if (context.mounted) {
                        setState(() {});
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 4),
            OverviewSection(
              navigatorKey: _navigatorKey,
              item: item,
              fileId: item.fileId,
              description: EpisodeSubtitle(
                item: item,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                iconSize: 14,
              ),
              onTap: () => _showSide.value = true,
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: Text(AppLocalizations.of(context)!.buttonWatchNow),
              onTap: () => toMediaPlayer(context, .episode, item.id),
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: Text(AppLocalizations.of(context)!.titleCastsCrews),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  _navigatorKey.currentContext!,
                  FadeInPageRoute(
                    builder: (context) => Align(
                      alignment: Alignment.topRight,
                      child: CastCrewSection(
                        mediaCast: item.mediaCast,
                        mediaCrew: item.mediaCrew,
                        type: MediaType.episode,
                      ),
                    ),
                  ),
                  (_) => false,
                );
                _showSide.value = true;
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.more_horiz_rounded),
              title: Text(AppLocalizations.of(context)!.buttonMore),
              onTap: () => Scaffold.of(context).openEndDrawer(),
            ),
          ],
        ),
      ),
    );
  }
}
