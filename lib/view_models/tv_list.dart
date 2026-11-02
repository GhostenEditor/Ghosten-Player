import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../medias/tv_list.dart';
import 'base.dart';

class TvListViewModelData {
  const TvListViewModelData({
    required this.recommendation,
    required this.watchNow,
    required this.favorite,
    required this.newAdd,
    required this.newRelease,
    required this.all,
  });

  final List<MediaRecommendation> recommendation;
  final List<TVEpisode> watchNow;
  final List<TVSeries> favorite;
  final List<TVSeries> newAdd;
  final List<TVSeries> newRelease;
  final PagingState<int, TVSeries> all;

  TvListViewModelData copyWith({
    List<MediaRecommendation>? recommendation,
    List<TVEpisode>? watchNow,
    List<TVSeries>? favorite,
    List<TVSeries>? newAdd,
    List<TVSeries>? newRelease,
    PagingState<int, TVSeries>? all,
  }) {
    return TvListViewModelData(
      recommendation: recommendation ?? this.recommendation,
      watchNow: watchNow ?? this.watchNow,
      favorite: favorite ?? this.favorite,
      newAdd: newAdd ?? this.newAdd,
      newRelease: newRelease ?? this.newRelease,
      all: all ?? this.all,
    );
  }
}

class TvListViewModel extends ViewModelBase<TvListViewModelData> {
  TvListViewModel() : snapshot = const .waiting() {
    _subscription = MergeStream([
      MergeStream([
        EventDispatcher.where(type: .server, subType: .update),
        EventDispatcher.where(type: .storage, subType: .delete),
        EventDispatcher.where(type: .library, subType: .update),
        EventDispatcher.where(type: .library, subType: .delete),
      ]).where((_) => snapshot.hasData).doOnData((_) => load()),
      MergeStream([EventDispatcher.where(type: .series, subType: .update)]).where((_) => snapshot.hasData).doOnData((
        event,
      ) async {
        final TVSeries series = await Api.tvSeriesQueryById(event.id);
        final TvListViewModelData data = snapshot.requireData;
        snapshot = AsyncSnapshot.withData(
          .done,
          .new(
            recommendation: data.recommendation,
            watchNow: await Api.tvSeriesNextToPlayQueryAll(),
            favorite: await Api.tvSeriesQueryAll(
              const MediaSearchQuery(sort: SortType.title, direction: SortDirection.desc, favorite: true, limit: 15),
            ).then((data) => data.data),
            newAdd: data.newAdd.map((item) => item.id != event.id ? item : series).toList(),
            newRelease: data.newRelease.map((item) => item.id != event.id ? item : series).toList(),
            all: data.all.copyWith(
              pages: data.all.pages
                  ?.map((page) => page.map((item) => item.id != event.id ? item : series).toList())
                  .toList(),
            ),
          ),
        );
        notifyListeners();
      }),
      EventDispatcher.where(type: .series, subType: .delete).where((_) => snapshot.hasData).doOnData((event) {
        final TvListViewModelData data = snapshot.requireData;
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
  AsyncSnapshot<TvListViewModelData> snapshot;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Future<void> load() async {
    try {
      final List<List<dynamic>> data = await Future.wait([
        Api.tvRecommendation(),
        Api.tvSeriesNextToPlayQueryAll(),
        Api.tvSeriesQueryAll(
          const MediaSearchQuery(sort: SortType.title, direction: SortDirection.desc, favorite: true, limit: 15),
        ).then((data) => data.data),
        Api.tvSeriesQueryAll(const MediaSearchQuery(sort: SortType.createAt, direction: SortDirection.desc, limit: 15))
            .then((data) => data.data),
        Api.tvSeriesQueryAll(const MediaSearchQuery(sort: SortType.airDate, direction: SortDirection.desc, limit: 15))
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
    return ChangeNotifierProvider(create: (_) => this, child: const TVListPage());
  }

  Future<void> fetchNextPage() async {
    final PagingState<int, TVSeries> state = snapshot.requireData.all;
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
      final PageData<TVSeries> data = await Api.tvSeriesQueryAll(
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
