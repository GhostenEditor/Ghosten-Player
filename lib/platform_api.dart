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

enum DeviceType {
  androidPad,
  androidPhone,
  web;

  static DeviceType fromString(String? s) {
    return switch (s) {
      '1' => DeviceType.androidPad,
      '2' => DeviceType.androidPhone,
      _ => DeviceType.androidPhone,
    };
  }
}

class PlatformApi {
  static const _channelNamespace = 'com.ghosten.player';
  static Stream<bool> pipEvent =
      kIsWeb
          ? const Stream.empty()
          : const EventChannel('$_channelNamespace/pip').receiveBroadcastStream().asBroadcastStream().cast();
  static Stream<String> deeplinkEvent =
      kIsWeb
          ? const Stream.empty()
          : const EventChannel(
            '$_channelNamespace/deeplink',
          ).receiveBroadcastStream().asBroadcastStream().cast<String?>().mapNotNull((l) => l).distinct();
  static Stream<ScreenState> screenEvent =
      (ReplaySubject<ScreenState>(maxSize: 1)..addStream(
        kIsWeb
            ? Stream.value(ScreenState.on)
            : const EventChannel(
              '$_channelNamespace/screen',
            ).receiveBroadcastStream().cast<String>().map((event) => ScreenState.fromString(event)),
      )).stream;
  static late DeviceType deviceType;

  static bool isAndroidPhone() {
    return deviceType == DeviceType.androidPhone;
  }
}
