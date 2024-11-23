library player;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'player_platform_interface.dart';

class PlayerController<T extends PlaylistItem> {
  final List<T> playlist;
  late final ValueNotifier<int> index;
  late final ValueNotifier<bool> isFirst;
  late final ValueNotifier<bool> isLast;
  late final ValueNotifier<String?> title;
  late final ValueNotifier<String> subTitle;
  late final ValueNotifier<String?> error = ValueNotifier(null);
  late final ValueNotifier<String?> fatalError = ValueNotifier(null);
  final ValueNotifier<double> playbackSpeed = ValueNotifier(1);
  final ValueNotifier<double> volume = ValueNotifier(1);
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);
  final ValueNotifier<int> networkSpeed = ValueNotifier(0);
  final ValueNotifier<Duration> bufferedPosition = ValueNotifier(Duration.zero);
  final ValueNotifier<PlayerStatus> status = ValueNotifier(PlayerStatus.buffering);
  final ValueNotifier<MediaTrackGroup> trackGroup = ValueNotifier(MediaTrackGroup.empty());
  final ValueNotifier<MediaInfo?> mediaInfo = ValueNotifier(null);
  final ValueNotifier<dynamic> willSkip = ValueNotifier(null);
  final ValueNotifier<bool> canPip = ValueNotifier(false);
  final ValueNotifier<bool> pipMode = ValueNotifier(false);
  final ValueNotifier<bool> isCasting = ValueNotifier(false);
  final ValueNotifier<(MediaChange, Duration)?> mediaChange = ValueNotifier(null);
  bool isInitialized = false;

  T get currentItem => playlist[index.value];

  PlayerController([this.playlist = const [], index = 0, Function(int, String)? onlog]) {
    assert(playlist.isNotEmpty);
    this.index = ValueNotifier(index);
    isFirst = ValueNotifier(index == 0);
    isLast = ValueNotifier(index == playlist.length - 1);
    title = ValueNotifier(playlist[index].title);
    subTitle = ValueNotifier(playlist[index].description ?? '');
    this.index.addListener(() {
      title.value = currentItem.title;
      subTitle.value = currentItem.description ?? '';
      isFirst.value = this.index.value == 0;
      isLast.value = this.index.value == playlist.length - 1;
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
          if (onlog != null) {
            onlog(call.arguments['level'], call.arguments['message']);
          }
        case 'isInitialized':
          PlayerPlatform.instance.setSources(playlist.map((item) => item.toSource()).toList(), this.index.value);
          isInitialized = true;
      }
    });
  }

  void dispose() {
    PlayerPlatform.instance.setMethodCallHandler(null);
    index.dispose();
    isFirst.dispose();
    isLast.dispose();
    title.dispose();
    subTitle.dispose();
    playbackSpeed.dispose();
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
    if (index < 0 || index >= playlist.length) return;
    return PlayerPlatform.instance.next(index);
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

  Future<void> setTrack(String type, dynamic id) {
    return PlayerPlatform.instance.setTrack(type, id);
  }

  Future<void> setVolume(double volume) {
    return PlayerPlatform.instance.setVolume(volume);
  }

  Future<bool?> requestPip() {
    return PlayerPlatform.instance.requestPip();
  }

  Future<void> requestFullscreen() {
    return PlayerPlatform.instance.requestFullscreen();
  }

  Future<void> setSkipPosition(String type, List<int> list) {
    return PlayerPlatform.instance.setSkipPosition(type, list);
  }

  Future<String?> getVideoThumbnail(int position) {
    return PlayerPlatform.instance.getVideoThumbnail(position);
  }

  Future<void> updateSource(T source, int index) {
    return PlayerPlatform.instance.updateSource(source.toSource(), index);
  }

  Future<void> hide() {
    return PlayerPlatform.instance.hide();
  }
}
