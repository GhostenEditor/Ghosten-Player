import 'package:api/api.dart';
import 'package:flutter/material.dart' hide IconButton;
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../cards/cards.dart';
import '../../components/components.dart';
import '../../extensions/extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';
import '../providers/function.dart';
import '../view_models/view_models.dart';
import 'components/media_scaffold.dart';
import 'components/recommendation_carousel.dart';

class TVListPage extends StatefulWidget {
  const TVListPage({super.key});

  @override
  State<TVListPage> createState() => _TVListPageState();
}

class _TVListPageState extends State<TVListPage> {
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
      onRefresh: () async => context.read<TvListViewModel>().load(),
      child: ViewModelConsumer<TvListViewModel, TvListViewModelData>(
        loadingBuilder: (context) => const _TVListPageLoading(),
        builder: (context, data, _) => data.recommendation.isNotEmpty
            ? MediaScaffold(
                backdrop: _backdrop,
                slivers: [
                  RecommendationCarousel(
                    onChanged: (index) => _backdrop.value = data.recommendation[index].backdrop,
                    items: data.recommendation,
                    onPressed: (index) => toMediaPlayer(context, .series, data.recommendation[index].id),
                  ),
                  SliverHorizontalList(
                    header: Text(AppLocalizations.of(context)!.watchNow),
                    cardStyle: theme.episodeCardTheme,
                    itemCount: data.watchNow.length,
                    allowHalf: true,
                    onTap: function.settingsHistory ? () => context.pushNamed(.settingsHistory) : null,
                    itemBuilder: (context, index, size) => EpisodeWatchNowCard(item: data.watchNow[index], size: size),
                  ),
                  SliverHorizontalList(
                    header: Text(AppLocalizations.of(context)!.tagFavorite),
                    cardStyle: theme.seriesCardTheme,
                    itemCount: data.favorite.length,
                    onTap: () => context.pushNamed(
                      .media,
                      arguments: const MediaListData(
                        type: .series,
                        query: MediaSearchQuery(
                          sort: SortType.createAt,
                          direction: SortDirection.desc,
                          favorite: true,
                          limit: 15,
                        ),
                      ),
                    ),
                    itemBuilder: (context, index, size) => SeriesCard(item: data.favorite[index], size: size),
                  ),
                  SliverHorizontalList(
                    header: Text(AppLocalizations.of(context)!.tagNewAdd),
                    cardStyle: theme.seriesCardTheme,
                    itemCount: data.newAdd.length,
                    onTap: () => context.pushNamed(
                      .media,
                      arguments: const MediaListData(
                        type: .series,
                        query: MediaSearchQuery(sort: SortType.createAt, direction: SortDirection.desc, limit: 15),
                      ),
                    ),
                    itemBuilder: (context, index, size) => SeriesCard(item: data.newAdd[index], size: size),
                  ),
                  SliverHorizontalList(
                    header: Text(AppLocalizations.of(context)!.tagNewRelease),
                    cardStyle: theme.seriesCardTheme,
                    itemCount: data.newRelease.length,
                    onTap: () => context.pushNamed(
                      .media,
                      arguments: const MediaListData(
                        type: .series,
                        query: MediaSearchQuery(sort: SortType.airDate, direction: SortDirection.desc, limit: 15),
                      ),
                    ),
                    itemBuilder: (context, index, size) => SeriesCard(item: data.newRelease[index], size: size),
                  ),
                  AspectRatioSliverGrid2(
                    header: Text(AppLocalizations.of(context)!.tagAll),
                    cardStyle: theme.seriesCardTheme,
                    headerPadding: theme.horizontalListTheme.headerPadding!,
                    contentPadding: theme.horizontalListTheme.padding!,
                    state: data.all,
                    fetchNextPage: context.read<TvListViewModel>().fetchNextPage,
                    itemBuilder: (context, item, size) => SeriesCard(item: item, size: size),
                  ),
                ],
              )
            : NoData(
                action: FilledButton(
                  onPressed: () => context.pushNamed(.settingsLibraryTv),
                  child: Text(AppLocalizations.of(context)!.settingsItemTV),
                ),
              ),
      ),
    );
  }
}

class _TVListPageLoading extends StatelessWidget {
  const _TVListPageLoading();

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return IgnorePointer(
      child: ListView(
        children: [
          const SafeArea(bottom: false, child: CarouselItem()),
          HorizontalList(
            header: const Align(
              alignment: .centerLeft,
              child: PlaceholderRRect(height: 24, width: 72, borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
            allowHalf: true,
            cardStyle: theme.episodeCardTheme,
            scrollCacheExtent: const ScrollCacheExtent.pixels(0),
            itemCount: 10,
            itemBuilder: (context, index, size) => ImageCardPlaceholder(size: size),
          ),
          ...List.generate(
            2,
            (_) => HorizontalList(
              header: const Align(
                alignment: .centerLeft,
                child: PlaceholderRRect(height: 24, width: 72, borderRadius: BorderRadius.all(Radius.circular(4))),
              ),
              cardStyle: theme.seriesCardTheme,
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
