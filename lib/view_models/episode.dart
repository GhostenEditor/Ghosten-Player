import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../adaptive/adaptive.dart';
import 'base.dart';

class EpisodeViewModel extends ViewModelBase<TVEpisode> {
  EpisodeViewModel(BuildContext context, {this.id, TVEpisode? data})
    : snapshot = data != null ? AsyncSnapshot.withData(.waiting, data) : const AsyncSnapshot.waiting() {
    _subscription = MergeStream([
      EventDispatcher.where(type: .episode, subType: .update, id: id).doOnData((_) => load()),
      EventDispatcher.where(type: .episode, subType: .delete, id: id).doOnData((_) => Navigator.of(context).pop()),
    ]).listen((_) {});
  }

  final dynamic id;
  StreamSubscription<EventData>? _subscription;

  @override
  AsyncSnapshot<TVEpisode> snapshot;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Future<void> load() async {
    try {
      final TVEpisode data = await Api.tvEpisodeQueryById(id);
      snapshot = AsyncSnapshot.withData(.done, data);
    } catch (e) {
      snapshot = AsyncSnapshot.withError(.done, e);
    }
    notifyListeners();
  }

  @override
  Widget build() {
    return ChangeNotifierProvider(create: (_) => this, child: const EpisodePage());
  }
}
