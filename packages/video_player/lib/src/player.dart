import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'player_platform_interface.dart';

abstract class PlayerBaseController {
  abstract final ValueNotifier<Duration> position;
  abstract final ValueNotifier<Duration> bufferedPosition;
  abstract final ValueNotifier<Duration> duration;
  abstract final ValueNotifier<PlayerStatus> status;

  Future<String?> getVideoThumbnail(int position);
}

enum PlaybackStatusEvent { start, progress, stop }

class PlayerController<T> implements PlayerBaseController {
  PlayerController(Function(int, String)? onLog, {this.onGetPlayBackInfo, this.onPlaybackStatusUpdate}) {
    index.addListener(() {
      title.value = currentItem?.title;
      subTitle.value = currentItem?.description ?? '';
      isFirst.value = index.value == 0;
      isLast.value = index.value == playlist.value.length - 1;
    });
    PlayerPlatform.instance.canPip().then((value) => canPip.value = value ?? false);
    PlayerPlatform.instance.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'position':
          position.value = Duration(milliseconds: (call.arguments as num).toInt());
        case 'duration':
          duration.value = Duration(milliseconds: (call.arguments as num).toInt());
        case 'networkSpeed':
          networkSpeed.value = call.arguments;
        case 'updateStatus':
          status.value = PlayerStatus.fromString(call.arguments);
          if (status.value != PlayerStatus.error && status.value != PlayerStatus.idle) {
            fatalError.value = null;
            error.value = null;
          }
          if (status.value == PlayerStatus.ended && index.value != null) {
            next(index.value! + 1);
          }
          if (status.value == PlayerStatus.playing) {
            _subscription?.resume();
          } else {
            _subscription?.pause();
          }
        case 'bufferingUpdate':
          bufferedPosition.value = Duration(milliseconds: (call.arguments as num).toInt());
        case 'tracksChanged':
          final tracks = (call.arguments as List<dynamic>).map(MediaTrack.fromJson).toList();
          trackGroup.value = MediaTrackGroup.fromTracks(tracks);
        case 'error':
          error.value = call.arguments;
        case 'fatalError':
          fatalError.value = call.arguments;
        case 'beforeMediaChange':
          if (duration.value > Duration.zero) {
            final data = MediaChange.fromJson(call.arguments);
            beforeMediaChanged.value = (data, duration.value);
          }
        case 'mediaChanged':
          final mediaChange = MediaChange.fromJson(call.arguments);
          position.value = mediaChange.position;
          error.value = null;
        case 'mediaIndexChanged':
          index.value = call.arguments;
        case 'volumeChanged':
          volume.value = call.arguments;
        case 'mediaInfo':
          mediaInfo.value = MediaInfo.fromJson(call.arguments);
        case 'willSkip':
          willSkip.value = UniqueKey();
        case 'log':
          if (onLog != null) {
            // ignore: avoid_dynamic_calls
            onLog(call.arguments['level'], call.arguments['message']);
          }
      }
    });

    if (onPlaybackStatusUpdate != null) {
      _subscription = _timer.listen((_) {
        if (status.value == PlayerStatus.playing) {
          onPlaybackStatusUpdate!(_playlistItem.value!, PlaybackStatusEvent.progress, position.value, duration.value);
        }
      });
    }
  }

  final ValueNotifier<List<PlaylistItemDisplay<T>>> playlist = ValueNotifier([]);
  final ValueNotifier<int?> index = ValueNotifier(null);
  final ValueNotifier<bool> isFirst = ValueNotifier(true);
  final ValueNotifier<bool> isLast = ValueNotifier(true);
  final ValueNotifier<String?> title = ValueNotifier(null);
  final ValueNotifier<String> subTitle = ValueNotifier('');
  final ValueNotifier<String?> error = ValueNotifier(null);
  final ValueNotifier<String?> fatalError = ValueNotifier(null);
  final ValueNotifier<Object?> playlistError = ValueNotifier(null);
  final ValueNotifier<double> playbackSpeed = ValueNotifier(1);
  final ValueNotifier<AspectRatioType> aspectRatio = ValueNotifier(AspectRatioType.auto);
  final ValueNotifier<double> volume = ValueNotifier(1);
  @override
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);
  @override
  final ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);
  final ValueNotifier<int> networkSpeed = ValueNotifier(0);
  @override
  final ValueNotifier<Duration> bufferedPosition = ValueNotifier(Duration.zero);
  @override
  final ValueNotifier<PlayerStatus> status = ValueNotifier(PlayerStatus.idle);
  final ValueNotifier<MediaTrackGroup> trackGroup = ValueNotifier(MediaTrackGroup.empty());
  final ValueNotifier<MediaInfo?> mediaInfo = ValueNotifier(null);
  final ValueNotifier<dynamic> willSkip = ValueNotifier(null);
  final ValueNotifier<bool> canPip = ValueNotifier(false);
  final ValueNotifier<bool> pipMode = ValueNotifier(false);
  final ValueNotifier<bool> isCasting = ValueNotifier(false);
  final ValueNotifier<int?> onMediaIndexChanged = ValueNotifier(null);
  final ValueNotifier<(MediaChange, Duration)?> beforeMediaChanged = ValueNotifier(null);
  final Future<PlaylistItem> Function(PlaylistItemDisplay<T>)? onGetPlayBackInfo;
  final Future<void> Function(PlaylistItem, PlaybackStatusEvent, Duration, Duration)? onPlaybackStatusUpdate;
  final ValueNotifier<PlaylistItem?> _playlistItem = ValueNotifier(null);
  final _timer = Stream.periodic(const Duration(seconds: 10));
  StreamSubscription<dynamic>? _subscription;

  PlaylistItemDisplay<T>? get currentItem => index.value == null ? null : playlist.value.elementAtOrNull(index.value!);

  Future<void> dispose() async {
    if (onPlaybackStatusUpdate != null && _playlistItem.value != null) {
      onPlaybackStatusUpdate!(_playlistItem.value!, PlaybackStatusEvent.stop, position.value, duration.value);
    }
    PlayerPlatform.instance.setMethodCallHandler(null);
    index.dispose();
    isFirst.dispose();
    isLast.dispose();
    title.dispose();
    subTitle.dispose();
    playbackSpeed.dispose();
    aspectRatio.dispose();
    position.dispose();
    duration.dispose();
    bufferedPosition.dispose();
    status.dispose();
    trackGroup.dispose();
    mediaInfo.dispose();
    _playlistItem.dispose();
    _subscription?.cancel();
    beforeMediaChanged.dispose();
    pipMode.dispose();
  }

  Future<void> play() {
    return PlayerPlatform.instance.play();
  }

  Future<void> pause() {
    return PlayerPlatform.instance.pause();
  }

  Future<void> next(int index) async {
    if (index < 0 || index >= playlist.value.length) return;
    if (index != this.index.value) {
      this.index.value = index;
      if (error.value != null) {
        error.value = null;
      }
      if (fatalError.value != null) {
        fatalError.value = null;
      }
      if (status.value == PlayerStatus.error) {
        status.value = PlayerStatus.idle;
      }
      await setSource(null);
      if (onPlaybackStatusUpdate != null && _playlistItem.value != null) {
        onPlaybackStatusUpdate!(_playlistItem.value!, PlaybackStatusEvent.stop, position.value, duration.value);
      }
      try {
        if (onGetPlayBackInfo == null) {
          _playlistItem.value = currentItem!.toItem();
          await setSource(_playlistItem.value);
        } else {
          _playlistItem.value = await onGetPlayBackInfo!(currentItem!);
          await setSource(_playlistItem.value);
        }
        if (onPlaybackStatusUpdate != null) {
          onPlaybackStatusUpdate!(
            _playlistItem.value!,
            PlaybackStatusEvent.start,
            _playlistItem.value!.start,
            duration.value,
          );
        }
      } on PlatformException catch (e) {
        status.value = PlayerStatus.error;
        fatalError.value = 'Code: ${e.code}, Message: ${e.message}';
      } catch (e) {
        status.value = PlayerStatus.error;
        fatalError.value = e.toString();
      }
    }
  }

  Future<void> seekTo(Duration position) async {
    if (position != this.position.value) {
      PlayerPlatform.instance.seekTo(position);
    }
  }

  Future<void> setPlaybackSpeed(double speed) {
    playbackSpeed.value = speed;
    return PlayerPlatform.instance.setPlaybackSpeed(speed);
  }

  Future<void> setTrack(String type, String? id) {
    if (id == 'null') id = null;
    return PlayerPlatform.instance.setTrack(type, id);
  }

  Future<bool?> requestPip() {
    return PlayerPlatform.instance.requestPip();
  }

  void setSkipPosition(String type, Duration duration) {
    switch (type) {
      case 'intro':
        playlist.value = playlist.value.map((item) => item.copyWith(start: duration)).toList();
      case 'ending':
        playlist.value = playlist.value.map((item) => item.copyWith(end: duration)).toList();
    }
  }

  @override
  Future<String?> getVideoThumbnail(int position) {
    return PlayerPlatform.instance.getVideoThumbnail(position);
  }

  Future<void> setTransform(List<double> matrix) {
    return PlayerPlatform.instance.setTransform(matrix);
  }

  Future<void> setAspectRatio(double? aspectRatio) {
    return PlayerPlatform.instance.setAspectRatio(aspectRatio);
  }

  Future<void> updateSource(PlaylistItemDisplay<T> source, int index) {
    playlist.value[index] = source;
    return PlayerPlatform.instance.updateSource(source.toItem().toSource(), index);
  }

  Future<void> setSource(PlaylistItem? playItem) async {
    return PlayerPlatform.instance.setSource(playItem?.toSource());
  }

  void setPlaylist(List<PlaylistItemDisplay<T>> playlist) {
    if (playlist.length == this.playlist.value.length &&
        List.generate(playlist.length, (i) => i).every((index) => playlist[index] == this.playlist.value[index])) {
      return;
    }
    index.value = null;
    this.playlist.value = playlist;
  }

  Future<void> enterFullscreen() {
    return PlayerPlatform.instance.enterFullscreen();
  }

  Future<void> exitFullscreen() {
    return PlayerPlatform.instance.exitFullscreen();
  }

  Future<void> setSubtitleStyle(List<int> style) {
    return PlayerPlatform.instance.setSubtitleStyle(style);
  }

  static Future<void> setPlayerOption(String optionName, dynamic optionValue) {
    return PlayerPlatform.instance.setPlayerOption(optionName, optionValue);
  }
}
