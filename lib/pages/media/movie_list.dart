import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/error_message.dart';
import '../../utils/utils.dart';
import '../components/image_card.dart';
import '../detail/movie.dart';
import '../library.dart';
import 'components/carousel.dart';
import 'components/channel.dart';
import 'components/media_scaffold.dart';
import 'search.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  final _backdrop = ValueNotifier<String?>(null);
  StreamSubscription<double?>? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription = Api.needUpdate$.listen((event) {
      if (mounted) context.read<MovieListCubit>().update();
    });
  }

  @override
  void dispose() {
    _backdrop.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<MovieListCubit>().update(),
      child: MediaScaffold(backdrop: _backdrop, slivers: [
        BlocBuilder<MovieListCubit, AsyncSnapshot<MovieListModel>>(builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
            case ConnectionState.done:
              if (snapshot.hasData) {
                return MediaCarousel<MovieListCubit, AsyncSnapshot<MovieListModel>>(
                  onChanged: (index) {
                    _backdrop.value = context.read<MovieListCubit>().state.data?.carousels[index].backdrop;
                  },
                  noDataBuilder: (context) => FilledButton(
                    child: Text(AppLocalizations.of(context)!.settingsItemMovie),
                    onPressed: () => navigateTo(context, const LibraryManage(type: LibraryType.movie)),
                  ),
                  selector: (state) => state?.data?.carousels.length,
                  itemBuilder: (BuildContext context, int index) => BlocSelector<MovieListCubit, AsyncSnapshot<MovieListModel>, MediaRecommendation>(
                      selector: (state) => state.requireData.carousels[index],
                      builder: (context, item) => CarouselItem(
                            item: item,
                            onPressed: () async {
                              final series = await Api.movieQueryById(item.id);
                              if (context.mounted) await _onMediaTap(context, series);
                            },
                          )),
                );
              } else {
                return SliverFillRemaining(child: Center(child: ErrorMessage(error: snapshot.error)));
              }
          }
        }),
        MediaChannel<MovieListCubit, AsyncSnapshot<MovieListModel>>(
          label: AppLocalizations.of(context)!.watchNow,
          height: 230,
          selector: (state) => state?.data?.watchNow.length ?? 0,
          builder: _buildRecentMediaCard,
        ),
        MediaChannel<MovieListCubit, AsyncSnapshot<MovieListModel>>(
          label: '收藏夹',
          more: IconButton(
              onPressed: () {
                navigateTo(context, const SearchPage(filterType: [FilterType.favorite], activeTab: 1));
              },
              icon: const Icon(Icons.chevron_right)),
          selector: (state) => state?.data?.favorite.length ?? 0,
          height: 230,
          builder: (context, index) => _buildMediaCard(context, (state) => state.requireData.favorite[index], width: 120, height: 180),
        ),
        MediaChannel<MovieListCubit, AsyncSnapshot<MovieListModel>>(
          label: AppLocalizations.of(context)!.tagNewAdd,
          selector: (state) => state?.data?.newAdd.length ?? 0,
          height: 230,
          builder: (context, index) => _buildMediaCard(context, (state) => state.requireData.newAdd[index], width: 120, height: 180),
        ),
        MediaChannel<MovieListCubit, AsyncSnapshot<MovieListModel>>(
          label: AppLocalizations.of(context)!.tagNewRelease,
          selector: (state) => state?.data?.newRelease.length ?? 0,
          height: 230,
          builder: (context, index) => _buildMediaCard(context, (state) => state.requireData.newRelease[index], width: 120, height: 180),
        ),
        MediaGridChannel<MovieListCubit, AsyncSnapshot<MovieListModel>>(
          label: AppLocalizations.of(context)!.tagAll,
          selector: (state) => state?.data?.all.length ?? 0,
          builder: (context, index) => _buildMediaCard(context, (state) => state.requireData.all[index]),
        ),
      ]),
    );
  }

  Widget _buildRecentMediaCard(BuildContext context, int index) {
    return BlocSelector<MovieListCubit, AsyncSnapshot<MovieListModel>, Movie>(
        selector: (state) => state.requireData.watchNow[index],
        builder: (context, item) {
          return ImageCard(
            item.poster,
            width: 120,
            height: 180,
            title: Text(item.displayRecentTitle()),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item.lastPlayedTime != null)
                  Text(AppLocalizations.of(context)!.timeAgo(item.lastPlayedTime!.fromNow().fromNowFormat(context)),
                      style: Theme.of(context).textTheme.labelSmall)
                else
                  const Spacer(),
                if (item.duration != null && item.duration != Duration.zero && item.lastPlayedPosition != null)
                  Text('${(item.lastPlayedPosition!.inSeconds / item.duration!.inSeconds * 100).toStringAsFixed(1)}%'),
              ],
            ),
            floating: item.duration != null && item.duration != Duration.zero && item.lastPlayedPosition != null
                ? Align(
                    alignment: const Alignment(0, 0.95),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: LinearProgressIndicator(
                        value: item.lastPlayedPosition!.inSeconds / item.duration!.inSeconds,
                        color: Theme.of(context).colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(3),
                        minHeight: 3,
                      ),
                    ),
                  )
                : null,
            onTap: () async {
              final movie = await Api.movieQueryById(item.id);
              if (context.mounted) await _onMediaTap(context, movie);
            },
          );
        });
  }

  Widget _buildMediaCard(BuildContext context, BlocWidgetSelector<AsyncSnapshot<MovieListModel>, Movie> selector, {double? width, double? height}) {
    return BlocSelector<MovieListCubit, AsyncSnapshot<MovieListModel>, Movie>(
        selector: selector,
        builder: (context, item) {
          return ImageCard(
            item.poster,
            width: width,
            height: height,
            title: Text(item.displayRecentTitle()),
            subtitle: Text(item.releaseDate?.format() ?? ''),
            floating: MediaBadges(item: item),
            onTap: () => _onMediaTap(context, item),
          );
        });
  }

  Future<void> _onMediaTap(BuildContext context, Movie item) async {
    await navigateTo(context, MovieDetail(item.id, initialData: item));
    if (context.mounted) context.read<MovieListCubit>().update();
  }
}

