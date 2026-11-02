import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile;

import '../../../l10n/app_localizations.dart';
import '../../../menus/movie.dart';
import '../../../subtitles/movie.dart';
import '../../../utils/utils.dart';
import '../../../view_models/view_models.dart';
import '../components/list_tile.dart';
import 'components/cast_crew.dart';
import 'components/genres.dart';
import 'components/overview.dart';
import 'components/scaffold.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final ValueNotifier<bool> _showSide = ValueNotifier(false);

  @override
  void dispose() {
    _showSide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer<MovieViewModel, Movie>(
      useScaffold: true,
      builder: (context, item, _) => DetailScaffold(
        item: item,
        navigatorKey: _navigatorKey,
        showSide: _showSide,
        menus: MovieMenu(item),
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GenresSection(genres: item.genres, type: .movie),
            Text(
              item.displayTitle(),
              style: Theme.of(context).textTheme.displaySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Expanded(
                  child: MovieSubtitle(
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
                      await Api.markWatched(MediaType.movie, item.id, !item.watched);
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
                      await Api.markWatched(MediaType.movie, item.id, !item.watched);
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
                      await Api.markFavorite(MediaType.movie, item.id, !item.favorite);
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
                      await Api.markFavorite(MediaType.movie, item.id, !item.favorite);
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
              description: MovieSubtitle(
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
              trailing: item.fileId != null
                  ? (item.duration != null && item.lastPlayedTime != null && item.duration!.inSeconds > 0)
                        ? SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              value: item.lastPlayedPosition!.inSeconds / item.duration!.inSeconds,
                              backgroundColor: Colors.white,
                              strokeAlign: BorderSide.strokeAlignInside,
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
              onTap: () => item.fileId != null ? toMediaPlayer(context, .movie, item.id) : null,
            ),
            ListTile(
              enabled: false,
              leading: const Icon(Icons.theaters_outlined),
              title: Text(AppLocalizations.of(context)!.buttonTrailer),
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
                        type: MediaType.movie,
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
