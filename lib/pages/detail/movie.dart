import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:video_player/player.dart';

import '../../components/gap.dart';
import '../../mixins/update.dart';
import '../../models/models.dart';
import '../../utils/notification.dart';
import '../../utils/player.dart';
import '../../utils/utils.dart';
import 'components/actors.dart';
import 'components/genres.dart';
import 'components/keywords.dart';
import 'components/overview.dart';
import 'components/studios.dart';
import 'dialogs/movie_metadata.dart';
import 'dialogs/subtitle.dart';
import 'mixins/detail_page.dart';
import 'utils/tmdb_uri.dart';

class MovieDetail extends StatefulWidget {
  final int movieId;
  final Movie? initialData;

  const MovieDetail(this.movieId, {super.key, this.initialData});

  @override
  State<MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> with DetailPageMixin<Movie, MovieDetail>, NeedUpdateMixin {
  @override
  Movie? get initialData => widget.initialData;

  @override
  Future<Movie> future() => Api.movieQueryById(widget.movieId);

  @override
  Widget buildTitle(BuildContext context, Movie item) => Text(item.displayTitle());

  @override
  Widget buildSubTitle(BuildContext context, Movie item) {
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
  List<ActionEntry> buildActions(BuildContext context, Movie item) {
    return [
      buildPlayAction(context, () => play(item)),
      ActionButton(
        onPressed: null,
        icon: const Icon(Icons.theaters_outlined),
        autoCollapse: true,
        text: Text(AppLocalizations.of(context)!.buttonTrailer),
      ),
      buildWatchedAction(context, item, MediaType.movie),
      buildFavoriteAction(context, item, MediaType.movie),
      buildCastAction(context, (device) => cast(item, device)),
      ActionDivider(),
      ActionButton(
          text: Text(AppLocalizations.of(context)!.buttonSaveMediaInfoToDriver),
          icon: const Icon(Icons.save_outlined),
          collapsed: true,
          onPressed: () async {
            await showNotification(context, Api.movieRenameById(item.id));
          }),
      ActionDivider(),
      buildRefreshInfoAction(context, () => refreshMovie(item)),
      ActionDivider(),
      buildEditMetadataAction(context, () async {
        final res = await showDialog<(String, int?)>(context: context, builder: (context) => MovieMetadata(movie: item));
        if (res != null) {
          final (title, year) = res;
          await Api.movieMetadataUpdateById(id: item.id, title: title, airDate: year == null ? null : DateTime(year));
          setState(() => refresh = true);
        }
      }),
      ActionButton(
        text: Text(AppLocalizations.of(context)!.buttonSubtitle),
        icon: const Icon(Icons.subtitles_outlined),
        collapsed: true,
        onPressed: () async {
          final subtitle = await showDialog<SubtitleData>(
              context: context,
              builder: (context) => SubtitleDialog(
                    subtitle: item.subtitles.firstOrNull,
                  ));
          if (subtitle != null && context.mounted) {
            final resp = await showNotification(context, Api.movieSubtitleUpdateById(id: item.id, subtitle: subtitle));
            if (resp?.error == null) setState(() => refresh = true);
          }
        },
      ),
      ActionButton(
        text: Text(AppLocalizations.of(context)!.buttonDownload),
        icon: const Icon(Icons.download_outlined),
        collapsed: true,
        onPressed: () async {
          final resp = await showNotification(context, Api.downloadTaskCreate(item.url.queryParameters['id']!),
              successText: AppLocalizations.of(context)!.tipsForDownload);
          if (resp?.error == null) setState(() => refresh = true);
        },
      ),
      if (item.scrapper.id != null) buildHomeAction(context, ImdbUri(MediaType.movie, item.scrapper.id!).toUri()),
      ActionDivider(),
      buildDeleteAction(context, () => Api.movieDeleteById(item.id)),
    ];
  }

  @override
  SliverChildDelegate buildChild(BuildContext context, Movie item) {
    return SliverChildListDelegate([
      OverviewSection(
          item: item,
          description: RichText(
              text: TextSpan(children: [
            TextSpan(text: '${item.filename}.${item.ext}', style: Theme.of(context).textTheme.labelSmall),
            const WidgetSpan(child: Gap.hSM),
            TextSpan(text: item.fileSize.toSizeDisplay(), style: Theme.of(context).textTheme.labelSmall),
          ]))),
      if (item.studios.isNotEmpty) StudiosSection(studios: item.studios),
      if (item.genres.isNotEmpty) GenresSection(genres: item.genres),
      if (item.keywords.isNotEmpty) KeywordsSection(keywords: item.keywords),
      if (item.actors.isNotEmpty) ActorsSection(actors: item.actors),
    ]);
  }

  Future<bool> refreshMovie(Movie item) {
    return search(
      ({required String title, int? year, int? index}) => Api.movieUpdateById(
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

  play(Movie item) async {
    await toPlayer(
      context,
      [FromMedia.fromMovie(item)],
      theme: item.themeColor,
      playerType: PlayerType.movie,
    );
    setState(() => refresh = true);
  }

  cast(Movie item, CastDevice device) async {
    await toPlayerCast(
      context,
      device,
      [FromMedia.fromMovie(item)],
      theme: item.themeColor,
    );
    setState(() => refresh = true);
  }
}