class MovieListModel {
  const MovieListModel({
    required this.carousels,
    required this.watchNow,
    required this.favorite,
    required this.newAdd,
    required this.newRelease,
    required this.all,
  });

  final List<MediaRecommendation> carousels;
  final List<Movie> watchNow;
  final List<Movie> newAdd;
  final List<Movie> favorite;
  final List<Movie> newRelease;
  final List<Movie> all;
}

class MovieListCubit extends Cubit<AsyncSnapshot<MovieListModel>> {
  MovieListCubit(super.initialState) {
    update();
  }

  Future<void> update() async {
    try {
      if (state.hasError) {
        emit(const AsyncSnapshot.waiting());
      }
      final items = await Future.wait([
        Api.movieRecommendation(),
        Api.movieNextToPlayQueryAll(),
        Api.movieQueryAll(
            const MediaSearchQuery(sort: SortConfig(type: SortType.createAt, direction: SortDirection.desc, filter: FilterType.favorite), limit: 8)),
        Api.movieQueryAll(const MediaSearchQuery(sort: SortConfig(type: SortType.createAt, direction: SortDirection.desc), limit: 8)),
        Api.movieQueryAll(const MediaSearchQuery(sort: SortConfig(type: SortType.airDate, direction: SortDirection.desc), limit: 8)),
        Api.movieQueryAll(const MediaSearchQuery(sort: SortConfig(type: SortType.title, direction: SortDirection.asc)))
      ]);
      emit(AsyncSnapshot.withData(
          ConnectionState.done,
          MovieListModel(
            carousels: items[0] as List<MediaRecommendation>,
            watchNow: items[1] as List<Movie>,
            favorite: items[2] as List<Movie>,
            newAdd: items[3] as List<Movie>,
            newRelease: items[4] as List<Movie>,
            all: items[5] as List<Movie>,
          )));
    } catch (e) {
      emit(AsyncSnapshot.withError(ConnectionState.done, e));
    }
  }
}
