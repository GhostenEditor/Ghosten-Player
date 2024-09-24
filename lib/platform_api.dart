import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

enum ScreenState {
  on,
  off,
  present;

  static ScreenState fromString(String? str) {
    return ScreenState.values.firstWhere((element) => element.name == str);
  }
}

enum AndroidDeviceType {
  tv,
  pad,
  phone;

  static AndroidDeviceType fromInt(int? i) {
    return switch (i) {
      0 => AndroidDeviceType.tv,
      1 => AndroidDeviceType.pad,
      2 => AndroidDeviceType.phone,
      _ => AndroidDeviceType.phone,
    };
  }
}

AndroidDeviceType androidDeviceType = AndroidDeviceType.phone;

class PlatformApi {
  static const _channelNamespace = 'com.ghosten.player';
  static const _platform = MethodChannel(_channelNamespace);
  static Stream<bool> pipEvent =
      kIsWeb ? const Stream.empty() : const EventChannel('$_channelNamespace/pip').receiveBroadcastStream().asBroadcastStream().cast();
  static Stream<String> deeplinkEvent = kIsWeb
      ? const Stream.empty()
      : const EventChannel('$_channelNamespace/deeplink').receiveBroadcastStream().asBroadcastStream().cast<String?>().mapNotNull((l) => l).distinct();
  static Stream<ScreenState> screenEvent = (ReplaySubject<ScreenState>(maxSize: 1)
        ..addStream(kIsWeb
            ? Stream.value(ScreenState.on)
            : const EventChannel('$_channelNamespace/screen').receiveBroadcastStream().cast<String>().map((event) => ScreenState.fromString(event))))
      .stream;

  static Future<AndroidDeviceType> getAndroidDeviceType() async {
    final data = await _platform.invokeMethod<int>('androidDeviceType');
    androidDeviceType = AndroidDeviceType.fromInt(data);
    return androidDeviceType;
  }

  static Future<String?> get externalUrl => _platform.invokeMethod<String>('externalUrl');
}
