import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../components/components.dart';
import '../../extensions/extensions.dart';
import '../cards/cards.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../utils/navigator.dart';

class MediaListPage extends StatefulWidget {
  const MediaListPage({super.key, required this.data});

  final MediaListData data;

  @override
  State<MediaListPage> createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {
  late MediaSearchQuery query = widget.data.query;

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: Scaffold(
        endDrawer: Drawer(
          child: _SearchFilter(query: query, onChanged: (value) => setState(() => query = value)),
        ),
        extendBodyBehindAppBar: true,
        body: Scrollbar(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                automaticallyImplyLeading: theme.mediaListTheme.automaticallyImplyLeading,
                forceMaterialTransparency: theme.mediaListTheme.forceMaterialTransparency,
                titleTextStyle: theme.mediaListTheme.titleTextStyle,
                expandedHeight: theme.mediaListTheme.expandedHeight,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(switch (widget.data.type) {
                    .movie => AppLocalizations.of(context)!.homeTabMovie,
                    .series => AppLocalizations.of(context)!.homeTabTV,
                    .episode => AppLocalizations.of(context)!.formLabelEpisode,
                    .cast => AppLocalizations.of(context)!.titleCasts,
                    .crew => AppLocalizations.of(context)!.titleCrews,
                  }),
                  titlePadding: theme.mediaListTheme.titlePadding,
                ),
              ),
              SliverSafeArea(
                top: false,
                sliver: SliverPadding(
                  padding: theme.mediaListTheme.contentPadding ?? .zero,
                  sliver: switch (widget.data.type) {
                    FuzzySearchType.movie => AspectRatioSliverGrid(
                      cardStyle: theme.movieCardTheme,
                      itemBuilder: (context, item, size) => MovieCard(item: item, size: size),
                      onQuery: (newKey) => Api.movieQueryAll(query.copyWith(limit: 30, offset: 30 * newKey)),
                    ),
                    FuzzySearchType.series => AspectRatioSliverGrid(
                      cardStyle: theme.seriesCardTheme,
                      itemBuilder: (context, item, size) => SeriesCard(item: item, size: size),
                      onQuery: (newKey) => Api.tvSeriesQueryAll(query.copyWith(limit: 30, offset: 30 * newKey)),
                    ),
                    FuzzySearchType.episode => AspectRatioSliverGrid(
                      cardStyle: theme.episodeCardTheme,
                      itemBuilder: (context, item, size) => EpisodeWatchNowCard(
                        size: size,
                        item: item,
                        onTap: () => context.pushNamed(.detailEpisode, arguments: {'id': item.id, 'data': item}),
                      ),
                      onQuery: (newKey) => Api.tvEpisodeQueryAll(query.copyWith(limit: 30, offset: 30 * newKey)),
                    ),
                    FuzzySearchType.cast => AspectRatioSliverGrid(
                      cardStyle: theme.castCardTheme,
                      itemBuilder: (context, item, size) => CastCard(item: item, size: size),
                      onQuery: (newKey) =>
                          Api.castQueryAll(SearchQuery(limit: 30, offset: 30 * newKey, search: query.search)),
                    ),
                    FuzzySearchType.crew => AspectRatioSliverGrid(
                      cardStyle: theme.crewCardTheme,
                      itemBuilder: (context, item, size) => CrewCard(item: item, size: size),
                      onQuery: (newKey) =>
                          Api.crewQueryAll(SearchQuery(limit: 30, offset: 30 * newKey, search: query.search)),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchFilter extends StatefulWidget {
  const _SearchFilter({required this.query, required this.onChanged});

  final MediaSearchQuery query;

  final ValueChanged<MediaSearchQuery> onChanged;

  @override
  State<_SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<_SearchFilter> {
  late MediaSearchQuery _query = widget.query;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.searchFilterTitle),
        actions: [
          IconButton(
            onPressed: () {
              widget.onChanged(_query);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check_rounded),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: FilledButtonTheme(
        data: FilledButtonThemeData(
          style: FilledButtonTheme.of(context).style!.copyWith(
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
            fixedSize: const WidgetStatePropertyAll(Size.fromHeight(24)),
            visualDensity: const VisualDensity(vertical: VisualDensity.minimumDensity),
            textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.labelMedium),
            tapTargetSize: .shrinkWrap,
          ),
        ),
        child: Scrollbar(
          child: CustomScrollView(
            slivers: [
              _MediaSearchQueryButtons(
                query: _query,
                onChanged: (query) {
                  _query = _query.copyWith(
                    search: query.search,
                    sort: query.sort,
                    direction: query.direction,
                    favorite: query.favorite,
                    watched: query.watched,
                  );
                },
              ),
              FutureBuilderSliverHandler(
                initialData: const <Genre>[],
                future: Api.genreQueryAll(),
                builder: (context, snapshot) => _MultiSelect(
                  label: AppLocalizations.of(context)!.titleGenres,
                  selected: (_query.genres?.toSet() ?? {})
                      .map((item) => snapshot.requireData.indexWhere((it) => it.id == item))
                      .where((index) => !index.isNegative)
                      .toSet(),
                  itemCount: snapshot.requireData.length,
                  itemBuilder: (context, index) => Text(snapshot.requireData[index].name),
                  onChanged: (value) =>
                      _query = _query.copyWith(genres: value.map((index) => snapshot.requireData[index].id).toList()),
                ),
              ),
              FutureBuilderSliverHandler(
                initialData: const <Studio>[],
                future: Api.studioQueryAll(),
                builder: (context, snapshot) => _MultiSelect(
                  label: AppLocalizations.of(context)!.titleStudios,
                  selected: (_query.studios?.toSet() ?? {})
                      .map((item) => snapshot.requireData.indexWhere((it) => it.id == item))
                      .where((index) => !index.isNegative)
                      .toSet(),
                  itemCount: snapshot.requireData.length,
                  itemBuilder: (context, index) => snapshot.requireData[index].logo != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: AsyncImage(snapshot.requireData[index].logo!, errorIconSize: 12),
                        )
                      : Text(snapshot.requireData[index].name),
                  onChanged: (value) =>
                      _query = _query.copyWith(studios: value.map((index) => snapshot.requireData[index].id).toList()),
                ),
              ),
              FutureBuilderSliverHandler(
                initialData: const <Keyword>[],
                future: Api.keywordQueryAll(),
                builder: (context, snapshot) => _MultiSelect(
                  label: AppLocalizations.of(context)!.titleKeywords,
                  selected: (_query.keywords?.toSet() ?? {})
                      .map((item) => snapshot.requireData.indexWhere((it) => it.id == item))
                      .where((index) => !index.isNegative)
                      .toSet(),
                  itemCount: snapshot.requireData.length,
                  itemBuilder: (context, index) => Text(snapshot.requireData[index].name),
                  onChanged: (value) =>
                      _query = _query.copyWith(keywords: value.map((index) => snapshot.requireData[index].id).toList()),
                ),
              ),
              FutureBuilderSliverHandler(
                initialData: const PageData<MediaCast>(),
                future: Api.castQueryAll(const SearchQuery()),
                builder: (context, snapshot) => _MultiSelect(
                  label: AppLocalizations.of(context)!.titleCasts,
                  selected: (_query.mediaCast?.toSet() ?? {})
                      .map((item) => snapshot.requireData.data.indexWhere((it) => it.id == item))
                      .where((index) => !index.isNegative)
                      .toSet(),
                  itemCount: snapshot.requireData.data.length,
                  itemBuilder: (context, index) => Text(snapshot.requireData.data[index].name),
                  onChanged: (value) => _query = _query.copyWith(
                    mediaCast: value.map((index) => snapshot.requireData.data[index].id).toList(),
                  ),
                ),
              ),
              FutureBuilderSliverHandler(
                initialData: const PageData<MediaCrew>(),
                future: Api.crewQueryAll(const SearchQuery()),
                builder: (context, snapshot) => _MultiSelect(
                  label: AppLocalizations.of(context)!.titleCrews,
                  selected: (_query.mediaCrew?.toSet() ?? {})
                      .map((item) => snapshot.requireData.data.indexWhere((it) => it.id == item))
                      .where((index) => !index.isNegative)
                      .toSet(),
                  itemCount: snapshot.requireData.data.length,
                  itemBuilder: (context, index) => Text(snapshot.requireData.data[index].name),
                  onChanged: (value) => _query = _query.copyWith(
                    mediaCrew: value.map((index) => snapshot.requireData.data[index].id).toList(),
                  ),
                ),
              ),
              const SliverSafeArea(sliver: SliverToBoxAdapter()),
            ],
          ),
        ),
      ),
    );
  }
}

class _MultiSelect extends StatefulWidget {
  const _MultiSelect({
    required this.itemCount,
    required this.itemBuilder,
    required this.onChanged,
    this.label,
    this.selected = const {},
  });

  final String? label;
  final Set<int> selected;
  final int itemCount;
  final Function(BuildContext, int) itemBuilder;
  final ValueChanged<Set<int>> onChanged;

  @override
  State<_MultiSelect> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<_MultiSelect> {
  static const int collapsedMax = 12;
  bool _collapsed = true;
  late final Set<int> _selected = {...widget.selected};
  late final ValueNotifier<int> _selectedLength = ValueNotifier(widget.selected.length);

  @override
  void dispose() {
    _selectedLength.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverMainAxisGroup(
        slivers: [
          if (widget.label != null || widget.itemCount > collapsedMax)
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    if (widget.label != null) Text(widget.label!, style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    ValueListenableBuilder(
                      valueListenable: _selectedLength,
                      builder: (context, value, child) =>
                          value > 0 ? Badge(label: Text(_selected.length.toString())) : child!,
                      child: const SizedBox(),
                    ),
                    if (widget.itemCount > collapsedMax)
                      SizedBox(
                        height: 24,
                        child: IconButton(
                          onPressed: () => setState(() => _collapsed = !_collapsed),
                          visualDensity: .compact,
                          style: const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size.zero)),
                          padding: .zero,
                          icon: Icon(
                            _collapsed ? Icons.keyboard_arrow_right_rounded : Icons.keyboard_arrow_down_rounded,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                ...List.generate(
                  _collapsed ? min(widget.itemCount, collapsedMax) : widget.itemCount,
                  (index) => StatefulBuilder(
                    builder: (context, setState) {
                      return _selected.contains(index)
                          ? FilledButton(
                              onPressed: () => _onPressed(context, index, setState),
                              child: widget.itemBuilder(context, index),
                            )
                          : FilledButton.tonal(
                              onPressed: () => _onPressed(context, index, setState),
                              child: widget.itemBuilder(context, index),
                            );
                    },
                  ),
                ),
                if (_collapsed && widget.itemCount > collapsedMax)
                  FilledButton.tonal(
                    onPressed: () => setState(() => _collapsed = !_collapsed),
                    child: const Icon(Icons.more_horiz_rounded),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onPressed(BuildContext context, int index, StateSetter setState) {
    if (_selected.contains(index)) {
      _selected.remove(index);
    } else {
      if (_selected.length >= 5) {
        // ScaffoldMessenger.of(context)
        return;
      }
      _selected.add(index);
    }
    _selectedLength.value = _selected.length;
    widget.onChanged(_selected);
    setState(() {});
  }
}

class _MediaSearchQueryButtons extends StatefulWidget {
  const _MediaSearchQueryButtons({required this.query, required this.onChanged});

  final MediaSearchQuery query;
  final ValueChanged<MediaSearchQuery> onChanged;

  @override
  State<_MediaSearchQueryButtons> createState() => _MediaSearchQueryButtonsState();
}

class _MediaSearchQueryButtonsState extends State<_MediaSearchQueryButtons> {
  late final _textController = TextEditingController(text: widget.query.search);
  late bool? _favorite = widget.query.favorite;
  late bool? _watched = widget.query.watched;
  late SortType? _sort = widget.query.sort;
  late SortDirection? _direction = widget.query.direction;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: IconButtonTheme(
              data: IconButtonThemeData(
                style: (IconButtonTheme.of(context).style ?? const ButtonStyle()).copyWith(
                  fixedSize: const WidgetStatePropertyAll(.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  iconSize: const WidgetStatePropertyAll(14),
                ),
              ),
              child: Row(
                spacing: 4,
                children: [
                  Expanded(
                    child: DropdownMenu(
                      initialSelection: _sort,
                      decorationBuilder: (context, _) => InputDecoration(
                        isDense: true,
                        filled: true,
                        border: const UnderlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide.none,
                        ),
                        visualDensity: VisualDensity.compact,
                        prefixIcon: const Icon(Icons.sort_rounded),
                        fillColor: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      onSelected: (type) {
                        _sort = type;
                        _onChanged();
                      },
                      dropdownMenuEntries: SortType.values
                          .map(
                            (value) => DropdownMenuEntry(
                              label: value.name,
                              value: value,
                              leadingIcon: Icon(switch (value) {
                                SortType.title => Icons.sort_by_alpha_rounded,
                                SortType.airDate => Icons.calendar_month_rounded,
                                SortType.createAt => Icons.add,
                                SortType.lastPlayedTime => Icons.play_arrow_rounded,
                                _ => null,
                              }, size: 18),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (_direction == .asc)
                    IconButton.filled(
                      onPressed: () {
                        _direction = .desc;
                        _onChanged();
                      },
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                  if (_direction == .desc)
                    IconButton.filled(
                      onPressed: () {
                        _direction = null;
                        _onChanged();
                      },
                      icon: const Icon(Icons.arrow_downward_rounded),
                    ),
                  if (_direction == null)
                    IconButton.filledTonal(
                      onPressed: () {
                        _direction = .asc;
                        _onChanged();
                      },
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                  Gap.hSM,
                  if (_favorite == true)
                    IconButton.filled(
                      onPressed: () {
                        _favorite = false;
                        _onChanged();
                      },
                      icon: const Icon(Icons.favorite_rounded),
                    ),
                  if (_favorite == false)
                    IconButton.filled(
                      onPressed: () {
                        _favorite = null;
                        _onChanged();
                      },
                      icon: const Icon(Icons.favorite_outline_rounded),
                    ),
                  if (_favorite == null)
                    IconButton.filledTonal(
                      onPressed: () {
                        _favorite = true;
                        _onChanged();
                      },
                      icon: const Icon(Icons.favorite_border_rounded),
                    ),
                  if (_watched == true)
                    IconButton.filled(
                      onPressed: () {
                        _watched = false;
                        _onChanged();
                      },
                      icon: const Icon(Icons.check),
                    ),
                  if (_watched == false)
                    IconButton.filled(
                      onPressed: () {
                        _watched = null;
                        _onChanged();
                      },
                      icon: const Icon(Icons.check),
                    ),
                  if (_watched == null)
                    IconButton.filledTonal(
                      onPressed: () {
                        _watched = true;
                        _onChanged();
                      },
                      icon: const Icon(Icons.check),
                    ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: TextFieldFocus(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  isDense: true,
                  visualDensity: .compact,
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: AppLocalizations.of(context)!.searchHint,
                  hintStyle: Theme.of(context).textTheme.labelSmall,
                ),
                onTapOutside: (_) {
                  _onChanged();
                  FocusScope.of(context).unfocus();
                },
                onEditingComplete: () {
                  _onChanged();
                  FocusScope.of(context).nextFocus();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onChanged() {
    setState(() {});
    widget.onChanged(
      widget.query.copyWith(
        favorite: _favorite,
        watched: _watched,
        sort: _sort,
        direction: _direction,
        search: _textController.text.trim(),
      ),
    );
  }
}
