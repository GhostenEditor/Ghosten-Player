import 'package:api/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:player_view/player.dart';

import '../../mixins/update.dart';
import '../../models/models.dart';
import '../../platform_api.dart';
import '../../utils/notification.dart';
import '../../utils/player.dart';
import '../../utils/utils.dart';
import 'components/actors.dart';
import 'components/genres.dart';
import 'components/keywords.dart';
import 'components/next_to_play.dart';
import 'components/overview.dart';
import 'components/seasons.dart';
import 'components/studios.dart';
import 'dialogs/series_metadata.dart';
import 'mixins/detail_page.dart';
import 'season.dart';
import 'utils/tmdb_uri.dart';

class TVDetail extends StatefulWidget {
  final int tvSeriesId;
  final TVSeries? initialData;

  const TVDetail({super.key, required this.tvSeriesId, this.initialData});

  @override
  State<TVDetail> createState() => _TVDetailState();
}

class _TVDetailState extends State<TVDetail> with DetailPageMixin<TVSeries, TVDetail>, NeedUpdateMixin {
  @override
  TVSeries? get initialData => widget.initialData;

  @override
  Future<TVSeries> future() => Api.tvSeriesQueryById(widget.tvSeriesId);

  @override
  Widget buildTitle(BuildContext context, TVSeries item) => SelectableText(item.displayTitle());

  @override
  Widget buildSubTitle(BuildContext context, TVSeries item) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.labelSmall!,
        children: [
          TextSpan(text: item.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
          const WidgetSpan(child: SizedBox(width: 20)),
          const WidgetSpan(child: Icon(Icons.star, color: Colors.orangeAccent, size: 14)),
          TextSpan(text: item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown),
          const WidgetSpan(child: SizedBox(width: 20)),
          TextSpan(text: AppLocalizations.of(context)!.seriesStatus(item.status.name)),
        ],
      ),
    );
  }

  @override
  List<ActionEntry> buildActions(BuildContext context, TVSeries item) {
    return [
      buildPlayAction(context, () => play(item)),
      buildWatchedAction(context, item, MediaType.series),
      buildFavoriteAction(context, item, MediaType.series),
      if (!PlatformApi.isAndroidTV()) buildCastAction(context, (device) => cast(item, device)),
      ActionDivider(),
      ActionButton(
          text: Text(AppLocalizations.of(context)!.buttonSyncDriver),
          icon: const Icon(Icons.video_library_outlined),
          collapsed: true,
          onPressed: () async {
            final res = await showNotification(context, Api.tvSeriesSyncById(item.id));
            if (res?.error is DioException) {
              if ((res?.error as DioException).response?.statusCode == 404) {
                if (!context.mounted) return;
                Navigator.of(context).pop(true);
              }
            } else {
              setState(() => refresh = true);
            }
          }),
      ActionButton(
        text: Text(AppLocalizations.of(context)!.buttonSaveMediaInfoToDriver),
        icon: const Icon(Icons.save_outlined),
        collapsed: true,
        onPressed: () => showNotification(context, Api.tvSeriesRenameById(item.id)),
      ),
      ActionDivider(),
      buildRefreshInfoAction(context, () => refreshTVSeries(item)),
      ActionDivider(),
      buildSkipFromStartAction(context, item, MediaType.series, item.skipIntro),
      buildSkipFromEndAction(context, item, MediaType.series, item.skipEnding),
      ActionDivider(),
      buildEditMetadataAction(context, () async {
        final res = await showDialog<(String, int?)>(context: context, builder: (context) => SeriesMetadata(series: item));
        if (res != null) {
          final (title, year) = res;
          await Api.tvSeriesMetadataUpdateById(id: item.id, title: title, airDate: year == null ? null : DateTime(year));
          setState(() => refresh = true);
        }
      }),
      if (item.scrapper.id != null) buildHomeAction(context, ImdbUri(MediaType.series, item.scrapper.id!).toUri()),
      ActionDivider(),
      buildDeleteAction(context, () => Api.tvSeriesDeleteById(item.id)),
    ];
  }

  @override
  SliverChildDelegate buildChild(BuildContext context, TVSeries item) {
    return SliverChildListDelegate([
      OverviewSection(
          item: item,
          description: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.labelSmall!,
              children: [
                const WidgetSpan(child: Icon(Icons.star, color: Colors.orangeAccent, size: 14)),
                const WidgetSpan(child: SizedBox(width: 4)),
                TextSpan(text: item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown),
                const WidgetSpan(child: SizedBox(width: 20)),
                TextSpan(text: AppLocalizations.of(context)!.seriesStatus(item.status.name)),
              ],
            ),
          )),
      if (item.studios.isNotEmpty) StudiosSection(studios: item.studios),
      if (item.genres.isNotEmpty) GenresSection(genres: item.genres),
      if (item.keywords.isNotEmpty) KeywordsSection(keywords: item.keywords),
      if (item.nextToPlay != null) NextToPlaySection(nextToPlay: item.nextToPlay, onTap: () => play(item)),
      if (item.seasons.isNotEmpty)
        SeasonsSection(
          seasons: item.seasons,
          onTap: (season) => navigate(context, SeasonDetail(id: season.id, initialData: season, scrapper: item.scrapper)),
        ),
      if (item.actors.isNotEmpty) ActorsSection(actors: item.actors),
    ]);
  }

  Future<bool> refreshTVSeries(TVSeries item) {
    return search(
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

  play(TVSeries item) async {
    final res = item.nextToPlay;
    if (res != null) {
      final season = await Api.tvSeasonQueryById(res.seasonId);
      final playlist = season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList();
      if (!mounted) return;
      await toPlayer(context, playlist, id: res.id, theme: item.themeColor, playerType: PlayerType.tv);
      setState(() => refresh = true);
    }
  }

  cast(TVSeries item, CastDevice device) async {
    final res = item.nextToPlay;
    if (res != null) {
      final season = await Api.tvSeasonQueryById(res.seasonId);
      final playlist = season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList();
      if (!mounted) return;
      await toPlayerCast(context, device, playlist, id: res.id, theme: item.themeColor);
      setState(() => refresh = true);
    }
  }
}
