import 'dart:js';
import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'player_platform_interface.dart';

class PlayerWeb extends PlayerPlatform {
  static Function(MethodCall call)? handler;

  PlayerWeb() {
    bool coreIdle = false;
    bool pause = false;
    bool pausedForCache = false;
    bool seeking = false;
    listen('isInitialized', (data) {
      handler?.call(const MethodCall('isInitialized'));
    });
    listen('position', (data) {
      handler?.call(MethodCall('position', data * 1000));
    });
    listen('duration', (data) {
      handler?.call(MethodCall('duration', data * 1000));
    });
    listen('buffer', (data) {
      handler?.call(MethodCall('bufferingUpdate', data * 1000));
    });
    listen('tracksChanged', (data) {
      dynamic mediaInfo = {};
      for (final track in data) {
        if (track['selected']) {
          switch (track['type']) {
            case 'video':
              mediaInfo['videoSize'] = '${track['width']} x ${track['height']}';
              mediaInfo['videoCodecs'] = track['codec'];
              mediaInfo['videoFPS'] = track['fps'];
              mediaInfo['videoMime'] = track['decoder_desc'];
            case 'audio':
              mediaInfo['audioCodecs'] = track['codec'];
              mediaInfo['audioBitrate'] = track['bitrate'];
              mediaInfo['audioMime'] = track['decoder_desc'];
          }
        }
      }
      handler?.call(MethodCall('mediaInfo', mediaInfo));
      handler?.call(MethodCall('tracksChanged', data));
    });
    listen('error', (data) {
      handler?.call(MethodCall('error', data));
    });
    listen('fatalError', (data) {
      handler?.call(MethodCall('fatalError', data));
    });
    listen('mediaChanged', (data) {
      handler?.call(MethodCall('mediaChanged', data));
    });
    listen('volume', (data) {
      handler?.call(MethodCall('volumeChanged', data));
    });
    listen('mediaInfo', (data) {
      handler?.call(MethodCall('mediaInfo', data));
    });
    listen('pause', (data) {
      pause = data;
      updateStatus(coreIdle, pause, seeking, pausedForCache);
    });
    listen('pausedForCache', (data) {
      pausedForCache = data;
      updateStatus(coreIdle, pause, seeking, pausedForCache);
    });

    listen('coreIdle', (data) {
      coreIdle = data;
      updateStatus(coreIdle, pause, seeking, pausedForCache);
    });

    listen('seeking', (data) {
      seeking = data;
      updateStatus(coreIdle, pause, seeking, pausedForCache);
    });
  }

  static void registerWith(Registrar registrar) {
    PlayerPlatform.instance = PlayerWeb();
  }

  Future<T>? invoke<T>(String method, [dynamic arg]) {
    final ar = arg is Map ? JsObject.jsify(arg) : arg;
    return context['__TAURI__']?.callMethod('invoke', [method, ar].nonNulls.toList()) as Future<T>?;
  }

  listen(String event, void Function(dynamic data) callback) {
    context['__TAURI__']?['event']?.callMethod('listen', [
      event,
      (JsObject data) {
        final payload = data['payload'];
        if (payload is JsObject) {
          callback(payload.toJSBox.toDart);
        } else {
          callback(payload);
        }
      }
    ]);
  }

  updateStatus(bool coreIdle, bool pause, bool seeking, bool pausedForCache) {
    handler?.call(MethodCall(
        'updateStatus',
        switch ((coreIdle, pause, seeking, pausedForCache)) {
          (false, _, _, _) => 'playing',
          (true, true, _, _) => 'paused',
          (true, false, true, _) => 'buffering',
          (_, _, _, _) => 'idle'
        }));
  }

  @override
  Future<void> play() async {
    invoke('play');
  }

  @override
  Future<void> pause() async {
    invoke('pause');
  }

  @override
  Future<void> next(int index) async {
    invoke('next', {'index': index});
  }

  @override
  Future<void> seekTo(Duration position) async {
    invoke('seek_to', {'position': position.inSeconds});
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    invoke('speed', {'speed': speed});
  }

  @override
  Future<void> setTrack(String type, String? id) async {
    invoke('track', {'id': id, 'type': type});
  }

  @override
  Future<bool?> requestPip() async {
    return false;
  }

  @override
  Future<String?> getVideoThumbnail(int position) async {
    return null;
  }

  @override
  Future<bool?> canPip() async {
    return false;
  }

  @override
  Future<void> enterFullscreen() async {}

  @override
  Future<void> exitFullscreen() async {}

  @override
  void setMethodCallHandler(Future<dynamic> Function(MethodCall call)? handler) {
    PlayerWeb.handler = handler;
  }

  @override
  Future<void> init(Map<String, dynamic> args) async {
    invoke('init', args);
  }

  @override
  Future<void> dispose() async {
    invoke('dispose');
  }
}
