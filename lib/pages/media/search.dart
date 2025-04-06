import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/no_data.dart';
import '../../utils/utils.dart';
import '../components/image_card.dart';
import '../detail/movie.dart';
import '../detail/series.dart';

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
  final _clearFocusNode = FocusNode();

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
    _clearFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              isDense: true,
              filled: true,
              hintText: AppLocalizations.of(context)!.searchHint,
              hintStyle: Theme.of(context).textTheme.labelMedium,
              contentPadding: EdgeInsets.zero,
              prefixIcon: const Icon(Icons.search),
              prefixIconConstraints: const BoxConstraints(maxHeight: 32, minWidth: 32),
              suffixIconConstraints: const BoxConstraints(minHeight: 36, minWidth: 36),
              suffixIcon: _filter.isEmpty
                  ? const Icon(null)
                  : IconButton(
                      focusNode: _clearFocusNode,
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear)),
            ),
            onTap: () {},
            onChanged: (_) {},
            onTapOutside: (_) => _focusNode.unfocus(),
            onSubmitted: (res) {
              _search();
            },
          ),
        ),
        actions: [
          TextButton(onPressed: _search, child: Text(AppLocalizations.of(context)!.search)),
        ],
      ),
      body: _searchFuzzyResult != null
          ? CustomScrollView(
              slivers: [
                if (_searchFuzzyResult!.movies.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(child: Text(AppLocalizations.of(context)!.homeTabMovie, style: const TextStyle(height: 3))),
                        SliverGrid.builder(
                            addAutomaticKeepAlives: false,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 120,
                              childAspectRatio: 0.5,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                            itemCount: _searchFuzzyResult!.movies.length,
                            itemBuilder: (context, index) {
                              final item = _searchFuzzyResult!.movies[index];
                              return ImageCard(
                                item.poster,
                                title: Text(item.displayRecentTitle()),
                                subtitle: Text(item.airDate?.format() ?? ''),
                                onTap: () {
                                  navigateTo(context, MovieDetail(item.id, initialData: item));
                                },
                              );
                            })
                      ],
                    ),
                  ),
                if (_searchFuzzyResult!.series.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(child: Text(AppLocalizations.of(context)!.homeTabTV, style: const TextStyle(height: 3))),
                        SliverGrid.builder(
                            addAutomaticKeepAlives: false,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 120,
                              childAspectRatio: 0.5,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                            itemCount: _searchFuzzyResult!.series.length,
                            itemBuilder: (context, index) {
                              final item = _searchFuzzyResult!.series[index];
                              return ImageCard(
                                item.poster,
                                title: Text(item.displayRecentTitle()),
                                subtitle: Text(item.airDate?.format() ?? ''),
                                onTap: () {
                                  navigateTo<bool>(context, TVDetail(item.id, initialData: item));
                                },
                              );
                            })
                      ],
                    ),
                  ),
                if (_searchFuzzyResult!.episodes.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(child: Text(AppLocalizations.of(context)!.formLabelEpisode, style: const TextStyle(height: 3))),
                        SliverGrid.builder(
                            addAutomaticKeepAlives: false,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 180,
                              childAspectRatio: 1.3,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                            itemCount: _searchFuzzyResult!.episodes.length,
                            itemBuilder: (context, index) {
                              final item = _searchFuzzyResult!.episodes[index];
                              return ImageCard(
                                item.poster,
                                title: Text(item.displayRecentTitle()),
                                subtitle: Text(item.airDate?.format() ?? ''),
                                onTap: () async {
                                  final series = await Api.tvSeriesQueryById(item.seriesId);
                                  if (context.mounted) await navigateTo(context, TVDetail(series.id, initialData: series));
                                },
                              );
                            })
                      ],
                    ),
                  ),
                if (_searchFuzzyResult!.actors.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(child: Text(AppLocalizations.of(context)!.titleCast, style: const TextStyle(height: 3))),
                        SliverGrid.builder(
                            addAutomaticKeepAlives: false,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 100,
                              childAspectRatio: 0.5,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                            itemCount: _searchFuzzyResult!.actors.length,
                            itemBuilder: (context, index) {
                              final item = _searchFuzzyResult!.actors[index];
                              return ImageCard(
                                item.profile,
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
    );
  }

  Future<void> _search() async {
    if (_filter.isEmpty) {
      _searchFuzzyResult = null;
    } else {
      _searchFuzzyResult = await Api.searchFuzzy(_filter);
    }
    setState(() {});
  }

  void _updateState() {
    if (!_focusNode.hasFocus && _focused && _filter.isEmpty) {
      setState(() {
        _focused = false;
        _clearFocusNode.unfocus();
        _focusNode.unfocus();
      });
    }
  }
}
