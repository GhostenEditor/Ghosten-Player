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
  androidPhone,
  androidPad,
  other;

  static DeviceType fromString(String? s) {
    return switch (s) {
      '0' => DeviceType.androidPhone,
      '1' => DeviceType.androidPad,
      _ => DeviceType.other,
    };
  }
}

class PlatformApi {
  static const _channelNamespace = 'com.ghosten.player';
  static const _methodChannel = MethodChannel(_channelNamespace);
  static const _notificationMethodChannel = MethodChannel('com.ghosten.player/notification');

  static Stream<bool> pipEvent = kIsWeb
      ? const Stream.empty()
      : const EventChannel('$_channelNamespace/pip').receiveBroadcastStream().asBroadcastStream().cast();
  static Stream<String> deeplinkEvent = kIsWeb
      ? const Stream.empty()
      : const EventChannel('$_channelNamespace/deeplink')
            .receiveBroadcastStream()
            .asBroadcastStream()
            .cast<String?>()
            .mapNotNull((l) => l)
            .distinct();
  static Stream<ScreenState> screenEvent =
      (ReplaySubject<ScreenState>(maxSize: 1)..addStream(
            kIsWeb
                ? Stream.value(ScreenState.on)
                : const EventChannel('$_channelNamespace/screen')
                      .receiveBroadcastStream()
                      .cast<String>()
                      .map((event) => ScreenState.fromString(event)),
          ))
          .stream;
  static DeviceType deviceType = .other;

  static bool isAndroidPhone() {
    return deviceType == DeviceType.androidPhone;
  }

  static Future<String?> arch() {
    return _methodChannel.invokeMethod('arch');
  }

  static Future<bool?> canPip() {
    return _methodChannel.invokeMethod('canPip');
  }

  static Future<bool?> requestPip() {
    return _methodChannel.invokeMethod('requestPip');
  }

  static Future<List<dynamic>?> initialized() {
    return _methodChannel.invokeMethod('initialized');
  }

  static void progressNotification(String method, {required int id, String? title, String? content, double? progress}) {
    final Future<dynamic> _ = _notificationMethodChannel.invokeMethod(method, {
      'id': id,
      'title': title,
      'content': content,
      'progress': progress,
    });
  }
}
