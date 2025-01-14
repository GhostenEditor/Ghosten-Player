import 'package:api/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/future_builder_handler.dart';
import '../../models/models.dart';
import '../../pages/detail/utils/tmdb_uri.dart';
import '../../utils/utils.dart';
import '../components/icon_button.dart';
import '../components/setting.dart';
import '../utils/notification.dart';
import '../utils/player.dart';
import '../utils/utils.dart';
import 'components/actors.dart';
import 'components/overview.dart';
import 'components/scaffold.dart';
import 'dialogs/series_metadata.dart';
import 'mixins/action.dart';
import 'mixins/searchable.dart';
import 'season.dart';

class TVDetail extends StatefulWidget {
  final TVSeries initialData;

  const TVDetail({super.key, required this.initialData});

  @override
  State<TVDetail> createState() => _TVDetailState();
}

class _TVDetailState extends State<TVDetail> with ActionMixin, SearchableMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _drawerNavigatorKey = GlobalKey<NavigatorState>();
  final _showSide = ValueNotifier(false);

  @override
  void dispose() {
    _showSide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (_drawerNavigatorKey.currentState?.canPop() == true) {
            _drawerNavigatorKey.currentState!.pop();
          } else {
            Navigator.of(context).pop(refresh);
          }
        }
      },
      child: FutureBuilderHandler(
        initialData: widget.initialData,
        future: Api.tvSeriesQueryById(widget.initialData.id),
        builder: (context, snapshot) {
          final item = snapshot.requireData;
          return DetailScaffold(
              item: item,
              scaffoldKey: _scaffoldKey,
              navigatorKey: _navigatorKey,
              drawerNavigatorKey: _drawerNavigatorKey,
              showSide: _showSide,
              endDrawer: buildEndDrawer(context, item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 32,
                    child: Row(
                        children: item.genres
                            .map((genre) => TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, visualDensity: VisualDensity.compact),
                                onPressed: null,
                                child: Text(genre.name, style: Theme.of(context).textTheme.labelSmall)))
                            .toList()),
                  ),
                  Text(
                    item.displayTitle(),
                    style: Theme.of(context).textTheme.displaySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: item.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                        const WidgetSpan(child: SizedBox(width: 20)),
                        const WidgetSpan(child: Icon(Icons.star, color: Colors.amber, size: 14)),
                        TextSpan(text: item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown),
                        const WidgetSpan(child: SizedBox(width: 20)),
                        TextSpan(text: AppLocalizations.of(context)!.seriesStatus(item.status.name)),
                        const WidgetSpan(child: SizedBox(width: 20)),
                        WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: item.watched
                                ? TVIconButton.filledTonal(
                                    icon: const Icon(Icons.check_rounded, size: 16),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size.square(32),
                                    onPressed: () async {
                                      await Api.markWatched(MediaType.series, item.id, !item.watched);
                                      if (context.mounted) setState(() => refresh = true);
                                    },
                                  )
                                : TVIconButton(
                                    icon: const Icon(Icons.check_rounded, size: 16),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size.square(32),
                                    onPressed: () async {
                                      await Api.markWatched(MediaType.series, item.id, !item.watched);
                                      if (context.mounted) setState(() => refresh = true);
                                    },
                                  )),
                        WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: item.favorite
                                ? TVIconButton.filledTonal(
                                    icon: const Icon(Icons.favorite_outline, size: 16),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size.square(32),
                                    onPressed: () async {
                                      await Api.markFavorite(MediaType.series, item.id, !item.favorite);
                                      if (context.mounted) setState(() => refresh = true);
                                    },
                                  )
                                : TVIconButton(
                                    icon: const Icon(Icons.favorite_outline, size: 16),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size.square(32),
                                    onPressed: () async {
                                      await Api.markFavorite(MediaType.series, item.id, !item.favorite);
                                      if (context.mounted) setState(() => refresh = true);
                                    },
                                  )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  OverviewSection(
                    navigatorKey: _navigatorKey,
                    item: item,
                    description: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.labelSmall!,
                        children: [
                          const WidgetSpan(child: Icon(Icons.star, color: Colors.amber, size: 14)),
                          const WidgetSpan(child: SizedBox(width: 4)),
                          TextSpan(text: item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown),
                          const WidgetSpan(child: SizedBox(width: 20)),
                          TextSpan(text: AppLocalizations.of(context)!.seriesStatus(item.status.name)),
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
                    onTap: () => play(context, item),
                  ),
                  ButtonSettingItem(
                    leading: const Icon(Icons.playlist_play),
                    title: Text(AppLocalizations.of(context)!.titleSeasons),
                    onTap: () async {
                      final flag = await navigateTo(context, SeasonDetail(initialData: item));
                      if (flag == true && context.mounted) setState(() => refresh = true);
                    },
                  ),
                  ButtonSettingItem(
                    leading: const Icon(Icons.person_rounded),
                    title: Text(AppLocalizations.of(context)!.titleCast),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(_navigatorKey.currentContext!, FadeInPageRoute(builder: (context) {
                        return Align(
                          alignment: Alignment.topRight,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: ActorSection(actors: item.actors),
                          ),
                        );
                      }), (_) => false);
                      _showSide.value = true;
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
              ));
        },
      ),
    );
  }

  Widget buildEndDrawer(BuildContext context, TVSeries item) {
    return SettingPage(
      title: AppLocalizations.of(context)!.buttonMore,
      child: Builder(builder: (context) {
        return ListView(padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32), children: [
          ButtonSettingItem(
            autofocus: true,
            leading: const Icon(Icons.video_library_outlined),
            title: Text(AppLocalizations.of(context)!.buttonSyncDriver),
            onTap: () async {
              final res = await showNotification(context, Api.tvSeriesSyncById(item.id));
              if (res?.error is DioException) {
                if ((res?.error as DioException).response?.statusCode == 404) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop(true);
                }
              } else {
                setState(() => refresh = true);
              }
            },
          ),
          ButtonSettingItem(
            leading: const Icon(Icons.save_outlined),
            title: Text(AppLocalizations.of(context)!.buttonSaveMediaInfoToDriver),
            onTap: () => showNotification(context, Api.tvSeriesRenameById(item.id)),
          ),
          const Divider(),
          ButtonSettingItem(
            leading: const Icon(Icons.info_outline),
            title: Text(AppLocalizations.of(context)!.buttonSyncMediaInfo),
            onTap: () async {
              final resp = await showNotification(context, refreshTVSeries(context, item));
              if (resp?.data == true) setState(() => refresh = true);
            },
          ),
          const Divider(),
          buildSkipIntroAction(context, item, MediaType.series, item.skipIntro),
          buildSkipEndingAction(context, item, MediaType.series, item.skipEnding),
          const Divider(),
          buildEditMetadataAction(context, () async {
            final res = await Navigator.of(context).push<(String, int?)>(FadeInPageRoute(builder: (context) => SeriesMetadata(series: item)));
            if (res != null) {
              final (title, year) = res;
              await Api.tvSeriesMetadataUpdateById(id: item.id, title: title, airDate: year == null ? null : DateTime(year));
              if (context.mounted) setState(() => refresh = true);
            }
          }),
          if (item.scrapper.id != null) buildHomeAction(context, ImdbUri(MediaType.series, item.scrapper.id!).toUri()),
          const Divider(),
          buildDeleteAction(context, () => Api.tvSeriesDeleteById(item.id)),
        ]);
      }),
    );
  }

  play(BuildContext context, TVSeries item) async {
    final res = item.nextToPlay;
    if (res != null) {
      final season = await Api.tvSeasonQueryById(res.seasonId);
      final playlist = season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList();
      if (!context.mounted) return;
      await toPlayer(context, playlist, id: res.id, theme: item.themeColor, playerType: PlayerType.tv);
      if (context.mounted) setState(() => refresh = true);
    }
  }

  Future<bool> refreshTVSeries(BuildContext context, TVSeries item) {
    return search(
      context,
      ({required String title, int? year, int? index}) => Api.tvSeriesUpdateById(
        item.id,
        title,
        Localizations.localeOf(context).languageCode,
        year: year.toString(),
        index: index,
      ),
      title: item.title ?? item.originalTitle ?? item.filename,
      year: item.airDate?.year,
    );
  }
}
