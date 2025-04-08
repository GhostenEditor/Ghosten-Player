import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'player_platform_interface.dart';

abstract class PlayerBaseController {
  abstract final ValueNotifier<Duration> position;
  abstract final ValueNotifier<Duration> bufferedPosition;
  abstract final ValueNotifier<Duration> duration;
  abstract final ValueNotifier<PlayerStatus> status;

  Future<String?> getVideoThumbnail(int position);
}

class PlayerController<T> implements PlayerBaseController {
  final ValueNotifier<List<PlaylistItem<T>>> playlist = ValueNotifier([]);
  final ValueNotifier<int?> index = ValueNotifier(null);
  final ValueNotifier<bool> isFirst = ValueNotifier(true);
  final ValueNotifier<bool> isLast = ValueNotifier(true);
  final ValueNotifier<String?> title = ValueNotifier(null);
  final ValueNotifier<String> subTitle = ValueNotifier('');
  final ValueNotifier<String?> error = ValueNotifier(null);
  final ValueNotifier<String?> fatalError = ValueNotifier(null);
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
  final ValueNotifier<(MediaChange, Duration)?> mediaChange = ValueNotifier(null);

  PlaylistItem<T>? get currentItem => index.value == null ? null : playlist.value.elementAtOrNull(index.value!);

  PlayerController([Function(int, String)? onLog]) {
    this.index.addListener(() {
      title.value = currentItem?.title;
      subTitle.value = currentItem?.description ?? '';
      isFirst.value = this.index.value == 0;
      isLast.value = this.index.value == playlist.value.length - 1;
    });
    PlayerPlatform.instance.canPip().then((value) => canPip.value = value ?? false);
    PlayerPlatform.instance.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'position':
          position.value = Duration(milliseconds: call.arguments);
        case 'duration':
          duration.value = Duration(milliseconds: call.arguments);
        case 'networkSpeed':
          networkSpeed.value = call.arguments;
        case 'updateStatus':
          status.value = PlayerStatus.fromString(call.arguments);
          if (status.value != PlayerStatus.error && status.value != PlayerStatus.idle) {
            fatalError.value = null;
            error.value = null;
          }
        case 'bufferingUpdate':
          bufferedPosition.value = Duration(milliseconds: call.arguments);
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
            mediaChange.value = (data, duration.value);
          }
        case 'mediaChanged':
          final mediaChange = MediaChange.fromJson(call.arguments);
          this.index.value = mediaChange.index;
          position.value = mediaChange.position;
          error.value = null;
        case 'volumeChanged':
          volume.value = call.arguments;
        case 'mediaInfo':
          mediaInfo.value = MediaInfo.fromJson(call.arguments);
        case 'willSkip':
          willSkip.value = UniqueKey();
        case 'log':
          if (onLog != null) {
            onLog(call.arguments['level'], call.arguments['message']);
          }
      }
    });
  }

  void dispose() async {
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
    mediaChange.dispose();
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
      PlayerPlatform.instance.next(index);
    }
    if (status.value == PlayerStatus.paused || status.value == PlayerStatus.idle) {
      play();
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

  Future<void> setSkipPosition(String type, List<int> list) {
    return PlayerPlatform.instance.setSkipPosition(type, list);
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

  Future<void> updateSource(PlaylistItem<T> source, int index) {
    return PlayerPlatform.instance.updateSource(source.toSource(), index);
  }

  Future<void> setSources(List<PlaylistItem<T>> playlist, int index) async {
    if (playlist.length == this.playlist.value.length &&
        List.generate(playlist.length, (i) => i).every((index) => playlist[index] == this.playlist.value[index])) {
      return;
    }
    this.playlist.value = playlist;
    return PlayerPlatform.instance.setSources(playlist.map((item) => item.toSource()).toList(), index);
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
