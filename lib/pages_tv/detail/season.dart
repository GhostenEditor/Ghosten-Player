import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../pages/detail/utils/tmdb_uri.dart';
import '../../utils/utils.dart';
import '../components/focusable_image.dart';
import '../components/future_builder_handler.dart';
import '../components/icon_button.dart';
import '../components/setting.dart';
import '../utils/player.dart';
import '../utils/utils.dart';
import 'components/cast_crew.dart';
import 'components/scaffold.dart';
import 'dialogs/season_metadata.dart';
import 'episode.dart';
import 'mixins/action.dart';

class SeasonDetail extends StatefulWidget {
  const SeasonDetail({super.key, required this.initialData});

  final TVSeries initialData;

  @override
  State<SeasonDetail> createState() => _SeasonDetailState();
}

class _SeasonDetailState extends State<SeasonDetail> with ActionMixin {
  final currentSeason = ValueNotifier<TVSeason?>(null);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _drawerNavigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    currentSeason.dispose();
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
        future: Api.tvSeriesQueryById(widget.initialData.id),
        builder: (context, snapshot) {
          final item = snapshot.requireData;
          if (item.seasons.isNotEmpty) {
            _switchSeason(
              item.seasons.firstWhere((it) => currentSeason.value == null || it.id == currentSeason.value?.id),
              widget.initialData.scrapper,
            );
          }
          return DetailScaffold(
            item: item,
            navigatorKey: _navigatorKey,
            scaffoldKey: _scaffoldKey,
            drawerNavigatorKey: _drawerNavigatorKey,
            endDrawer: _buildEndDrawer(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayTitle(),
                  style: Theme.of(context).textTheme.displaySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: AppLocalizations.of(context)!.seasonCount(item.seasons.length)),
                      const TextSpan(text: ' ・ '),
                      TextSpan(text: item.firstAirDate?.format()),
                    ],
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      ListenableBuilder(
                        listenable: currentSeason,
                        builder:
                            (context, _) => SliverMainAxisGroup(
                              slivers:
                                  item.seasons.asMap().entries.map((entry) {
                                    final item = entry.value;
                                    return SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: ButtonSettingItem(
                                          autofocus: entry.key == 0,
                                          selected: currentSeason.value?.id == entry.value.id,
                                          title: Text(AppLocalizations.of(context)!.seasonNumber(item.season)),
                                          subtitle:
                                              (item.title != null || item.airDate != null)
                                                  ? Row(
                                                    children: [
                                                      if (item.title != null) Text(item.title!),
                                                      if (item.title != null) const SizedBox(width: 12),
                                                      if (item.airDate != null)
                                                        Text(
                                                          item.airDate!.format(),
                                                          style: const TextStyle(fontSize: 12),
                                                        ),
                                                      if (item.airDate != null) const SizedBox(width: 6),
                                                      if (item.episodeCount != null)
                                                        Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.episodeCount(item.episodeCount!),
                                                          style: const TextStyle(fontSize: 12),
                                                        ),
                                                    ],
                                                  )
                                                  : null,
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (item.watched) const Icon(Icons.check),
                                              if (item.favorite) const SizedBox(width: 8),
                                              if (item.favorite) const Icon(Icons.favorite_outline_rounded),
                                            ],
                                          ),
                                          onTap: () => _switchSeason(item, snapshot.requireData.scrapper),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                      ),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ButtonSettingItem(
                            leading: const Icon(Icons.more_horiz_rounded),
                            title: Text(AppLocalizations.of(context)!.buttonMore),
                            onTap: () {
                              if (currentSeason.value != null) {
                                _scaffoldKey.currentState!.openEndDrawer();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _switchSeason(TVSeason item, Scrapper scrapper) {
    if (currentSeason.value == item) return;
    currentSeason.value = item;
    Future.microtask(() {
      Navigator.of(_navigatorKey.currentContext!).pushAndRemoveUntil(
        FadeInPageRoute(
          builder:
              (context) => _SeasonPage(
                key: ValueKey(item.id),
                seasonId: item.id,
                scrapper: scrapper,
                needUpdate: () => refresh = true,
              ),
        ),
        (_) => false,
      );
    });
  }

  Widget _buildEndDrawer(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.buttonMore,
      child: ListenableBuilder(
        listenable: currentSeason,
        builder:
            (context, _) =>
                currentSeason.value != null
                    ? ListView(
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
                      children: [
                        buildSkipIntroAction(
                          context,
                          currentSeason.value!,
                          MediaType.season,
                          currentSeason.value!.skipIntro,
                        ),
                        buildSkipIntroAction(
                          context,
                          currentSeason.value!,
                          MediaType.season,
                          currentSeason.value!.skipEnding,
                        ),
                        const Divider(),
                        buildEditMetadataAction(context, () async {
                          final newSeason = await Navigator.of(context).push<int>(
                            FadeInPageRoute(builder: (context) => SeasonMetadata(season: currentSeason.value!)),
                          );
                          if (newSeason != null) {
                            final newId = await Api.tvSeasonNumberUpdate(currentSeason.value!, newSeason);
                            refresh = true;
                            if (newId == currentSeason.value!.id) {
                              setState(() {});
                            } else if (context.mounted) {
                              Navigator.of(context).pop(refresh);
                            }
                          }
                        }),
                        if (widget.initialData.scrapper.id != null)
                          buildHomeAction(
                            context,
                            ImdbUri(
                              MediaType.season,
                              widget.initialData.scrapper.id!,
                              season: currentSeason.value!.season,
                            ).toUri(),
                          ),
                        const Divider(),
                        buildDeleteAction(context, () => Api.tvSeasonDeleteById(currentSeason.value!.id)),
                      ],
                    )
                    : const SizedBox(),
      ),
    );
  }
}

class _SeasonPage extends StatefulWidget {
  const _SeasonPage({super.key, required this.seasonId, required this.scrapper, required this.needUpdate});

  final dynamic seasonId;
  final Scrapper scrapper;
  final VoidCallback needUpdate;

  @override
  State<_SeasonPage> createState() => _SeasonPageState();
}

class _SeasonPageState extends State<_SeasonPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilderHandler(
      future: Api.tvSeasonQueryById(widget.seasonId),
      builder: (context, snapshot) {
        final item = snapshot.requireData;
        return CustomScrollView(
          cacheExtent: 1000,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 32, left: 8, right: 8, bottom: 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    FocusableImage(poster: item.poster, width: 120, height: 180, onTap: () {}),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              if (item.episodeCount != null)
                                Text(
                                  '${item.episodes.length} / ${AppLocalizations.of(context)!.episodeCount(item.episodeCount!)}',
                                )
                              else
                                Text(AppLocalizations.of(context)!.episodeCount(item.episodes.length)),
                              const SizedBox(width: 16),
                              if (item.airDate != null)
                                Text(item.airDate!.format(), style: Theme.of(context).textTheme.labelSmall),
                              const Spacer(),
                              if (item.watched)
                                TVIconButton.filledTonal(
                                  icon: const Icon(Icons.check_rounded, size: 16),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size.square(32),
                                  onPressed: () async {
                                    await Api.markWatched(MediaType.season, item.id, !item.watched);
                                    if (context.mounted) setState(() {});
                                  },
                                )
                              else
                                TVIconButton(
                                  icon: const Icon(Icons.check_rounded, size: 16),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size.square(32),
                                  onPressed: () async {
                                    await Api.markWatched(MediaType.season, item.id, !item.watched);
                                    if (context.mounted) setState(() {});
                                  },
                                ),
                              if (item.favorite)
                                TVIconButton.filledTonal(
                                  icon: const Icon(Icons.favorite_outline, size: 16),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size.square(32),
                                  onPressed: () async {
                                    await Api.markFavorite(MediaType.season, item.id, !item.favorite);
                                    if (context.mounted) setState(() {});
                                  },
                                )
                              else
                                TVIconButton(
                                  icon: const Icon(Icons.favorite_outline, size: 16),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size.square(32),
                                  onPressed: () async {
                                    await Api.markFavorite(MediaType.season, item.id, !item.favorite);
                                    if (context.mounted) setState(() {});
                                  },
                                ),
                            ],
                          ),
                          Text(
                            item.overview ?? AppLocalizations.of(context)!.noOverview,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.justify,
                            maxLines: 7,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverList.separated(
                itemCount: item.episodes.length,
                itemBuilder:
                    (context, index) => _EpisodeListTile(
                      key: UniqueKey(),
                      autofocus: index == 0,
                      episode: item.episodes[index],
                      scrapper: widget.scrapper,
                      onTap: () async {
                        await toPlayer(navigatorKey.currentContext!, (
                          item.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList(),
                          index,
                        ), theme: item.themeColor);
                        widget.needUpdate();
                      },
                      onTapMore: () async {
                        final resp = await navigateTo(
                          navigatorKey.currentContext!,
                          EpisodeDetail(item.episodes[index], scrapper: widget.scrapper),
                        );
                        if (resp == true) {
                          setState(() {});
                          widget.needUpdate();
                        }
                      },
                    ),
                separatorBuilder: (context, index) => const SizedBox(height: 16),
              ),
            ),
            CastCrewTitle(mediaCast: item.mediaCast, mediaCrew: item.mediaCrew),
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: CastCrewInner(mediaCast: item.mediaCast, mediaCrew: item.mediaCrew, type: MediaType.season),
            ),
          ],
        );
      },
    );
  }
}

