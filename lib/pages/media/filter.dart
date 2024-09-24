import 'package:api/api.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/appbar_progress.dart';
import '../../components/async_image.dart';
import '../../components/future_builder_handler.dart';
import '../../components/gap.dart';
import '../../components/no_data.dart';
import '../../mixins/update.dart';
import '../../utils/utils.dart';
import '../detail/movie.dart';
import '../detail/series.dart';
import 'components/media_card.dart';

class FilterPage extends StatefulWidget {
  final QueryType queryType;
  final int? id;

  const FilterPage({super.key, this.queryType = QueryType.genre, this.id});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> with NeedUpdateMixin {
  late QueryType queryType = widget.queryType;

  late Future<List<Genre>> genres = Api.genreQueryAll();
  late Future<List<Studio>> studios = Api.studioQueryAll();
  late Future<List<Keyword>> keywords = Api.keywordQueryAll();
  late Future<List<Actor>> actors = Api.actorQueryAll();
  int? selectedGenre;
  int? selectedStudio;
  int? selectedKeyword;
  int? selectedActor;
  List<TVSeries> tvSeries = [];
  List<Movie> movies = [];

  @override
  void initState() {
    if (widget.id != null) {
      switch (queryType) {
        case QueryType.genre:
          selectedGenre = widget.id;
        case QueryType.studio:
          selectedStudio = widget.id;
        case QueryType.keyword:
          selectedKeyword = widget.id;
        case QueryType.actor:
          selectedActor = widget.id;
      }
      search();
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
                                queryType = value;
                              }),
                          itemBuilder: (context) => QueryType.values
                              .map((e) => CheckedPopupMenuItem(
                                    checked: e == queryType,
                                    value: e,
                                    child: Text(AppLocalizations.of(context)!.queryType(e.name)),
                                  ))
                              .toList(),
                          child: _FilterButton(text: AppLocalizations.of(context)!.queryType(queryType.name))),
                    ),
                    if (queryType == QueryType.genre)
                      FutureBuilderHandler(
                          initialData: const <Genre>[],
                          future: genres,
                          builder: (context, snapshot) {
                            final selected = snapshot.requireData.firstWhereOrNull((e) => e.id == selectedGenre);
                            return PopupMenuButton(
                                onSelected: (value) {
                                  selectedGenre = value;
                                  search();
                                  setState(() {});
                                },
                                itemBuilder: (context) => snapshot.requireData
                                    .map((e) => CheckedPopupMenuItem(
                                          checked: e.id == selectedGenre,
                                          value: e.id,
                                          child: Text(e.name),
                                        ))
                                    .toList(),
                                child: _FilterButton(text: selected?.name ?? AppLocalizations.of(context)!.unselect));
                          }),
                    if (queryType == QueryType.studio)
                      FutureBuilderHandler(
                          initialData: const <Studio>[],
                          future: studios,
                          builder: (context, snapshot) {
                            final selected = snapshot.requireData.firstWhereOrNull((e) => e.id == selectedStudio);
                            return PopupMenuButton(
                                onSelected: (value) {
                                  selectedStudio = value;
                                  search();
                                  setState(() {});
                                },
                                itemBuilder: (context) => snapshot.requireData
                                    .map((e) => CheckedPopupMenuItem(
                                          checked: e.id == selectedStudio,
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
                    if (queryType == QueryType.keyword)
                      FutureBuilderHandler(
                          initialData: const <Keyword>[],
                          future: keywords,
                          builder: (context, snapshot) {
                            final selected = snapshot.requireData.firstWhereOrNull((e) => e.id == selectedKeyword);
                            return PopupMenuButton(
                                onSelected: (value) {
                                  selectedKeyword = value;
                                  search();
                                },
                                itemBuilder: (context) => snapshot.requireData
                                    .map((e) => CheckedPopupMenuItem(
                                          checked: e.id == selectedKeyword,
                                          value: e.id,
                                          child: Text(e.name),
                                        ))
                                    .toList(),
                                child: _FilterButton(text: selected?.name ?? AppLocalizations.of(context)!.unselect));
                          }),
                    if (queryType == QueryType.actor)
                      FutureBuilderHandler(
                          initialData: const <Actor>[],
                          future: actors,
                          builder: (context, snapshot) {
                            final selected = snapshot.requireData.firstWhereOrNull((e) => e.id == selectedActor);
                            return PopupMenuButton(
                                onSelected: (value) {
                                  selectedActor = value;
                                  search();
                                },
                                itemBuilder: (context) => snapshot.requireData
                                    .map((e) => CheckedPopupMenuItem(
                                          checked: e.id == selectedActor,
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
                                  imageWidth: 40,
                                  imageHeight: 60,
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
          if (tvSeries.isEmpty)
            const SliverSafeArea(sliver: SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: NoData())))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, childAspectRatio: 0.56),
                  itemCount: tvSeries.length,
                  itemBuilder: (context, index) {
                    final item = tvSeries[index];
                    return MediaCard(
                      key: ValueKey(item.id),
                      item: item,
                      onTap: () async {
                        final flag = await navigateTo<bool>(context, TVDetail(tvSeriesId: item.id, initialData: item));
                        if (flag == true) setState(() {});
                      },
                    );
                  }),
            ),
          SliverToBoxAdapter(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Text(AppLocalizations.of(context)!.homeTabMovie, style: Theme.of(context).textTheme.titleLarge),
          )),
          if (movies.isEmpty)
            const SliverSafeArea(sliver: SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: NoData())))
          else
            SliverSafeArea(
                sliver: SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, childAspectRatio: 0.56),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final item = movies[index];
                    return MediaCard(
                      key: ValueKey(item.id),
                      item: item,
                      onTap: () async {
                        final flag = await navigateTo<bool>(context, MovieDetail(item.id, initialData: item));
                        if (flag == true) setState(() {});
                      },
                    );
                  }),
            )),
          const SliverToBoxAdapter(child: Focus(child: SizedBox())),
        ],
      ),
    );
  }

  search() async {
    switch (queryType) {
      case QueryType.genre:
        if (selectedGenre != null) {
          tvSeries = await Api.tvSeriesQueryByFilter(queryType, selectedGenre!);
          movies = await Api.movieQueryByFilter(queryType, selectedGenre!);
        }
      case QueryType.studio:
        if (selectedStudio != null) {
          tvSeries = await Api.tvSeriesQueryByFilter(queryType, selectedStudio!);
          movies = await Api.movieQueryByFilter(queryType, selectedStudio!);
        }
      case QueryType.keyword:
        if (selectedKeyword != null) {
          tvSeries = await Api.tvSeriesQueryByFilter(queryType, selectedKeyword!);
          movies = await Api.movieQueryByFilter(queryType, selectedKeyword!);
        }
      case QueryType.actor:
        if (selectedActor != null) {
          tvSeries = await Api.tvSeriesQueryByFilter(queryType, selectedActor!);
          movies = await Api.movieQueryByFilter(queryType, selectedActor!);
        }
    }
    setState(() {});
  }
}

class _FilterButton extends StatelessWidget {
  final String text;
  final double? width;
  final double imageWidth;
  final double imageHeight;
  final EdgeInsets imagePadding;
  final String? image;

  const _FilterButton({
    this.width,
    required this.text,
    this.image,
    this.imageWidth = 40,
    this.imageHeight = 60,
    this.imagePadding = EdgeInsets.zero,
  });

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
                children: [
                  width == null ? Text(text) : Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
                  if (image != null) Gap.hMD,
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
