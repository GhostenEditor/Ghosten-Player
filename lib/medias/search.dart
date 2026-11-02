import 'package:api/api.dart';
import 'package:flutter/material.dart' hide Scrollbar;
import 'package:provider/provider.dart';

import '../../cards/cards.dart';
import '../../components/components.dart';
import '../../extensions/extensions.dart';
import '../../l10n/app_localizations.dart';
import '../adaptive/adaptive.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import '../view_models/view_models.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.autofocus = false});

  final bool autofocus;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: SearchBox(autofocus: true, controller: _searchController, onSubmitted: (_) => _search()),
        actions: [TextButton(onPressed: _search, child: Text(AppLocalizations.of(context)!.search))],
      ),
      body: ViewModelConsumer<SearchViewModel, SearchFuzzyResult>(
        builder: (context, data, _) => data.isNotEmpty
            ? Scrollbar(
                child: CustomScrollView(
                  slivers: [
                    SliverHorizontalList(
                      header: Text('${AppLocalizations.of(context)!.homeTabMovie}${data.movies.count.countString}'),
                      cardStyle: theme.movieCardTheme,
                      itemCount: data.movies.data.length,
                      itemBuilder: (context, index, size) => MovieCard(item: data.movies.data[index], size: size),
                      onTap: data.movies.data.length == data.movies.limit
                          ? () => context.pushNamed(
                              .media,
                              arguments: MediaListData(
                                query: MediaSearchQuery(search: _searchController.text),
                                type: FuzzySearchType.movie,
                              ),
                            )
                          : null,
                    ),
                    SliverHorizontalList(
                      header: Text('${AppLocalizations.of(context)!.homeTabTV}${data.series.count.countString}'),
                      cardStyle: theme.seriesCardTheme,
                      itemCount: data.series.data.length,
                      itemBuilder: (context, index, size) => SeriesCard(item: data.series.data[index], size: size),
                      onTap: data.series.data.length == data.series.limit
                          ? () => context.pushNamed(
                              .media,
                              arguments: MediaListData(
                                query: MediaSearchQuery(search: _searchController.text),
                                type: FuzzySearchType.series,
                              ),
                            )
                          : null,
                    ),
                    SliverHorizontalList(
                      header: Text(
                        '${AppLocalizations.of(context)!.formLabelEpisode}${data.episodes.count.countString}',
                      ),
                      cardStyle: theme.episodeCardTheme,
                      allowHalf: true,
                      itemCount: data.episodes.data.length,
                      itemBuilder: (context, index, size) {
                        final TVEpisode item = data.episodes.data[index];
                        return EpisodeWatchNowCard(
                          item: item,
                          size: size,
                          onTap: () => context.pushNamed(.detailEpisode, arguments: {'id': item.id, 'data': item}),
                        );
                      },
                      onTap: data.episodes.data.length == data.episodes.limit
                          ? () => context.pushNamed(
                              .media,
                              arguments: MediaListData(
                                query: MediaSearchQuery(search: _searchController.text),
                                type: FuzzySearchType.episode,
                              ),
                            )
                          : null,
                    ),
                    SliverHorizontalList(
                      header: Text('${AppLocalizations.of(context)!.titleCasts}${data.mediaCast.count.countString}'),
                      cardStyle: theme.castCardTheme,
                      itemCount: data.mediaCast.data.length,
                      itemBuilder: (context, index, size) => CastCard(item: data.mediaCast.data[index], size: size),
                      onTap: data.mediaCast.data.length == data.mediaCast.limit
                          ? () => context.pushNamed(
                              .media,
                              arguments: MediaListData(
                                query: MediaSearchQuery(search: _searchController.text),
                                type: FuzzySearchType.cast,
                              ),
                            )
                          : null,
                    ),
                    SliverHorizontalList(
                      header: Text('${AppLocalizations.of(context)!.titleCrews}${data.mediaCrew.count.countString}'),
                      cardStyle: theme.crewCardTheme,
                      itemCount: data.mediaCrew.data.length,
                      itemBuilder: (context, index, size) => CrewCard(item: data.mediaCrew.data[index], size: size),
                      onTap: data.mediaCrew.data.length == data.mediaCrew.limit
                          ? () => context.pushNamed(
                              .media,
                              arguments: MediaListData(
                                query: MediaSearchQuery(search: _searchController.text),
                                type: FuzzySearchType.crew,
                              ),
                            )
                          : null,
                    ),
                    const SliverSafeArea(top: false, sliver: SliverToBoxAdapter()),
                  ],
                ),
              )
            : const NoData(),
      ),
    );
  }

  void _search() {
    final SearchViewModel viewModel = context.read();
    viewModel.search = _searchController.text;
    viewModel.load();
  }
}

extension on SearchFuzzyResult {
  bool get isEmpty =>
      series.data.isEmpty &&
      episodes.data.isEmpty &&
      movies.data.isEmpty &&
      mediaCast.data.isEmpty &&
      mediaCrew.data.isEmpty;

  bool get isNotEmpty => !isEmpty;
}

extension on int {
  String get countString => this == 0 ? '' : ' ($this)';
}
