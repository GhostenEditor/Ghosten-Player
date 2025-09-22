import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../components/future_builder_handler.dart';
import '../../components/gap.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../pages/detail/utils/tmdb_uri.dart';
import '../../utils/utils.dart';
import '../components/icon_button.dart';
import '../components/setting.dart';
import '../utils/notification.dart';
import '../utils/player.dart';
import '../utils/utils.dart';
import 'components/cast_crew.dart';
import 'components/overview.dart';
import 'components/scaffold.dart';
import 'dialogs/movie_metadata.dart';
import 'dialogs/subtitle.dart';
import 'mixins/action.dart';
import 'mixins/searchable.dart';

class MovieDetail extends StatefulWidget {
  const MovieDetail({super.key, required this.initialData});

  final Movie initialData;

  @override
  State<MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> with ActionMixin {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _showSide = ValueNotifier(false);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _drawerNavigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _showSide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_drawerNavigatorKey.currentState?.canPop() ?? false) {
            _drawerNavigatorKey.currentState!.pop();
          } else {
            Navigator.of(context).pop(refresh);
          }
        }
      },
      child: FutureBuilderHandler(
        initialData: widget.initialData,
        future: Api.movieQueryById(widget.initialData.id),
        builder: (context, snapshot) {
          final item = snapshot.requireData;
          return DetailScaffold(
            item: item,
            scaffoldKey: _scaffoldKey,
            navigatorKey: _navigatorKey,
            drawerNavigatorKey: _drawerNavigatorKey,
            showSide: _showSide,
            endDrawer: _buildEndDrawer(context, item),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 32,
                  child: Row(
                    children:
                        item.genres
                            .map(
                              (genre) => TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () {},
                                child: Text(genre.name, style: Theme.of(context).textTheme.labelSmall),
                              ),
                            )
                            .toList(),
                  ),
                ),
                Text(
                  item.displayTitle(),
                  style: Theme.of(context).textTheme.displaySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                    children: [
                      const WidgetSpan(child: Icon(Icons.calendar_month_rounded, size: 14)),
                      const WidgetSpan(child: SizedBox(width: 4)),
                      TextSpan(text: item.releaseDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                      const WidgetSpan(child: SizedBox(width: 20)),
                      const WidgetSpan(child: Icon(Icons.star, color: Colors.amber, size: 14)),
                      const WidgetSpan(child: SizedBox(width: 2)),
                      TextSpan(text: item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown),
                      const WidgetSpan(child: SizedBox(width: 20)),
                      TextSpan(text: AppLocalizations.of(context)!.seriesStatus(item.status.name)),
                      const WidgetSpan(child: SizedBox(width: 20)),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child:
                            item.watched
                                ? TVIconButton.filledTonal(
                                  icon: const Icon(Icons.check_rounded, size: 16),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size.square(32),
                                  onPressed: () async {
                                    await Api.markWatched(MediaType.movie, item.id, !item.watched);
                                    if (context.mounted) setState(() => refresh = true);
                                  },
                                )
                                : TVIconButton(
                                  icon: const Icon(Icons.check_rounded, size: 16),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size.square(32),
                                  onPressed: () async {
                                    await Api.markWatched(MediaType.movie, item.id, !item.watched);
                                    if (context.mounted) setState(() => refresh = true);
                                  },
                                ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child:
                            item.favorite
                                ? TVIconButton.filledTonal(
                                  icon: const Icon(Icons.favorite_outline, size: 16),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size.square(32),
                                  onPressed: () async {
                                    await Api.markFavorite(MediaType.movie, item.id, !item.favorite);
                                    if (context.mounted) setState(() => refresh = true);
                                  },
                                )
                                : TVIconButton(
                                  icon: const Icon(Icons.favorite_outline, size: 16),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size.square(32),
                                  onPressed: () async {
                                    await Api.markFavorite(MediaType.movie, item.id, !item.favorite);
                                    if (context.mounted) setState(() => refresh = true);
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                OverviewSection(
                  navigatorKey: _navigatorKey,
                  item: item,
                  fileId: item.fileId,
                  description: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.labelSmall,
                      children: [
                        const WidgetSpan(child: Icon(Icons.star, color: Colors.amber, size: 14)),
                        const WidgetSpan(child: SizedBox(width: 4)),
                        TextSpan(
                          text: item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown,
                        ),
                        const WidgetSpan(child: SizedBox(width: 20)),
                        TextSpan(text: AppLocalizations.of(context)!.seriesStatus(item.status.name)),
                        const WidgetSpan(child: Gap.hSM),
                        if (item.duration != null) const WidgetSpan(child: Gap.hSM),
                        if (item.duration != null) const WidgetSpan(child: Icon(Icons.access_time_rounded, size: 14)),
                        if (item.duration != null) const WidgetSpan(child: SizedBox(width: 4)),
                        if (item.duration != null)
                          TextSpan(text: item.duration!.toDisplay(), style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                  onTap: () => _showSide.value = true,
                ),
                const SizedBox(height: 18),
                ButtonSettingItem(
                  autofocus: true,
                  leading: const Icon(Icons.play_arrow_rounded),
                  title: Text(AppLocalizations.of(context)!.buttonWatchNow),
                  trailing:
                      item.fileId != null
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
                  onTap: () => item.fileId != null ? _play(item) : null,
                ),
                ButtonSettingItem(
                  autofocus: true,
                  leading: const Icon(Icons.theaters_outlined),
                  title: Text(AppLocalizations.of(context)!.buttonTrailer),
                ),
                ButtonSettingItem(
                  leading: const Icon(Icons.person_rounded),
                  title: Text(AppLocalizations.of(context)!.titleCastCrew),
                  onTap: () {
                    _showSide.value = true;
                    navigateToSlideLeft(
                      _navigatorKey.currentContext!,
                      Align(
                        alignment: Alignment.topRight,
                        child: CastCrewSection(
                          mediaCast: item.mediaCast,
                          mediaCrew: item.mediaCrew,
                          type: MediaType.movie,
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                ButtonSettingItem(
                  leading: const Icon(Icons.more_horiz_rounded),
                  title: Text(AppLocalizations.of(context)!.buttonMore),
                  onTap: () {
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEndDrawer(BuildContext context, Movie item) {
    return SettingPage(
      title: AppLocalizations.of(context)!.buttonMore,
      child: Builder(
        builder: (context) {
          return ListView(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
            children: [
              ButtonSettingItem(
                title: Text(AppLocalizations.of(context)!.buttonSaveMediaInfoToDriver),
                leading: const Icon(Icons.save_outlined),
                autofocus: true,
                // onTap: () => showNotification(context, Api.movieRenameById(item.id)),
              ),
              ButtonSettingItem(
                title: Text(AppLocalizations.of(context)!.buttonScraperMediaInfo),
                leading: const Icon(Icons.info_outline),
                onTap: () async {
                  final data = await navigateTo<(String, String, String?)>(
                    navigatorKey.currentContext!,
                    SearchResultSelect(item: item),
                  );
                  if (data != null && context.mounted) {
                    final resp = await showNotification(
                      context,
                      Api.movieScraperById(item.id, data.$1, data.$2, data.$3),
                    );
                    if (resp?.error == null) setState(() {});
                  }
                },
              ),
              const DividerSettingItem(),
              buildEditMetadataAction(context, () async {
                final res = await Navigator.of(
                  context,
                ).push<bool>(FadeInPageRoute(builder: (context) => MovieMetadata(movie: item)));
                if ((res ?? false) && context.mounted) setState(() => refresh = true);
              }),
              ButtonSettingItem(
                title: Text(AppLocalizations.of(context)!.buttonSubtitle),
                leading: const Icon(Icons.subtitles_outlined),
                onTap:
                    () => Navigator.of(
                      context,
                    ).push<SubtitleData>(FadeInPageRoute(builder: (context) => SubtitleListPage(fileId: item.fileId!))),
              ),
              buildDownloadAction(context, item.fileId),
              if (item.scrapper.id != null)
                buildHomeAction(context, ImdbUri(MediaType.movie, item.scrapper.id!).toUri()),
              const DividerSettingItem(),
              buildDeleteAction(context, () => Api.movieDeleteById(item.id)),
            ],
          );
        },
      ),
    );
  }

  Future<void> _play(Movie item) async {
    await toPlayer(context, ([FromMedia.fromMovie(item)], 0), theme: item.themeColor);
    setState(() => refresh = true);
  }
}
