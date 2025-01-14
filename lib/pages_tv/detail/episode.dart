import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/gap.dart';
import '../../models/models.dart';
import '../../pages/detail/utils/tmdb_uri.dart';
import '../../utils/utils.dart';
import '../components/future_builder_handler.dart';
import '../components/icon_button.dart';
import '../components/setting.dart';
import '../utils/notification.dart';
import '../utils/player.dart';
import '../utils/utils.dart';
import 'components/actors.dart';
import 'components/overview.dart';
import 'components/scaffold.dart';
import 'dialogs/episode_metadata.dart';
import 'dialogs/subtitle.dart';
import 'mixins/action.dart';

class EpisodeDetail extends StatefulWidget {
  final TVEpisode initialData;
  final Scrapper scrapper;

  const EpisodeDetail(this.initialData, {super.key, required this.scrapper});

  @override
  State<EpisodeDetail> createState() => _EpisodeDetailState();
}

class _EpisodeDetailState extends State<EpisodeDetail> with ActionMixin {
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
          future: Api.tvEpisodeQueryById(widget.initialData.id),
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
                    Text(
                      item.displayTitle(),
                      style: Theme.of(context).textTheme.displaySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: item.seriesTitle),
                          const WidgetSpan(child: SizedBox(width: 6)),
                          TextSpan(text: AppLocalizations.of(context)!.seasonNumber(item.season)),
                          const WidgetSpan(child: SizedBox(width: 6)),
                          TextSpan(text: AppLocalizations.of(context)!.episodeNumber(item.episode)),
                          const WidgetSpan(child: SizedBox(width: 10)),
                          if (item.airDate != null) TextSpan(text: item.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                          const WidgetSpan(child: SizedBox(width: 10)),
                          WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: item.watched
                                  ? TVIconButton.filledTonal(
                                      icon: const Icon(Icons.check_rounded, size: 16),
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size.square(32),
                                      onPressed: () async {
                                        await Api.markWatched(MediaType.episode, item.id, !item.watched);
                                        if (context.mounted) setState(() => refresh = true);
                                      },
                                    )
                                  : TVIconButton(
                                      icon: const Icon(Icons.check_rounded, size: 16),
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size.square(32),
                                      onPressed: () async {
                                        await Api.markWatched(MediaType.episode, item.id, !item.watched);
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
                                        await Api.markFavorite(MediaType.episode, item.id, !item.favorite);
                                        if (context.mounted) setState(() => refresh = true);
                                      },
                                    )
                                  : TVIconButton(
                                      icon: const Icon(Icons.favorite_outline, size: 16),
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size.square(32),
                                      onPressed: () async {
                                        await Api.markFavorite(MediaType.episode, item.id, !item.favorite);
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
                          text: TextSpan(children: [
                        TextSpan(text: '${item.filename}.${item.ext}', style: Theme.of(context).textTheme.labelSmall),
                        const WidgetSpan(child: Gap.hSM),
                        TextSpan(text: item.fileSize.toSizeDisplay(), style: Theme.of(context).textTheme.labelSmall),
                      ])),
                      onTap: () => _showSide.value = true,
                    ),
                    const SizedBox(height: 18),
                    ButtonSettingItem(
                      autofocus: true,
                      leading: const Icon(Icons.play_arrow_rounded),
                      title: Text(AppLocalizations.of(context)!.buttonWatchNow),
                      onTap: () {
                        play(item);
                      },
                    ),
                    ButtonSettingItem(
                      leading: const Icon(Icons.person_rounded),
                      title: Text(AppLocalizations.of(context)!.titleCast),
                      onTap: () {
                        _showSide.value = true;
                        navigateToSlideLeft(
                            _navigatorKey.currentContext!,
                            Align(
                              alignment: Alignment.topRight,
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                child: ActorSection(actors: item.actors),
                              ),
                            ));
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
          }),
    );
  }

  Widget buildEndDrawer(BuildContext context, TVEpisode item) {
    return SettingPage(
      title: AppLocalizations.of(context)!.buttonMore,
      child: Builder(builder: (context) {
        return ListView(padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32), children: [
          buildSkipIntroAction(context, item, MediaType.episode, item.skipIntro),
          buildSkipEndingAction(context, item, MediaType.episode, item.skipEnding),
          const DividerSettingItem(),
          buildEditMetadataAction(context, () async {
            final resp = await Navigator.of(context).push<(String, int)>(FadeInPageRoute(builder: (context) => EpisodeMetadata(episode: item)));
            if (resp is (String, int)) {
              final (title, episode) = resp;
              await Api.tvEpisodeMetadataUpdateById(id: item.id, title: title, episode: episode);
              setState(() => refresh = true);
            }
          }),
          ButtonSettingItem(
            title: Text(AppLocalizations.of(context)!.buttonSubtitle),
            leading: const Icon(Icons.subtitles_outlined),
            onTap: () async {
              final subtitle = await Navigator.of(context).push<SubtitleData>(FadeInPageRoute(
                  builder: (context) => SubtitleDialog(
                        subtitle: item.subtitles.firstOrNull,
                      )));
              if (subtitle != null && context.mounted) {
                final resp = await showNotification(context, Api.tvEpisodeSubtitleUpdateById(id: item.id, subtitle: subtitle));
                if (resp?.error == null) setState(() => refresh = true);
              }
            },
          ),
          buildDownloadAction(context, item.url),
          if (widget.scrapper.id != null)
            buildHomeAction(context, ImdbUri(MediaType.episode, widget.scrapper.id!, season: item.season, episode: item.episode).toUri()),
          const DividerSettingItem(),
          buildDeleteAction(context, () => Api.tvEpisodeDeleteById(item.id)),
        ]);
      }),
    );
  }

  play(TVEpisode item) async {
    final season = await Api.tvSeasonQueryById(item.seasonId);
    if (!mounted) return;
    await toPlayer(
      context,
      season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList(),
      playerType: PlayerType.tv,
      id: item.id,
      theme: item.themeColor,
    );
    setState(() => refresh = true);
  }
}
