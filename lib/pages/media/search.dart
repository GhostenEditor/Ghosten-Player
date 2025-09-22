import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../components/async_image.dart';
import '../../components/future_builder_handler.dart';
import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../components/image_card.dart';
import '../components/loading.dart';
import '../detail/movie.dart';
import '../detail/series.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.filterType = const [],
    this.selectedGenre = const [],
    this.selectedStudio = const [],
    this.selectedKeyword = const [],
    this.selectedCast = const [],
    this.selectedCrew = const [],
    this.activeTab = 0,
    this.autofocus = false,
  });

  final bool autofocus;
  final int activeTab;
  final List<FilterType> filterType;
  final List<Genre> selectedGenre;
  final List<Studio> selectedStudio;
  final List<Keyword> selectedKeyword;
  final List<MediaCast> selectedCast;
  final List<MediaCrew> selectedCrew;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late int _activeIndex = widget.activeTab;
  final _searchController = TextEditingController();
  late final _pageController = PageController(initialPage: _activeIndex);

  String get _filter => _searchController.value.text;
  final _focusNode = FocusNode();
  final _clearFocusNode = FocusNode();

  late List<FilterType> _filterType = [...widget.filterType];
  late List<Genre> _selectedGenre = [...widget.selectedGenre];
  late List<Studio> _selectedStudio = [...widget.selectedStudio];
  late List<Keyword> _selectedKeyword = [...widget.selectedKeyword];
  late List<MediaCast> _selectedCast = [...widget.selectedCast];
  late List<MediaCrew> _selectedCrew = [...widget.selectedCrew];

  _SearchParams get _params {
    return _SearchParams(
      filter: _filter,
      genres: _selectedGenre.map((e) => e.id).toList(),
      studios: _selectedStudio.map((e) => e.id).toList(),
      keywords: _selectedKeyword.map((e) => e.id).toList(),
      mediaCast: _selectedCast.map((e) => e.id).toList(),
      mediaCrew: _selectedCrew.map((e) => e.id).toList(),
      favorite: switch ((_filterType.contains(FilterType.favorite), _filterType.contains(FilterType.exceptFavorite))) {
        ((true, false)) => true,
        ((false, true)) => false,
        _ => null,
      },
      watched: switch ((_filterType.contains(FilterType.watched), _filterType.contains(FilterType.unwatched))) {
        ((true, false)) => true,
        ((false, true)) => false,
        _ => null,
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
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
            autofocus: widget.autofocus,
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
              suffixIcon:
                  _filter.isEmpty
                      ? const Icon(null)
                      : IconButton(
                        focusNode: _clearFocusNode,
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
            ),
            onTap: () {},
            onChanged: (_) {},
            onTapOutside: (_) => _focusNode.unfocus(),
            onSubmitted: (res) {
              setState(() {});
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {});
            },
            child: Text(AppLocalizations.of(context)!.search),
          ),
        ],
        bottom: _HomeTabs(
          activeIndex: _activeIndex,
          tabs: [
            _TabItem(title: AppLocalizations.of(context)!.homeTabTV, canFilter: true),
            _TabItem(title: AppLocalizations.of(context)!.homeTabMovie, canFilter: true),
            _TabItem(title: AppLocalizations.of(context)!.formLabelEpisode),
            _TabItem(title: AppLocalizations.of(context)!.titleCast),
            _TabItem(title: AppLocalizations.of(context)!.titleCrew),
          ],
          onTabChange: (index) {
            _activeIndex = index;
            _pageController.jumpToPage(index);
            setState(() {});
          },
          onFilterTap: () {
            showModalBottomSheet(
              context: context,
              builder:
                  (context) => _SearchFilter(
                    selectedFilterType: _filterType,
                    selectedGenre: _selectedGenre,
                    selectedStudio: _selectedStudio,
                    selectedKeyword: _selectedKeyword,
                    selectedCast: _selectedCast,
                    selectedCrew: _selectedCrew,
                    onChanged: (value) {
                      _filterType = value.$1;
                      _selectedGenre = value.$2;
                      _selectedStudio = value.$3;
                      _selectedKeyword = value.$4;
                      _selectedCast = value.$5;
                      _selectedCrew = value.$6;
                      setState(() {});
                    },
                  ),
            );
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _activeIndex = index;
          setState(() {});
        },
        children: [
          CustomScrollView(
            slivers: [
              _buildFilterChipsGroup(context),
              _ItemSearchPage(
                key: const ValueKey('series'),
                params: _params,
                searchType: 'series',
                itemBuilder: (context, item, index) {
                  return ImageCard(
                    item.poster,
                    title: Text(item.displayRecentTitle()),
                    subtitle: Text(item.airDate?.format() ?? ''),
                    onTap: () {
                      navigateTo<bool>(context, TVDetail(item.id, initialData: item));
                    },
                  );
                },
                dataResolve: (data) => data.series,
              ),
            ],
          ),
          CustomScrollView(
            slivers: [
              _buildFilterChipsGroup(context),
              _ItemSearchPage(
                key: const ValueKey('movie'),
                params: _params,
                searchType: 'movie',
                itemBuilder: (context, item, index) {
                  return ImageCard(
                    item.poster,
                    title: Text(item.displayRecentTitle()),
                    subtitle: Text(item.airDate?.format() ?? ''),
                    onTap: () {
                      navigateTo<bool>(context, MovieDetail(item.id, initialData: item));
                    },
                  );
                },
                dataResolve: (data) => data.movies,
              ),
            ],
          ),
          CustomScrollView(
            slivers: [
              _ItemSearchPage(
                key: const ValueKey('episode'),
                params: _params,
                searchType: 'episode',
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  childAspectRatio: 1.3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, item, index) {
                  return ImageCard(
                    item.poster,
                    title: Text(item.displayTitle()),
                    subtitle: Text('S${item.season} E${item.episode} ${item.seriesTitle}'),
                    onTap: () async {
                      final series = await Api.tvSeriesQueryById(item.seriesId);
                      if (context.mounted) {
                        await navigateTo(context, TVDetail(series.id, initialData: series, playingId: item.id));
                      }
                    },
                  );
                },
                dataResolve: (data) => data.episodes,
              ),
            ],
          ),
          CustomScrollView(
            slivers: [
              _ItemSearchPage(
                key: const ValueKey('cast'),
                params: _params,
                searchType: 'media_cast',
                itemBuilder: (context, item, index) {
                  return ImageCard(
                    item.profile,
                    title: Text(item.name, textAlign: TextAlign.center),
                    noImageIcon: item.gender == 1 ? Icons.person_2 : Icons.person,
                    onTap: () {},
                  );
                },
                dataResolve: (data) => data.mediaCast,
              ),
            ],
          ),
          CustomScrollView(
            slivers: [
              _ItemSearchPage(
                key: const ValueKey('crew'),
                params: _params,
                searchType: 'media_crew',
                itemBuilder: (context, item, index) {
                  return ImageCard(
                    item.profile,
                    title: Text(item.name),
                    subtitle: Text(item.knownForDepartment ?? ''),
                    noImageIcon: item.gender == 1 ? Icons.person_2 : Icons.person,
                    onTap: () {},
                  );
                },
                dataResolve: (data) => data.mediaCrew,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipsGroup(BuildContext context) {
    return _FilterChipsGroup(
      filerType: _filterType,
      onFilterTypeDeleted: (ty) {
        setState(() {
          _filterType.remove(ty);
        });
      },
      genres: _selectedGenre,
      onGenreDeleted: (genre) {
        setState(() {
          _selectedGenre.remove(genre);
        });
      },
      studios: _selectedStudio,
      onStudioDeleted: (studio) {
        setState(() {
          _selectedStudio.remove(studio);
        });
      },
      keywords: _selectedKeyword,
      onKeywordDeleted: (keyword) {
        setState(() {
          _selectedKeyword.remove(keyword);
        });
      },
      cast: _selectedCast,
      onCastDeleted: (cast) {
        setState(() {
          _selectedCast.remove(cast);
        });
      },
      crew: _selectedCrew,
      onCrewDeleted: (crew) {
        setState(() {
          _selectedCrew.remove(crew);
        });
      },
    );
  }
}

class _SearchFilter extends StatefulWidget {
  const _SearchFilter({
    this.selectedFilterType = const [],
    this.selectedGenre = const [],
    this.selectedStudio = const [],
    this.selectedKeyword = const [],
    this.selectedCast = const [],
    this.selectedCrew = const [],
    required this.onChanged,
  });

  final List<FilterType> selectedFilterType;
  final List<Genre> selectedGenre;
  final List<Studio> selectedStudio;
  final List<Keyword> selectedKeyword;
  final List<MediaCast> selectedCast;
  final List<MediaCrew> selectedCrew;

  final ValueChanged<(List<FilterType>, List<Genre>, List<Studio>, List<Keyword>, List<MediaCast>, List<MediaCrew>)>
  onChanged;

  @override
  State<_SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<_SearchFilter> {
  late List<FilterType> _selectedFilterType = widget.selectedFilterType;
  late List<Genre> _selectedGenre = widget.selectedGenre;
  late List<Studio> _selectedStudio = widget.selectedStudio;
  late List<Keyword> _selectedKeyword = widget.selectedKeyword;
  late List<MediaCast> _selectedCast = widget.selectedCast;
  late List<MediaCrew> _selectedCrew = widget.selectedCrew;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.searchFilterTitle, style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                onPressed: () {
                  widget.onChanged((
                    _selectedFilterType,
                    _selectedGenre,
                    _selectedStudio,
                    _selectedKeyword,
                    _selectedCast,
                    _selectedCrew,
                  ));
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check_rounded),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: Scrollbar(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: _MultiSelect(
                    collapsedMax: 6,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150,
                      childAspectRatio: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    selected: _selectedFilterType,
                    items: FilterType.values,
                    itemBuilder:
                        (context, item) =>
                            Text(item.name, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, maxLines: 2),
                    onChanged: (value) {
                      _selectedFilterType = value;
                    },
                  ),
                ),
                FutureBuilderSliverHandler(
                  initialData: const <Genre>[],
                  future: Api.genreQueryAll(),
                  builder: (context, snapshot) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver:
                          snapshot.requireData.isNotEmpty
                              ? _MultiSelect(
                                label: AppLocalizations.of(context)!.titleGenre,
                                collapsedMax: 9,
                                selected: _selectedGenre,
                                items: snapshot.requireData,
                                itemBuilder:
                                    (context, item) => Text(
                                      item.name,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                onChanged: (value) {
                                  _selectedGenre = value;
                                },
                              )
                              : const SliverToBoxAdapter(),
                    );
                  },
                ),
                FutureBuilderSliverHandler(
                  initialData: const <Studio>[],
                  future: Api.studioQueryAll(),
                  builder: (context, snapshot) {
                    return snapshot.requireData.isNotEmpty
                        ? SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: _MultiSelect(
                            label: AppLocalizations.of(context)!.titleStudios,
                            collapsedMax: 6,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              childAspectRatio: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            selected: _selectedStudio,
                            items: snapshot.requireData,
                            itemBuilder:
                                (context, item) =>
                                    item.logo != null
                                        ? Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: AsyncImage(item.logo!, errorIconSize: 12),
                                        )
                                        : Text(
                                          item.name,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                        ),
                            onChanged: (value) {
                              _selectedStudio = value;
                            },
                          ),
                        )
                        : const SliverToBoxAdapter();
                  },
                ),
                FutureBuilderSliverHandler(
                  initialData: const <Keyword>[],
                  future: Api.keywordQueryAll(),
                  builder: (context, snapshot) {
                    return snapshot.requireData.isNotEmpty
                        ? SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: _MultiSelect(
                            label: AppLocalizations.of(context)!.titleKeyword,
                            collapsedMax: 6,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              childAspectRatio: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            selected: _selectedKeyword,
                            items: snapshot.requireData,
                            itemBuilder:
                                (context, item) => Text(
                                  item.name,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                            onChanged: (value) {
                              _selectedKeyword = value;
                            },
                          ),
                        )
                        : const SliverToBoxAdapter();
                  },
                ),
                FutureBuilderSliverHandler(
                  initialData: const <MediaCast>[],
                  future: Api.castQueryAll(),
                  builder: (context, snapshot) {
                    return snapshot.requireData.isNotEmpty
                        ? SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: _MultiSelect(
                            label: AppLocalizations.of(context)!.titleCast,
                            collapsedMax: 6,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              childAspectRatio: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            selected: _selectedCast,
                            items: snapshot.requireData,
                            itemBuilder:
                                (context, item) => Text(
                                  item.name,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                            onChanged: (value) {
                              _selectedCast = value;
                            },
                          ),
                        )
                        : const SliverToBoxAdapter();
                  },
                ),
                FutureBuilderSliverHandler(
                  initialData: const <MediaCrew>[],
                  future: Api.crewQueryAll(),
                  builder: (context, snapshot) {
                    return snapshot.requireData.isNotEmpty
                        ? SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: _MultiSelect(
                            label: AppLocalizations.of(context)!.titleCrew,
                            collapsedMax: 6,
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              childAspectRatio: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            selected: _selectedCrew,
                            items: snapshot.requireData,
                            itemBuilder:
                                (context, item) => Text(
                                  item.name,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                            onChanged: (value) {
                              _selectedCrew = value;
                            },
                          ),
                        )
                        : const SliverToBoxAdapter();
                  },
                ),
                const SliverSafeArea(sliver: SliverToBoxAdapter()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MultiSelect<T> extends StatefulWidget {
  const _MultiSelect({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.gridDelegate,
    this.label,
    required this.onChanged,
    this.selected = const [],
    this.collapsedMax = 12,
  });

  final String? label;
  final List<T> items;
  final List<T> selected;
  final Function(BuildContext, T) itemBuilder;
  final ValueChanged<List<T>> onChanged;
  final SliverGridDelegate? gridDelegate;
  final int collapsedMax;

  @override
  State<_MultiSelect<T>> createState() => _MultiSelectState();
}

class _MultiSelectState<T> extends State<_MultiSelect<T>> {
  bool _collapsed = true;
  late final _selected = [...widget.selected];

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        if (widget.label != null || widget.items.length > widget.collapsedMax)
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.label != null) Text(widget.label!, style: Theme.of(context).textTheme.titleMedium),
                  if (widget.items.length > widget.collapsedMax)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _collapsed = !_collapsed;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _collapsed
                                    ? AppLocalizations.of(context)!.buttonMore
                                    : AppLocalizations.of(context)!.buttonCollapse,
                              ),
                              Icon(_collapsed ? Icons.arrow_drop_down : Icons.arrow_drop_up),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        SliverGrid.builder(
          itemCount: _collapsed ? min(widget.items.length, widget.collapsedMax) : widget.items.length,
          addAutomaticKeepAlives: false,
          gridDelegate:
              widget.gridDelegate ??
              const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 100,
                childAspectRatio: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
          itemBuilder:
              (context, index) => Material(
                color:
                    _selected.contains(widget.items[index])
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                child: InkWell(
                  onTap: () {
                    if (_selected.contains(widget.items[index])) {
                      _selected.remove(widget.items[index]);
                    } else {
                      _selected.add(widget.items[index]);
                    }
                    widget.onChanged(_selected);
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Center(
                      child: DefaultTextStyle(
                        style: Theme.of(context).textTheme.labelSmall!,
                        child: widget.itemBuilder(context, widget.items[index]),
                      ),
                    ),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}

class _TabItem {
  const _TabItem({required this.title, this.canFilter = false});

  final String title;
  final bool canFilter;
}

class _HomeTabs extends StatefulWidget implements PreferredSizeWidget {
  const _HomeTabs({required this.tabs, required this.onTabChange, this.activeIndex = 0, required this.onFilterTap})
    : assert(activeIndex < tabs.length),
      assert(activeIndex >= 0);
  final int activeIndex;

  final List<_TabItem> tabs;
  final ValueChanged<int> onTabChange;
  final VoidCallback onFilterTap;

  @override
  State<_HomeTabs> createState() => _HomeTabsState();

  @override
  Size get preferredSize => const Size.fromHeight(36);
}

class _HomeTabsState extends State<_HomeTabs> {
  late int _activeIndex = widget.activeIndex;

  _TabItem get _active {
    return widget.tabs[_activeIndex];
  }

  late final tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(covariant _HomeTabs oldWidget) {
    if (_activeIndex != widget.activeIndex) {
      _activeIndex = widget.activeIndex;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (Theme.of(context).brightness) {
      Brightness.dark => Colors.white,
      Brightness.light => Colors.black,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                SizedBox(
                  height: 36,
                  child: Row(
                    children:
                        widget.tabs.indexed
                            .map(
                              (tab) => Builder(
                                builder: (context) {
                                  return TextButton(
                                    key: tabKeys[tab.$1],
                                    style: TextButton.styleFrom(
                                      shape: const RoundedRectangleBorder(),
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () {
                                      _activeIndex = tab.$1;
                                      widget.onTabChange(tab.$1);
                                      setState(() {});
                                    },
                                    child: Text(
                                      tab.$2.title,
                                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                        color: tab.$1 == _activeIndex ? color : Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: FutureBuilder(
                    initialData: (0.0, 0.0),
                    future: _updateActiveLine(context),
                    builder:
                        (context, snapshot) => AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          width: snapshot.requireData.$1,
                          height: 2,
                          margin: EdgeInsets.only(left: snapshot.requireData.$2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(2),
                              topRight: Radius.circular(2),
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: _active.canFilter ? widget.onFilterTap : null,
          icon: const Icon(Icons.filter_alt_outlined, size: 18),
        ),
      ],
    );
  }

  Future<(double, double)> _updateActiveLine(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final box = tabKeys[_activeIndex].currentContext!.findRenderObject()! as RenderBox;
    final offset = box.globalToLocal(Offset.zero, ancestor: box.parent);
    final lineWidth = box.size.width * 0.6;
    final lineOffset = -offset.dx + lineWidth * 0.3;
    return (lineWidth, lineOffset);
  }
}

class _FilterChips<T> extends StatelessWidget {
  const _FilterChips({
    super.key,
    required this.title,
    required this.chips,
    required this.onDeleted,
    required this.labelBuilder,
  });

  final String title;
  final List<T> chips;
  final Function(T) onDeleted;
  final Function(BuildContext, T) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(child: Text('$title: ', style: Theme.of(context).textTheme.labelSmall));
          } else {
            final chip = chips[index - 1];
            return Chip(
              label: labelBuilder(context, chip),
              labelPadding: EdgeInsets.zero,
              labelStyle: Theme.of(context).textTheme.labelSmall,
              shape: const StadiumBorder(),
              visualDensity: VisualDensity.compact,
              onDeleted: () {
                onDeleted(chip);
              },
            );
          }
        },
        itemCount: chips.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 4),
      ),
    );
  }
}

class _FilterChipsGroup extends StatelessWidget {
  const _FilterChipsGroup({
    required this.genres,
    required this.onGenreDeleted,
    required this.studios,
    required this.onStudioDeleted,
    required this.keywords,
    required this.onKeywordDeleted,
    required this.filerType,
    required this.onFilterTypeDeleted,
    required this.cast,
    required this.onCastDeleted,
    required this.crew,
    required this.onCrewDeleted,
  });

  final List<FilterType> filerType;
  final Function(FilterType) onFilterTypeDeleted;
  final List<Genre> genres;
  final Function(Genre) onGenreDeleted;
  final List<Studio> studios;
  final Function(Studio) onStudioDeleted;
  final List<Keyword> keywords;
  final Function(Keyword) onKeywordDeleted;
  final List<MediaCast> cast;
  final Function(MediaCast) onCastDeleted;
  final List<MediaCrew> crew;
  final Function(MediaCrew) onCrewDeleted;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        if (filerType.isNotEmpty)
          SliverToBoxAdapter(
            child: _FilterChips(
              title: AppLocalizations.of(context)!.titleGenre,
              chips: filerType,
              onDeleted: onFilterTypeDeleted,
              labelBuilder: (context, ty) => Text(ty.name),
            ),
          ),
        if (genres.isNotEmpty)
          SliverToBoxAdapter(
            child: _FilterChips(
              title: AppLocalizations.of(context)!.titleGenre,
              chips: genres,
              onDeleted: onGenreDeleted,
              labelBuilder: (context, genre) => Text(genre.name),
            ),
          ),
        if (studios.isNotEmpty)
          SliverToBoxAdapter(
            child: _FilterChips(
              title: AppLocalizations.of(context)!.titleStudios,
              chips: studios,
              onDeleted: onStudioDeleted,
              labelBuilder: (context, studio) => Text(studio.name),
            ),
          ),
        if (keywords.isNotEmpty)
          SliverToBoxAdapter(
            child: _FilterChips(
              title: AppLocalizations.of(context)!.titleKeyword,
              chips: keywords,
              onDeleted: onKeywordDeleted,
              labelBuilder: (context, keyword) => Text(keyword.name),
            ),
          ),
        if (cast.isNotEmpty)
          SliverToBoxAdapter(
            child: _FilterChips(
              title: AppLocalizations.of(context)!.titleCast,
              chips: cast,
              onDeleted: onCastDeleted,
              labelBuilder: (context, cast) => Text(cast.name),
            ),
          ),
        if (crew.isNotEmpty)
          SliverToBoxAdapter(
            child: _FilterChips(
              title: AppLocalizations.of(context)!.titleCrew,
              chips: crew,
              onDeleted: onCrewDeleted,
              labelBuilder: (context, crew) => Text(crew.name),
            ),
          ),
      ],
    );
  }
}

class _ItemSearchPage<T> extends StatefulWidget {
  const _ItemSearchPage({
    super.key,
    required this.params,
    required this.searchType,
    required this.itemBuilder,
    required this.dataResolve,
    this.gridDelegate = const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 120,
      childAspectRatio: 0.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
    ),
  });

  final _SearchParams params;
  final String searchType;
  final ItemWidgetBuilder<T> itemBuilder;
  final PageData<T> Function(SearchFuzzyResult) dataResolve;
  final SliverGridDelegate gridDelegate;

  @override
  State<_ItemSearchPage<T>> createState() => _ItemSearchPageState();
}

class _ItemSearchPageState<T> extends State<_ItemSearchPage<T>> {
  PagingState<int, T> _state = PagingState();

  Future<void> _fetchNextPage() async {
    if (_state.isLoading) return;

    await Future.value();

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final newKey = (_state.keys?.last ?? -1) + 1;
      final data = await Api.searchFuzzy(
        widget.searchType,
        limit: 30,
        offset: newKey * 30,
        filter: widget.params.filter,
        genres: widget.params.genres.isNotEmpty ? widget.params.genres : null,
        studios: widget.params.studios.isNotEmpty ? widget.params.studios : null,
        keywords: widget.params.keywords.isNotEmpty ? widget.params.keywords : null,
        mediaCast: widget.params.mediaCast.isNotEmpty ? widget.params.mediaCast : null,
        mediaCrew: widget.params.mediaCrew.isNotEmpty ? widget.params.mediaCrew : null,
        watched: widget.params.watched,
        favorite: widget.params.favorite,
      ).then(widget.dataResolve);

      final hasNextPage = data.offset + data.limit < data.count;

      setState(() {
        _state = _state.copyWith(
          pages: [...?_state.pages, data.data],
          keys: [...?_state.keys, newKey],
          hasNextPage: hasNextPage,
          isLoading: false,
        );
      });
    } catch (error) {
      setState(() {
        _state = _state.copyWith(error: error, isLoading: false);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ItemSearchPage<T> oldWidget) {
    setState(() {
      _state = PagingState();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SliverSafeArea(
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        sliver: PagedSliverGrid(
          state: _state,
          fetchNextPage: _fetchNextPage,
          gridDelegate: widget.gridDelegate,
          showNewPageProgressIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          builderDelegate: PagedChildBuilderDelegate<T>(
            itemBuilder: widget.itemBuilder,
            noMoreItemsIndicatorBuilder:
                (context) => const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Column(
                    spacing: 16,
                    children: [
                      FractionallySizedBox(widthFactor: 0.5, child: Divider()),
                      Text('THE END', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            firstPageProgressIndicatorBuilder: (context) => const Loading(),
            newPageProgressIndicatorBuilder: (context) => const Loading(),
            noItemsFoundIndicatorBuilder: (_) => const NoData(),
          ),
        ),
      ),
    );
  }
}

class _SearchParams {
  const _SearchParams({
    required this.filter,
    required this.genres,
    required this.studios,
    required this.keywords,
    required this.mediaCast,
    required this.mediaCrew,
    required this.watched,
    required this.favorite,
  });

  final String? filter;
  final List<dynamic> genres;
  final List<dynamic> studios;
  final List<dynamic> keywords;
  final List<dynamic> mediaCast;
  final List<dynamic> mediaCrew;
  final bool? watched;
  final bool? favorite;
}
