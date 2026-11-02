import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/player.dart';

import '../platform_api.dart';

class CastDevice extends PlayerBaseController {
  CastDevice({required this.id, required this.friendlyName});

  factory CastDevice.fromJson(dynamic data) {
    // ignore: avoid_dynamic_calls
    return CastDevice(id: data[0], friendlyName: data[1]);
  }

  final String friendlyName;
  final String id;

  late final Stream<(int, int)> _stream = PlatformApi.screenEvent
      .switchMap(
        (value) => switch (value) {
          ScreenState.on || ScreenState.off => Stream.periodic(const Duration(seconds: 1)),
          ScreenState.present => Stream.periodic(const Duration(seconds: 1)).switchMap(
            (_) => Stream.fromFuture(
              Future.microtask(() async {
                try {
                  final data = await Api.dlnaGetPositionInfo(id) as Map<String, dynamic>;
                  final int duration = data['duration'];
                  final int position = data['position'];
                  return (position, duration);
                } catch (e) {
                  return null;
                }
              }),
            ),
          ),
        },
      )
      .mapNotNull((e) => e);

  @override
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);
  @override
  final ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);
  @override
  final ValueNotifier<Duration> bufferedPosition = ValueNotifier(Duration.zero);
  @override
  final ValueNotifier<PlaybackState> playbackState = ValueNotifier(PlaybackState.idle);
  @override
  final ValueNotifier<String?> fatalError = ValueNotifier(null);
  @override
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);

  @override
  final ValueNotifier<dynamic> error = ValueNotifier(null);

  StreamSubscription<dynamic>? _subscription;

  bool disposed = false;

  Future<dynamic> getMediaInfo() {
    return Api.dlnaGetMediaInfo(id).catchError(onError);
  }

  Future<dynamic> getTransportInfo() {
    return Api.dlnaGetTransportInfo(id).catchError(onError);
  }

  Future<double> getVolume() {
    return Api.dlnaGetVolume(id);
  }

  Future<void> setUrl(Uri uri, {String? title, String playType = 'video'}) {
    return Api.dlnaSetUri(id, uri, title: title, playType: playType).catchError(onError);
  }

  Future<void> pause() async {
    return Api.dlnaPause(id).catchError(onError);
  }

  Future<void> play() {
    return Api.dlnaPlay(id).catchError(onError);
  }

  Future<void> seek(Duration seek) {
    return Api.dlnaSeek(id, seek).catchError(onError);
  }

  Future<void> start() async {
    _subscription = _stream.listen((data) {
      position.value = Duration(seconds: data.$1);
      duration.value = Duration(seconds: data.$2);
    });
  }

  Future<void> stop() {
    _subscription?.cancel();
    return Api.dlnaStop(id).catchError(onError);
  }

  Future<void> setVolume(double volume) {
    return Api.dlnaSetVolume(id, volume).catchError(onError);
  }

  @override
  Future<String?> getVideoThumbnail(int position) {
    throw UnimplementedError();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  void onError(dynamic error) {
    if (!disposed) {
      this.error.value = error;
    }
  }
}
