import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../cards/cards.dart';
import '../../components/components.dart';
import '../../extensions/extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';
import '../models/models.dart';
import '../providers/function.dart';
import '../view_models/view_models.dart';
import 'components/media_scaffold.dart';
import 'components/recommendation_carousel.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  final _backdrop = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _backdrop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FunctionConfig function = context.watch<FunctionConfig>();
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return RefreshIndicator(
      onRefresh: () async => context.read<MovieListViewModel>().load(),
      child: ViewModelConsumer<MovieListViewModel, MovieListViewModelData>(
        loadingBuilder: (context) => const _MovieListPageLoading(),
        builder: (context, data, _) => data.recommendation.isNotEmpty
            ? MediaScaffold(
                backdrop: _backdrop,
                slivers: [
                  RecommendationCarousel(
                    onChanged: (index) => _backdrop.value = data.recommendation[index].backdrop,
                    items: data.recommendation,
                    onPressed: (index) => toMediaPlayer(context, .movie, data.recommendation[index].id),
                  ),
                  SliverHorizontalList(
                    header: Text(AppLocalizations.of(context)!.watchNow),
                    cardStyle: theme.movieCardTheme,
                    itemCount: data.watchNow.length,
                    onTap: function.settingsHistory ? () => context.pushNamed(.settingsHistory) : null,
                    itemBuilder: (context, index, size) => _buildRecentMediaCard(context, data.watchNow[index], size),
                  ),
                  SliverHorizontalList(
                    header: Text(AppLocalizations.of(context)!.tagFavorite),
                    cardStyle: theme.movieCardTheme,
                    itemCount: data.favorite.length,
                    onTap: () => context.pushNamed(
                      .media,
                      arguments: const MediaListData(
                        type: .movie,
                        query: MediaSearchQuery(
                          sort: SortType.createAt,
                          direction: SortDirection.desc,
                          favorite: true,
                          limit: 15,
                        ),
                      ),
                    ),
                    itemBuilder: (context, index, size) => MovieCard(item: data.favorite[index], size: size),
                  ),
                  SliverHorizontalList(
                    header: Text(AppLocalizations.of(context)!.tagNewAdd),
                    cardStyle: theme.movieCardTheme,
                    itemCount: data.newAdd.length,
                    onTap: () => context.pushNamed(
                      .media,
                      arguments: const MediaListData(
                        type: .movie,
                        query: MediaSearchQuery(sort: SortType.createAt, direction: SortDirection.desc, limit: 15),
                      ),
                    ),
                    itemBuilder: (context, index, size) => MovieCard(item: data.newAdd[index], size: size),
                  ),
                  SliverHorizontalList(
                    header: Text(AppLocalizations.of(context)!.tagNewRelease),
                    cardStyle: theme.movieCardTheme,
                    itemCount: data.newRelease.length,
                    onTap: () => context.pushNamed(
                      .media,
                      arguments: const MediaListData(
                        type: .movie,
                        query: MediaSearchQuery(sort: SortType.airDate, direction: SortDirection.desc, limit: 15),
                      ),
                    ),
                    itemBuilder: (context, index, size) => MovieCard(item: data.newRelease[index], size: size),
                  ),
                  AspectRatioSliverGrid2(
                    header: Text(AppLocalizations.of(context)!.tagAll),
                    cardStyle: theme.movieCardTheme,
                    headerPadding: theme.horizontalListTheme.headerPadding!,
                    contentPadding: theme.horizontalListTheme.padding!,
                    state: data.all,
                    fetchNextPage: context.read<MovieListViewModel>().fetchNextPage,
                    itemBuilder: (context, item, size) => MovieCard(item: item, size: size),
                  ),
                ],
              )
            : NoData(
                action: FilledButton(
                  onPressed: () => context.pushNamed(.settingsLibraryMovie),
                  child: Text(AppLocalizations.of(context)!.settingsItemMovie),
                ),
              ),
      ),
    );
  }

  Widget _buildRecentMediaCard(BuildContext context, Movie item, Size size) {
    return ImageCard(
      src: item.poster,
      width: size.width,
      height: size.height,
      title: Text(item.displayRecentTitle()),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (item.lastPlayedTime != null)
            Text(
              AppLocalizations.of(context)!.timeAgo(item.lastPlayedTime!.fromNow().fromNowFormat(context)),
              style: Theme.of(context).textTheme.labelSmall,
            )
          else
            const Spacer(),
          if (item.lastPlayedPosition != null && item.duration != null && item.duration!.inSeconds != 0)
            Text('${(item.lastPlayedPosition!.inSeconds / item.duration!.inSeconds * 100).toStringAsFixed(1)}%'),
        ],
      ),
      onTap: () => toMediaPlayer(context, .movie, item.id),
      floating: item.lastPlayedPosition != null && item.duration != null && item.duration!.inSeconds != 0
          ? Positioned(
              bottom: 6,
              left: 6,
              right: 6,
              child: LinearProgressIndicator(
                value: item.lastPlayedPosition!.inSeconds / item.duration!.inSeconds,
                color: Theme.of(context).colorScheme.onSurface,
                borderRadius: BorderRadius.circular(3),
                minHeight: 3,
              ),
            )
          : null,
    );
  }
}

class _MovieListPageLoading extends StatelessWidget {
  const _MovieListPageLoading();

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return IgnorePointer(
      child: ListView(
        children: [
          const SafeArea(bottom: false, child: CarouselItem()),
          ...List.generate(
            3,
            (_) => HorizontalList(
              header: const Align(
                alignment: .centerLeft,
                child: PlaceholderRRect(height: 24, width: 72, borderRadius: BorderRadius.all(Radius.circular(4))),
              ),
              cardStyle: theme.movieCardTheme,
              scrollCacheExtent: const ScrollCacheExtent.pixels(0),
              itemCount: 10,
              itemBuilder: (context, index, size) => ImageCardPlaceholder(size: size),
            ),
          ),
        ],
      ),
    );
  }
}
