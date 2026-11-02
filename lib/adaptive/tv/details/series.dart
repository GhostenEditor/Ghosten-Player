import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile;

import '../../../l10n/app_localizations.dart';
import '../../../menus/series.dart';
import '../../../subtitles/series.dart';
import '../../../utils/utils.dart';
import '../../../view_models/view_models.dart';
import '../components/list_tile.dart';
import 'components/cast_crew.dart';
import 'components/genres.dart';
import 'components/overview.dart';
import 'components/scaffold.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final ValueNotifier<bool> _showSide = ValueNotifier(false);

  @override
  void dispose() {
    _showSide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer<SeriesViewModel, TVSeries>(
      useScaffold: true,
      builder: (context, item, _) => DetailScaffold(
        item: item,
        navigatorKey: _navigatorKey,
        showSide: _showSide,
        menus: SeriesMenu(item),
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GenresSection(genres: item.genres, type: .series),
            Text(
              item.displayTitle(),
              style: Theme.of(context).textTheme.displaySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Expanded(
                  child: SeriesSubtitle(
                    item: item,
                    iconSize: 14,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (item.watched)
                  IconButton.filled(
                    icon: const Icon(Icons.check_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(minimumSize: const Size.square(32)),
                    onPressed: () async {
                      await Api.markWatched(MediaType.series, item.id, !item.watched);
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
                      await Api.markWatched(MediaType.series, item.id, !item.watched);
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
                      await Api.markFavorite(MediaType.series, item.id, !item.favorite);
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
                      await Api.markFavorite(MediaType.series, item.id, !item.favorite);
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
              description: SeriesSubtitle(
                item: item,
                iconSize: 14,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              onTap: () => _showSide.value = true,
            ),
            const SizedBox(height: 18),
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              minTileHeight: 64,
              title: Text(AppLocalizations.of(context)!.buttonWatchNow),
              subtitle: item.nextToPlay != null
                  ? Text(
                      'S${item.nextToPlay!.season} E${item.nextToPlay!.episode} - ${item.nextToPlay!.displayTitle()}',
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: item.nextToPlay != null
                  ? (item.nextToPlay?.duration != null &&
                            item.nextToPlay?.lastPlayedTime != null &&
                            item.nextToPlay!.duration!.inSeconds > 0)
                        ? SizedBox.square(
                            dimension: 16,
                            child: Builder(
                              builder: (context) {
                                return CircularProgressIndicator(
                                  value:
                                      item.nextToPlay!.lastPlayedPosition!.inSeconds /
                                      item.nextToPlay!.duration!.inSeconds,
                                  backgroundColor: Colors.white,
                                  strokeAlign: BorderSide.strokeAlignInside,
                                );
                              },
                            ),
                          )
                        : null
                  : const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
              onTap: item.nextToPlay != null ? () => toMediaPlayer(context, .series, item.id) : () {},
            ),
            ListTile(
              leading: const Icon(Icons.playlist_play),
              title: Text(AppLocalizations.of(context)!.titleSeasons),
              onTap: () => context.pushNamed(.detailSeries2, arguments: {'id': item.id, 'data': item}),
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
                        type: MediaType.series,
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
