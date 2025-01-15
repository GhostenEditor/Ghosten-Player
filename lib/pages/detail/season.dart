import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:player_view/player.dart';

import '../../components/async_image.dart';
import '../../components/focus_card.dart';
import '../../components/gap.dart';
import '../../components/mobile_builder.dart';
import '../../mixins/update.dart';
import '../../models/models.dart';
import '../../utils/player.dart';
import '../../utils/utils.dart';
import 'components/drop_cap_text.dart';
import 'components/overview.dart';
import 'dialogs/season_metadata.dart';
import 'episode.dart';
import 'mixins/detail_page.dart';
import 'utils/tmdb_uri.dart';

class SeasonDetail extends StatefulWidget {
  final int id;
  final Scrapper scrapper;
  final TVSeason? initialData;

  const SeasonDetail({super.key, required this.id, this.initialData, required this.scrapper});

  @override
  State<SeasonDetail> createState() => _SeasonDetailState();
}

class _SeasonDetailState extends State<SeasonDetail> with DetailPageMixin<TVSeason, SeasonDetail>, NeedUpdateMixin {
  @override
  TVSeason? get initialData => widget.initialData;

  @override
  Future<TVSeason> future() => Api.tvSeasonQueryById(widget.id);

  @override
  Widget buildTitle(BuildContext context, TVSeason item) {
    return Text('${item.seriesTitle} ${item.title ?? ''}');
  }

  @override
  Widget buildSubTitle(BuildContext context, TVSeason item) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.labelSmall!,
        children: [
          TextSpan(text: AppLocalizations.of(context)!.seasonNumber(item.season), style: Theme.of(context).textTheme.bodyMedium),
          const WidgetSpan(child: SizedBox(width: 10)),
          if (item.episodeCount != null) ...[
            TextSpan(text: item.episodes.length.toString()),
            const TextSpan(text: ' / '),
            TextSpan(text: AppLocalizations.of(context)!.episodeCount(item.episodeCount!)),
          ] else
            TextSpan(text: AppLocalizations.of(context)!.episodeCount(item.episodes.length)),
          const WidgetSpan(child: SizedBox(width: 20)),
          if (item.airDate != null) TextSpan(text: item.airDate?.format()),
        ],
      ),
    );
  }

  @override
  List<ActionEntry> buildActions(BuildContext context, TVSeason item) {
    return [
      buildPlayAction(context, () => play(item)),
      ActionButton(
        onPressed: () => shufflePlay(item),
        icon: const Icon(Icons.shuffle_rounded),
        autoCollapse: true,
        text: Text(AppLocalizations.of(context)!.buttonShuffle),
      ),
      buildWatchedAction(context, item, MediaType.season),
      buildFavoriteAction(context, item, MediaType.season),
      buildCastAction(context, (device) => cast(item, device)),
      ActionDivider(),
      buildSkipFromStartAction(context, item, MediaType.season, item.skipIntro),
      buildSkipFromEndAction(context, item, MediaType.season, item.skipEnding),
      ActionDivider(),
      buildEditMetadataAction(context, () async {
        final newSeason = await showDialog<int>(context: context, builder: (context) => SeasonMetadata(season: item));
        if (newSeason != null) {
          final newId = await Api.tvSeasonNumberUpdate(item, newSeason);
          refresh = true;
          if (newId == item.id) {
            setState(() {});
          } else if (context.mounted) {
            Navigator.of(context).pop(refresh);
          }
        }
      }),
      if (widget.scrapper.id != null) buildHomeAction(context, ImdbUri(MediaType.season, widget.scrapper.id!, season: item.season).toUri()),
      ActionDivider(),
      buildDeleteAction(context, () => Api.tvSeasonDeleteById(item.id)),
    ];
  }

  @override
  SliverChildDelegate buildChild(BuildContext context, TVSeason season) {
    return SliverChildListDelegate([
      OverviewSection(
          item: season,
          description: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.labelSmall,
                children: [
                  TextSpan(text: season.seriesTitle),
                  const WidgetSpan(child: SizedBox(width: 10)),
                  TextSpan(text: AppLocalizations.of(context)!.seasonNumber(season.season)),
                  const WidgetSpan(child: SizedBox(width: 10)),
                  if (season.episodeCount != null) ...[
                    const WidgetSpan(child: SizedBox.shrink()),
                    TextSpan(text: season.episodes.length.toString()),
                    const TextSpan(text: ' / '),
                    TextSpan(text: AppLocalizations.of(context)!.episodeCount(season.episodeCount!)),
                  ] else
                    TextSpan(text: AppLocalizations.of(context)!.episodeCount(season.episodes.length)),
                ],
              ),
              textAlign: TextAlign.justify)),
      Gap.vLG,
      ...List.generate(season.episodes.length, (index) {
        final item = season.episodes[index];
        return FocusCard(
            onTap: () => navigate(context, EpisodeDetail(tvEpisodeId: item.id, initialData: item, scrapper: widget.scrapper)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text('${item.episode}.  ${item.displayTitle()}',
                              style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
                      Gap.hSM,
                      if (item.downloaded) Icon(Icons.download_outlined, size: 14, color: Theme.of(context).colorScheme.secondary),
                      if (item.watched) Icon(Icons.check_rounded, size: 14, color: Theme.of(context).colorScheme.secondary),
                      if (item.favorite) Icon(Icons.favorite_outline_rounded, size: 14, color: Theme.of(context).colorScheme.secondary),
                      Gap.hSM,
                      if (item.airDate != null) Text(item.airDate!.format(), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Gap.vSM,
                  MobileBuilder(builder: (context, isMobile, _) {
                    return DropCapText(
                      item.overview ?? AppLocalizations.of(context)!.noData,
                      style: DefaultTextStyle.of(context).style,
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isMobile ? TextAlign.start : TextAlign.justify,
                      dropCapPadding: const EdgeInsets.only(right: 8, top: 4),
                      dropCap: DropCap(
                          width: isMobile ? 160 : 220,
                          height: isMobile ? 90 : 150,
                          child: item.poster != null
                              ? AsyncImage(item.poster!, ink: true)
                              : Container(
                                  color: Theme.of(context).colorScheme.primary.withAlpha(0x11),
                                  child: Center(
                                      child: Icon(Icons.image_not_supported_outlined, size: 50, color: Theme.of(context).colorScheme.secondaryContainer)))),
                    );
                  }),
                ],
              ),
            ));
      }),
    ]);
  }

  shufflePlay(TVSeason item) async {
    final playlist = item.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList()..shuffle();
    await toPlayer(context, playlist, id: playlist[0].id, theme: item.themeColor, playerType: PlayerType.tv);
    setState(() => refresh = true);
  }

  play(TVSeason item) async {
    await toPlayer(
      context,
      item.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList(),
      id: item.episodes[0].id,
      theme: item.themeColor,
      playerType: PlayerType.tv,
    );
    setState(() => refresh = true);
  }

  cast(TVSeason item, CastDevice device) async {
    await toPlayerCast(
      context,
      device,
      item.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList(),
      id: item.episodes[0].id,
      theme: item.themeColor,
    );
    setState(() => refresh = true);
  }
}
