import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/logo.dart';
import '../../components/no_data.dart';
import '../../utils/utils.dart';
import '../detail/episode.dart';
import '../detail/movie.dart';
import '../detail/series.dart';
import 'components/media_grid_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _focused = false;

  String get _filter => _searchController.value.text;
  final _focusNode = FocusNode();

  SearchFuzzyResult? _searchFuzzyResult;

  @override
  void initState() {
    _focusNode.addListener(_updateState);
    _searchController.addListener(_updateState);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        if (_focusNode.hasFocus && _searchFuzzyResult != null) {
          _focusNode.nextFocus();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const Padding(
            padding: EdgeInsets.all(12),
            child: Logo(),
          ),
          leadingWidth: 120,
          title: IconButtonTheme(
            data: IconButtonThemeData(
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                iconSize: 16,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            child: TextField(
              autofocus: true,
              focusNode: _focusNode,
              controller: _searchController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide.none,
                ),
                hintText: AppLocalizations.of(context)!.searchHint,
                contentPadding: EdgeInsets.zero,
                prefixIcon: const Icon(Icons.search),
                suffixIconConstraints: const BoxConstraints(minHeight: 36, minWidth: 36),
              ),
              onTap: () {},
              onChanged: (_) {},
              onTapOutside: (_) => _focusNode.unfocus(),
              onSubmitted: (res) {
                _search();
              },
            ),
          ),
        ),
        body: _searchFuzzyResult != null
            ? CustomScrollView(
                slivers: [
                  if (_searchFuzzyResult!.movies.data.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverMainAxisGroup(
                        slivers: [
                          SliverToBoxAdapter(
                              child: Text(AppLocalizations.of(context)!.homeTabMovie, style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 3))),
                          SliverGrid.builder(
                              addAutomaticKeepAlives: false,
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 172,
                                childAspectRatio: 0.56,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              itemCount: _searchFuzzyResult!.movies.data.length,
                              itemBuilder: (context, index) {
                                final item = _searchFuzzyResult!.movies.data[index];
                                return MediaGridItem(
                                  imageUrl: item.poster,
                                  imageWidth: 172,
                                  imageHeight: 258,
                                  title: Text(item.displayRecentTitle()),
                                  subtitle: Text(item.airDate?.format() ?? ''),
                                  onTap: () {
                                    navigateTo(context, MovieDetail(initialData: item));
                                  },
                                );
                              })
                        ],
                      ),
                    ),
                  if (_searchFuzzyResult!.series.data.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverMainAxisGroup(
                        slivers: [
                          SliverToBoxAdapter(
                              child: Text(AppLocalizations.of(context)!.homeTabTV, style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 3))),
                          SliverGrid.builder(
                              addAutomaticKeepAlives: false,
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 172,
                                childAspectRatio: 0.56,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              itemCount: _searchFuzzyResult!.series.data.length,
                              itemBuilder: (context, index) {
                                final item = _searchFuzzyResult!.series.data[index];
                                return MediaGridItem(
                                  imageUrl: item.poster,
                                  imageWidth: 172,
                                  imageHeight: 258,
                                  title: Text(item.displayRecentTitle()),
                                  subtitle: Text(item.airDate?.format() ?? ''),
                                  onTap: () {
                                    navigateTo<bool>(context, TVDetail(initialData: item));
                                  },
                                );
                              })
                        ],
                      ),
                    ),
                  if (_searchFuzzyResult!.episodes.data.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverMainAxisGroup(
                        slivers: [
                          SliverToBoxAdapter(
                              child: Text(AppLocalizations.of(context)!.formLabelEpisode, style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 3))),
                          SliverGrid.builder(
                              addAutomaticKeepAlives: false,
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 240,
                                childAspectRatio: 1.2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              itemCount: _searchFuzzyResult!.episodes.data.length,
                              itemBuilder: (context, index) {
                                final item = _searchFuzzyResult!.episodes.data[index];
                                return MediaGridItem(
                                  imageUrl: item.poster,
                                  imageWidth: 220,
                                  imageHeight: 220 / 1.78,
                                  title: Text(item.displayRecentTitle()),
                                  subtitle: Text(item.airDate?.format() ?? ''),
                                  onTap: () async {
                                    final series = await Api.tvSeriesQueryById(item.seriesId);
                                    if (context.mounted) await navigateTo(context, EpisodeDetail(item, scrapper: series.scrapper));
                                  },
                                );
                              })
                        ],
                      ),
                    ),
                  if (_searchFuzzyResult!.mediaCast.data.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverMainAxisGroup(
                        slivers: [
                          SliverToBoxAdapter(
                              child: Text(AppLocalizations.of(context)!.titleCast, style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 3))),
                          SliverGrid.builder(
                              addAutomaticKeepAlives: false,
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 120,
                                childAspectRatio: 0.56,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              itemCount: _searchFuzzyResult!.mediaCast.data.length,
                              itemBuilder: (context, index) {
                                final item = _searchFuzzyResult!.mediaCast.data[index];
                                return MediaGridItem(
                                  imageUrl: item.profile,
                                  imageWidth: 120,
                                  imageHeight: 180,
                                  placeholderIcon: Icons.account_circle_outlined,
                                  title: Text(item.name),
                                  onTap: () {},
                                );
                              })
                        ],
                      ),
                    ),
                ],
              )
            : const Center(child: NoData()),
      ),
    );
  }

  Future<void> _search() async {
    if (_filter.isEmpty) {
      _searchFuzzyResult = null;
    } else {
      // _searchFuzzyResult = await Api.searchFuzzy(_filter);
    }
    setState(() {});
  }

  void _updateState() {
    if (!_focusNode.hasFocus && _focused && _filter.isEmpty) {
      setState(() {
        _focused = false;
        _focusNode.unfocus();
      });
    }
  }
}
