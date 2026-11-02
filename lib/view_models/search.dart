import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../medias/search.dart';
import 'base.dart';

class SearchViewModel extends ViewModelBase<SearchFuzzyResult> {
  SearchViewModel() : snapshot = const .nothing();

  @override
  AsyncSnapshot<SearchFuzzyResult> snapshot;

  String? search;

  @override
  Future<void> load() async {
    if (search?.isEmpty ?? true) {
      snapshot = const AsyncSnapshot.withData(.done, SearchFuzzyResult());
    } else {
      try {
        snapshot = const AsyncSnapshot.waiting();
        notifyListeners();
        final SearchFuzzyResult data = await Api.searchFuzzy(MediaSearchQuery(search: search, limit: 15));
        snapshot = AsyncSnapshot.withData(.done, data);
      } catch (e) {
        snapshot = AsyncSnapshot.withError(.done, e);
      }
    }
    notifyListeners();
  }

  @override
  Widget build() {
    return ChangeNotifierProvider(create: (_) => this, child: const SearchPage());
  }
}