class _EpisodeListTile extends StatelessWidget {
  const _EpisodeListTile({
    super.key,
    required this.episode,
    this.onTap,
    required this.scrapper,
    this.autofocus,
    this.onTapMore,
  });

  final TVEpisode episode;
  final Scrapper scrapper;
  final bool? autofocus;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onTapMore;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FocusableImage(autofocus: autofocus, poster: episode.poster, onTap: onTap),
                Align(
                  alignment: const Alignment(0.95, 0.9),
                  child: BadgeTheme(
                    data: BadgeTheme.of(context).copyWith(backgroundColor: Colors.black87, textColor: Colors.white),
                    child: IconTheme(
                      data: IconTheme.of(context).copyWith(size: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          if (episode.watched) const Badge(label: Icon(Icons.check)),
                          if (episode.favorite) const Badge(label: Icon(Icons.favorite_rounded)),
                          if (episode.downloaded) const Badge(label: Icon(Icons.download_rounded)),
                          if (episode.duration != null)
                            IconTheme(
                              data: IconThemeData(color: Theme.of(context).colorScheme.onInverseSurface, size: 14),
                              child: Badge(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 2,
                                  children: [
                                    const Icon(Icons.access_time_rounded),
                                    Text(episode.duration!.toDisplay()),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.labelSmall,
                    children: [
                      TextSpan(text: episode.seriesTitle),
                      const WidgetSpan(child: SizedBox(width: 6)),
                      TextSpan(text: AppLocalizations.of(context)!.seasonNumber(episode.season)),
                      const TextSpan(text: ' · '),
                      TextSpan(text: AppLocalizations.of(context)!.episodeNumber(episode.episode)),
                      const WidgetSpan(child: SizedBox(width: 10)),
                      if (episode.airDate != null)
                        TextSpan(text: episode.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        episode.displayTitle(),
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TVIconButton.filledTonal(
                      onPressed: onTapMore,
                      icon: const Icon(Icons.more_horiz_rounded, size: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(episode.overview ?? '', maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
