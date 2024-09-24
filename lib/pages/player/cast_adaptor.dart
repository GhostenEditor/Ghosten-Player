import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:player_view/player.dart';
import 'package:rxdart/rxdart.dart';

import '../../components/error_message.dart';
import '../../platform_api.dart';

class CastAdaptor extends Cast {
  const CastAdaptor();

  @override
  Stream<List<CastDeviceAdaptor>> discover() {
    return Api.dlnaDiscover().map(CastDeviceAdaptor.fromJson).scan((acc, curr, i) => acc..add(curr), []);
  }
}

class CastDeviceAdaptor extends CastDevice {
  const CastDeviceAdaptor({
    required super.id,
    required super.friendlyName,
  });

  factory CastDeviceAdaptor.fromJson(dynamic data) {
    return CastDeviceAdaptor(id: data['id'], friendlyName: data['friendlyName']);
  }

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
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
        backgroundColor: Colors.black87,
        content: ErrorMessage(
          snapshot: AsyncSnapshot.withError(ConnectionState.done, error),
          safeArea: false,
        ),
        behavior: SnackBarBehavior.floating,
      ));
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
  Stream<PositionInfo> position() {
    return PlatformApi.screenEvent
        .switchMap((value) => switch (value) {
              ScreenState.on || ScreenState.off => Stream.periodic(const Duration(seconds: 1)),
              ScreenState.present => Stream.periodic(const Duration(seconds: 1)).switchMap((_) => Stream.fromFuture(Future.microtask(() async {
                    try {
                      final data = await Api.dlnaGetPositionInfo(id);
                      final duration = data['duration'];
                      final position = data['position'];
                      if (duration is int && position is int) {
                        return PositionInfo(
                          duration: Duration(seconds: duration),
                          position: Duration(seconds: position),
                        );
                      } else {
                        return null;
                      }
                    } catch (e) {
                      return null;
                    }
                  })))
            })
        .mapNotNull((e) => e);
  }

  @override
  Future<void> seek(Duration seek) {
    return Api.dlnaSeek(id, seek);
  }

  @override
  Future<void> stop() {
    return Api.dlnaStop(id);
  }

  @override
  Future<void> setVolume(double volume) {
    return Api.dlnaSetVolume(id, volume);
  }
}
