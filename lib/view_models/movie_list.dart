import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../medias/movie_list.dart';
import 'base.dart';

class MovieListViewModelData {
  const MovieListViewModelData({
    required this.recommendation,
    required this.watchNow,
    required this.favorite,
    required this.newAdd,
    required this.newRelease,
    required this.all,
  });

  final List<MediaRecommendation> recommendation;
  final List<Movie> watchNow;
  final List<Movie> favorite;
  final List<Movie> newAdd;
  final List<Movie> newRelease;
  final PagingState<int, Movie> all;

  MovieListViewModelData copyWith({
    List<MediaRecommendation>? recommendation,
    List<Movie>? watchNow,
    List<Movie>? favorite,
    List<Movie>? newAdd,
    List<Movie>? newRelease,
    PagingState<int, Movie>? all,
  }) {
    return MovieListViewModelData(
      recommendation: recommendation ?? this.recommendation,
      watchNow: watchNow ?? this.watchNow,
      favorite: favorite ?? this.favorite,
      newAdd: newAdd ?? this.newAdd,
      newRelease: newRelease ?? this.newRelease,
      all: all ?? this.all,
    );
  }
}

class MovieListViewModel extends ViewModelBase<MovieListViewModelData> {
  MovieListViewModel() : snapshot = const .waiting() {
    _subscription = MergeStream([
      MergeStream([
        EventDispatcher.where(type: .server, subType: .update),
        EventDispatcher.where(type: .storage, subType: .delete),
        EventDispatcher.where(type: .library, subType: .update),
        EventDispatcher.where(type: .library, subType: .delete),
      ]).where((_) => snapshot.hasData).doOnData((_) => load()),
      MergeStream([EventDispatcher.where(type: .movie, subType: .update)]).where((_) => snapshot.hasData).doOnData((
        event,
      ) async {
        final Movie movie = await Api.movieQueryById(event.id);
        final MovieListViewModelData data = snapshot.requireData;
        snapshot = AsyncSnapshot.withData(
          .done,
          .new(
            recommendation: data.recommendation,
            watchNow: await Api.movieNextToPlayQueryAll(),
            favorite: await Api.movieQueryAll(
              const MediaSearchQuery(sort: SortType.title, direction: SortDirection.desc, favorite: true, limit: 15),
            ).then((data) => data.data),
            newAdd: data.newAdd.map((item) => item.id != event.id ? item : movie).toList(),
            newRelease: data.newRelease.map((item) => item.id != event.id ? item : movie).toList(),
            all: data.all.copyWith(
              pages: data.all.pages
                  ?.map((page) => page.map((item) => item.id != event.id ? item : movie).toList())
                  .toList(),
            ),
          ),
        );
        notifyListeners();
      }),
      EventDispatcher.where(type: .movie, subType: .delete).where((_) => snapshot.hasData).doOnData((event) {
        final MovieListViewModelData data = snapshot.requireData;
        snapshot = AsyncSnapshot.withData(
          .done,
          .new(
            recommendation: data.recommendation.where((item) => item.id != event.id).toList(),
            watchNow: data.watchNow.where((item) => item.id != event.id).toList(),
            favorite: data.favorite.where((item) => item.id != event.id).toList(),
            newAdd: data.newAdd.where((item) => item.id != event.id).toList(),
            newRelease: data.newRelease.where((item) => item.id != event.id).toList(),
            all: data.all.copyWith(
              pages: data.all.pages?.map((page) => page.where((item) => item.id != event.id).toList()).toList(),
            ),
          ),
        );
        notifyListeners();
      }),
    ]).listen((_) {});
  }

  StreamSubscription<EventData>? _subscription;

  @override
  AsyncSnapshot<MovieListViewModelData> snapshot;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Future<void> load() async {
    try {
      final List<List<dynamic>> data = await Future.wait([
        Api.movieRecommendation(),
        Api.movieNextToPlayQueryAll(),
        Api.movieQueryAll(
          const MediaSearchQuery(sort: SortType.title, direction: SortDirection.desc, favorite: true, limit: 15),
        ).then((data) => data.data),
        Api.movieQueryAll(const MediaSearchQuery(sort: SortType.createAt, direction: SortDirection.desc, limit: 15))
            .then((data) => data.data),
        Api.movieQueryAll(const MediaSearchQuery(sort: SortType.airDate, direction: SortDirection.desc, limit: 15))
            .then((data) => data.data),
      ]);
      snapshot = AsyncSnapshot.withData(
        .done,
        .new(
          recommendation: data[0].cast(),
          watchNow: data[1].cast(),
          favorite: data[2].cast(),
          newAdd: data[3].cast(),
          newRelease: data[4].cast(),
          all: PagingState(),
        ),
      );
    } catch (e) {
      snapshot = AsyncSnapshot.withError(.done, e);
    }
    notifyListeners();
  }

  @override
  Widget build() {
    return ChangeNotifierProvider(create: (_) => this, child: const MovieListPage());
  }

  Future<void> fetchNextPage() async {
    final PagingState<int, Movie> state = snapshot.requireData.all;
    if (state.isLoading) {
      return;
    }

    await Future.value();

    snapshot = AsyncSnapshot.withData(
      .done,
      snapshot.requireData.copyWith(all: state.copyWith(isLoading: true, error: null)),
    );
    notifyListeners();

    try {
      final int newKey = (state.keys?.last ?? -1) + 1;
      final PageData<Movie> data = await Api.movieQueryAll(
        MediaSearchQuery(limit: 30, offset: 30 * newKey, sort: .title),
      );
      final hasNextPage = data.data.length == data.limit;
      snapshot = AsyncSnapshot.withData(
        .done,
        snapshot.requireData.copyWith(
          all: state.copyWith(
            pages: [...?state.pages, data.data],
            keys: [...?state.keys, newKey],
            hasNextPage: hasNextPage,
            isLoading: false,
          ),
        ),
      );
      notifyListeners();
    } catch (error) {
      snapshot = AsyncSnapshot.withData(
        .done,
        snapshot.requireData.copyWith(all: state.copyWith(error: error, isLoading: false)),
      );
      notifyListeners();
    }
  }
}
