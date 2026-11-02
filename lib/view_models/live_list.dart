import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../medias/live_list.dart';
import 'base.dart';

class LiveListViewModel extends ListViewModelBase<Playlist> {
  LiveListViewModel() : snapshot = const .waiting() {
    _subscription = MergeStream([EventDispatcher.where(type: .playlist).doOnData((_) => load())]).listen((_) {});
  }

  StreamSubscription<EventData>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  AsyncSnapshot<List<Playlist>> snapshot;

  @override
  Widget build() {
    return ChangeNotifierProvider(create: (_) => this, child: const LiveListPage());
  }

  @override
  Future<void> load() async {
    try {
      final List<Playlist> data = await Api.playlistQueryAll();
      snapshot = AsyncSnapshot.withData(.done, data);
    } catch (e) {
      snapshot = AsyncSnapshot.withError(.done, e);
    }
    notifyListeners();
  }
}
