import 'package:api/api.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/async_image.dart';
import '../../components/future_builder_handler.dart';
import '../../components/no_data.dart';
import '../../utils/utils.dart';
import '../components/appbar_progress.dart';
import '../components/image_card.dart';
import '../detail/movie.dart';
import '../detail/series.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key, this.queryType = QueryType.genre, this.id});

  final QueryType queryType;
  final int? id;

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late QueryType _queryType = widget.queryType;

  late final Future<List<Genre>> _genres = Api.genreQueryAll();
  late final Future<List<Studio>> _studios = Api.studioQueryAll();
  late final Future<List<Keyword>> _keywords = Api.keywordQueryAll();
  late final Future<List<Actor>> _actors = Api.actorQueryAll();
  int? _selectedGenre;
  int? _selectedStudio;
  int? _selectedKeyword;
  int? _selectedActor;
  List<TVSeries> _tvSeries = [];
  List<Movie> _movies = [];

  @override
  void initState() {
    if (widget.id != null) {
      switch (_queryType) {
        case QueryType.genre:
          _selectedGenre = widget.id;
        case QueryType.studio:
          _selectedStudio = widget.id;
        case QueryType.keyword:
          _selectedKeyword = widget.id;
        case QueryType.actor:
          _selectedActor = widget.id;
      }
      _search();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pageTitleFilter),
        bottom: const AppbarProgressIndicator(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.formLabelFilterCategory, style: Theme.of(context).textTheme.labelMedium),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: PopupMenuButton(
                          onSelected: (value) => setState(() {
                                _queryType = value;
                              }),
                          itemBuilder: (context) => QueryType.values
                              .map((e) => CheckedPopupMenuItem(
                                    checked: e == _queryType,
                                    value: e,
                                    child: Text(AppLocalizations.of(context)!.queryType(e.name)),
                                  ))
                              .toList(),
                          child: _FilterButton(text: AppLocalizations.of(context)!.queryType(_queryType.name))),
                    ),
                    if (_queryType == QueryType.genre)
                      FutureBuilderHandler(
                          initialData: const <Genre>[],
                          future: _genres,
                          builder: (context, snapshot) {
                            final selected = snapshot.requireData.firstWhereOrNull((e) => e.id == _selectedGenre);
                            return PopupMenuButton(
                                onSelected: (value) {
                                  _selectedGenre = value;
                                  _search();
                                  setState(() {});
                                },
                                itemBuilder: (context) => snapshot.requireData
                                    .map((e) => CheckedPopupMenuItem(
                                          checked: e.id == _selectedGenre,
                                          value: e.id,
                                          child: Text(e.name),
                                        ))
                                    .toList(),
                                child: _FilterButton(text: selected?.name ?? AppLocalizations.of(context)!.unselect));
                          }),
                    if (_queryType == QueryType.studio)
                      FutureBuilderHandler(
                          initialData: const <Studio>[],
                          future: _studios,
                          builder: (context, snapshot) {
                            final selected = snapshot.requireData.firstWhereOrNull((e) => e.id == _selectedStudio);
                            return PopupMenuButton(
                                onSelected: (value) {
                                  _selectedStudio = value;
                                  _search();
                                  setState(() {});
                                },
                                itemBuilder: (context) => snapshot.requireData
                                    .map((e) => CheckedPopupMenuItem(
                                          checked: e.id == _selectedStudio,
                                          value: e.id,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(child: Text(e.name, overflow: TextOverflow.ellipsis)),
                                              if (e.logo != null) AsyncImage(e.logo!, height: 40, width: 60, fit: BoxFit.contain),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                child: _FilterButton(
                                  width: 200,
                                  text: selected?.name ?? AppLocalizations.of(context)!.unselect,
                                  image: selected?.logo,
                                  imageWidth: 80,
                                  imageHeight: 40,
                                  imagePadding: const EdgeInsets.only(right: 4),
                                ));
                          }),
                    if (_queryType == QueryType.keyword)
                      FutureBuilderHandler(
                          initialData: const <Keyword>[],
                          future: _keywords,
                          builder: (context, snapshot) {
                            final selected = snapshot.requireData.firstWhereOrNull((e) => e.id == _selectedKeyword);
                            return PopupMenuButton(
                                onSelected: (value) {
                                  _selectedKeyword = value;
                                  _search();
                                },
                                itemBuilder: (context) => snapshot.requireData
                                    .map((e) => CheckedPopupMenuItem(
                                          checked: e.id == _selectedKeyword,
                                          value: e.id,
                                          child: Text(e.name),
                                        ))
                                    .toList(),
                                child: _FilterButton(text: selected?.name ?? AppLocalizations.of(context)!.unselect));
                          }),
                    if (_queryType == QueryType.actor)
                      FutureBuilderHandler(
                          initialData: const <Actor>[],
                          future: _actors,
                          builder: (context, snapshot) {
                            final selected = snapshot.requireData.firstWhereOrNull((e) => e.id == _selectedActor);
                            return PopupMenuButton(
                                onSelected: (value) {
                                  _selectedActor = value;
                                  _search();
                                },
                                itemBuilder: (context) => snapshot.requireData
                                    .map((e) => CheckedPopupMenuItem(
                                          checked: e.id == _selectedActor,
                                          value: e.id,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(child: Text(e.name, overflow: TextOverflow.ellipsis)),
                                              if (e.profile != null) AsyncImage(e.profile!, height: 40, width: 30, fit: BoxFit.contain),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                child: _FilterButton(
                                  text: selected?.name ?? AppLocalizations.of(context)!.unselect,
                                  image: selected?.profile,
                                  width: 200,
                                ));
                          }),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Text(AppLocalizations.of(context)!.homeTabTV, style: Theme.of(context).textTheme.titleLarge),
          )),
          if (_tvSeries.isEmpty)
            const SliverSafeArea(sliver: SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: NoData())))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
                    childAspectRatio: 0.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: _tvSeries.length,
                  itemBuilder: (context, index) {
                    final item = _tvSeries[index];
                    return ImageCard(
                      key: ValueKey(item.id),
                      item.poster,
                      title: Text(item.displayRecentTitle()),
                      subtitle: Text(item.airDate?.format() ?? ''),
                      onTap: () async {
                        final flag = await navigateTo<bool>(context, TVDetail(item.id, initialData: item));
                        if (flag ?? false) setState(() {});
                      },
                    );
                  }),
            ),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Text(AppLocalizations.of(context)!.homeTabMovie, style: Theme.of(context).textTheme.titleLarge),
          )),
          if (_movies.isEmpty)
            const SliverSafeArea(sliver: SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: NoData())))
          else
            SliverSafeArea(
                sliver: SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
                    childAspectRatio: 0.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: _movies.length,
                  itemBuilder: (context, index) {
                    final item = _movies[index];
                    return ImageCard(
                      item.poster,
                      title: Text(item.displayRecentTitle()),
                      subtitle: Text(item.airDate?.format() ?? ''),
                      onTap: () async {
                        final flag = await navigateTo<bool>(context, MovieDetail(item.id, initialData: item));
                        if (flag ?? false) setState(() {});
                      },
                    );
                  }),
            )),
          const SliverToBoxAdapter(child: Focus(child: SizedBox())),
        ],
      ),
    );
  }

  Future<void> _search() async {
    switch (_queryType) {
      case QueryType.genre:
        if (_selectedGenre != null) {
          _tvSeries = await Api.tvSeriesQueryByFilter(_queryType, _selectedGenre!);
          _movies = await Api.movieQueryByFilter(_queryType, _selectedGenre!);
        }
      case QueryType.studio:
        if (_selectedStudio != null) {
          _tvSeries = await Api.tvSeriesQueryByFilter(_queryType, _selectedStudio!);
          _movies = await Api.movieQueryByFilter(_queryType, _selectedStudio!);
        }
      case QueryType.keyword:
        if (_selectedKeyword != null) {
          _tvSeries = await Api.tvSeriesQueryByFilter(_queryType, _selectedKeyword!);
          _movies = await Api.movieQueryByFilter(_queryType, _selectedKeyword!);
        }
      case QueryType.actor:
        if (_selectedActor != null) {
          _tvSeries = await Api.tvSeriesQueryByFilter(_queryType, _selectedActor!);
          _movies = await Api.movieQueryByFilter(_queryType, _selectedActor!);
        }
    }
    setState(() {});
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    this.width,
    required this.text,
    this.image,
    this.imageWidth = 40,
    this.imageHeight = 60,
    this.imagePadding = EdgeInsets.zero,
  });

  final String text;
  final double? width;
  final double imageWidth;
  final double imageHeight;
  final EdgeInsets imagePadding;
  final String? image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: 48,
        child: Material(
          type: MaterialType.card,
          color: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          shape: Theme.of(context).cardTheme.shape,
          elevation: Theme.of(context).cardTheme.elevation ?? 1,
          clipBehavior: Clip.antiAlias,
          child: InkResponse(
            child: Padding(
              padding: image != null ? const EdgeInsets.only(left: 16) : const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 12,
                children: [
                  if (width == null) Text(text) else Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
                  if (image != null)
                    AsyncImage(
                      image!,
                      ink: true,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerRight,
                      padding: imagePadding,
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
