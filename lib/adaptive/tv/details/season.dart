import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../l10n/app_localizations.dart';
import '../../../subtitles/season.dart';
import '../../../utils/utils.dart';
import '../../../view_models/view_models.dart';
import '../components/image_card.dart';
import 'components/cast_crew.dart';

class SeasonPage extends StatelessWidget {
  const SeasonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer<SeasonViewModel, TVSeason>(
      useScaffold: true,
      builder: (context, item, _) => CustomScrollView(
        scrollCacheExtent: const ScrollCacheExtent.pixels(1000),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 32, left: 8, right: 8, bottom: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  ImageCard(
                    src: item.poster,
                    width: 120,
                    height: 180,
                    onTap: item.poster != null
                        ? () => context.pushNamed(.imageViewer, arguments: {'url': Uri.parse(item.poster!)})
                        : null,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          item.title ?? '',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(child: SeasonSubtitle(item: item, iconSize: 14)),
                            if (item.watched)
                              IconButton.filled(
                                icon: const Icon(Icons.check_rounded, size: 16),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                style: IconButton.styleFrom(minimumSize: const Size.square(32)),
                                onPressed: () => Api.markWatched(MediaType.season, item.id, !item.watched),
                              )
                            else
                              IconButton.filledTonal(
                                icon: const Icon(Icons.check_rounded, size: 16),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                style: IconButton.styleFrom(minimumSize: const Size.square(32)),
                                onPressed: () => Api.markWatched(MediaType.season, item.id, !item.watched),
                              ),
                            if (item.favorite)
                              IconButton.filled(
                                icon: const Icon(Icons.favorite_rounded, size: 16),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                style: IconButton.styleFrom(minimumSize: const Size.square(32)),
                                onPressed: () => Api.markFavorite(MediaType.season, item.id, !item.favorite),
                              )
                            else
                              IconButton.filledTonal(
                                icon: const Icon(Icons.favorite_outline_rounded, size: 16),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                style: IconButton.styleFrom(minimumSize: const Size.square(32)),
                                onPressed: () => Api.markFavorite(MediaType.season, item.id, !item.favorite),
                              ),
                          ],
                        ),
                        Text(
                          item.overview ?? AppLocalizations.of(context)!.noOverview,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.justify,
                          maxLines: 5,
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
            sliver: SliverFixedExtentList.builder(
              itemCount: item.episodes.length,
              itemExtent: 156,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _EpisodeListTile(
                  key: UniqueKey(),
                  autofocus: index == 0,
                  episode: item.episodes[index],
                  width: 249,
                  height: 140,
                  onTap: () => toMediaPlayer(context, .season, item.id),
                  onTapMore: () => context.pushNamed(
                    .detailEpisode,
                    arguments: {'id': item.episodes[index].id, 'data': item.episodes[index]},
                  ),
                ),
              ),
            ),
          ),
          CastCrewTitle(mediaCast: item.mediaCast, mediaCrew: item.mediaCrew),
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: CastCrewInner(mediaCast: item.mediaCast, mediaCrew: item.mediaCrew, type: MediaType.season),
          ),
        ],
      ),
    );
  }
}

class _EpisodeListTile extends StatelessWidget {
  const _EpisodeListTile({
    super.key,
    required this.episode,
    this.onTap,
    this.autofocus,
    this.onTapMore,
    this.width,
    this.height,
  });

  final TVEpisode episode;
  final bool? autofocus;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onTapMore;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ImageCard(
      src: episode.poster,
      onTap: onTap,
      width: width,
      height: height,
      direction: .horizontal,
      title: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4,
              children: [
                Text(episode.displayTitle()),
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
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onTapMore,
            icon: const Icon(Icons.more_horiz_rounded, size: 16),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      subtitle: Text(episode.overview ?? '', maxLines: 4, overflow: .ellipsis),
      floating: Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 4,
            children: [
              BadgeTheme(
                data: BadgeTheme.of(context).copyWith(backgroundColor: Colors.black87, textColor: Colors.white),
                child: IconTheme(
                  data: IconTheme.of(context).copyWith(size: 12, color: Colors.white),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      if (episode.watched) const Badge(label: Icon(Icons.check_circle)),
                      if (episode.favorite) const Badge(label: Icon(Icons.favorite_rounded)),
                      if (episode.downloaded) const Badge(label: Icon(Icons.download_rounded)),
                      if (episode.duration != null && episode.duration != Duration.zero)
                        Badge(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 2,
                            children: [
                              const Icon(Icons.access_time_filled_rounded),
                              Text(episode.duration!.toDisplay()),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (episode.duration != null &&
                  episode.duration != Duration.zero &&
                  episode.lastPlayedPosition != null &&
                  episode.lastPlayedPosition != Duration.zero)
                LinearProgressIndicator(
                  value: episode.lastPlayedPosition!.inSeconds / episode.duration!.inSeconds,
                  color: Theme.of(context).colorScheme.onSurface,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(3),
                  minHeight: 3,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
