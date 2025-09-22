import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/player.dart';

import '../../components/error_message.dart';
import '../../platform_api.dart';

class CastAdaptor extends Cast {
  const CastAdaptor();

  @override
  Stream<List<CastDeviceAdaptor>> discover() {
    return Api.dlnaDiscover().map((data) => data.map(CastDeviceAdaptor.fromJson).toList());
  }
}

class CastDeviceAdaptor extends CastDevice {
  CastDeviceAdaptor({required super.id, required super.friendlyName});

  factory CastDeviceAdaptor.fromJson(dynamic data) {
    // ignore: avoid_dynamic_calls
    return CastDeviceAdaptor(id: data['id'], friendlyName: data['friendlyName']);
  }

  late final Stream<(int, int)> _stream = PlatformApi.screenEvent
      .switchMap(
        (value) => switch (value) {
          ScreenState.on || ScreenState.off => Stream.periodic(const Duration(seconds: 1)),
          ScreenState.present => Stream.periodic(const Duration(seconds: 1)).switchMap(
            (_) => Stream.fromFuture(
              Future.microtask(() async {
                try {
                  final data = await Api.dlnaGetPositionInfo(id) as Json;
                  final duration = data['duration'];
                  final position = data['position'];
                  if (duration is int && position is int) {
                    return (position, duration);
                  } else {
                    return null;
                  }
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
  final ValueNotifier<PlayerStatus> status = ValueNotifier(PlayerStatus.idle);

  StreamSubscription<dynamic>? _subscription;

  @override
  Future<dynamic> getMediaInfo() {
    return Api.dlnaGetMediaInfo(id);
  }

  @override
  Future<dynamic> getTransportInfo() {
    return Api.dlnaGetTransportInfo(id);
  }

  @override
  Future<double> getVolume() {
    return Api.dlnaGetVolume(id);
  }

  @override
  Future<void> setUrl(Uri uri, {String? title, String playType = 'video'}) async {
    try {
      await Api.dlnaSetUri(id, uri, title: title, playType: playType);
    } catch (error) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black87,
          content: ErrorMessage(error: error, safeArea: false, minHeight: 0),
          behavior: SnackBarBehavior.floating,
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> pause() {
    return Api.dlnaPause(id);
  }

  @override
  Future<void> play() {
    return Api.dlnaPlay(id);
  }

  @override
  Future<void> seek(Duration seek) {
    return Api.dlnaSeek(id, seek);
  }

  @override
  Future<void> start() async {
    _subscription = _stream.listen((data) {
      position.value = Duration(seconds: data.$1);
      duration.value = Duration(seconds: data.$2);
    });
  }

  @override
  Future<void> stop() {
    _subscription?.cancel();
    return Api.dlnaStop(id);
  }

  @override
  Future<void> setVolume(double volume) {
    return Api.dlnaSetVolume(id, volume);
  }

  @override
  Future<String?> getVideoThumbnail(int position) {
    throw UnimplementedError();
  }
}
