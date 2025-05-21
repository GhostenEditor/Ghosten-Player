import 'package:flutter/services.dart';

import 'player_platform_interface.dart';

class MethodChannelPlayer extends PlayerPlatform {
  final MethodChannel _channel = const MethodChannel('com.ghosten.player/player');

  MethodChannelPlayer();

  @override
  play() {
    return _channel.invokeMethod('play');
  }

  @override
  pause() {
    return _channel.invokeMethod('pause');
  }

  @override
  next(int index) {
    return _channel.invokeMethod('next', index);
  }

  @override
  seekTo(Duration position) {
    return _channel.invokeMethod('seekTo', position.inMilliseconds);
  }

  @override
  setPlaybackSpeed(double speed) {
    return _channel.invokeMethod('setPlaybackSpeed', speed);
  }

  @override
  setTrack(String type, String? id) {
    return _channel.invokeMethod('setTrack', {'type': type, 'id': id});
  }

  @override
  Future<bool?> requestPip() {
    return _channel.invokeMethod<bool>('requestPip', {});
  }

  @override
  Future<void> setTransform(List<double> matrix) {
    return _channel.invokeMethod('setTransform', {'matrix': matrix});
  }

  @override
  Future<void> setAspectRatio(double? aspectRatio) {
    return _channel.invokeMethod('setAspectRatio', aspectRatio);
  }

  @override
  Future<void> setSource(Map<String, dynamic>? item) {
    return _channel.invokeMethod('setSource', item);
  }

  @override
  Future<void> updateSource(Map<String, dynamic> source, int index) {
    return _channel.invokeMethod('updateSource', {'source': source, 'index': index});
  }

  @override
  Future<String?> getVideoThumbnail(int position) {
    return _channel.invokeMethod('getVideoThumbnail', {'position': position});
  }

  @override
  Future<String?> getLocalIpAddress() {
    return _channel.invokeMethod('getLocalIpAddress');
  }

  @override
  Future<bool?> canPip() {
    return _channel.invokeMethod('canPip');
  }

  @override
  Future<void> enterFullscreen() {
    return _channel.invokeMethod('fullscreen', true);
  }

  @override
  Future<void> exitFullscreen() {
    return _channel.invokeMethod('fullscreen', false);
  }

  @override
  Future<void> setPlayerOption(String optionName, dynamic optionValue) {
    return _channel.invokeMethod('setPlayerOption', {'name': optionName, 'value': optionValue});
  }

  @override
  Future<void> setSubtitleStyle(List<int> style) {
    return _channel.invokeMethod('setSubtitleStyle', {'style': style});
  }

  @override
  void setMethodCallHandler(Future<dynamic> Function(MethodCall call)? handler) {
    _channel.setMethodCallHandler(handler);
  }

  @override
  Future<void> init(Map<String, dynamic> args) {
    return _channel.invokeMethod('init', args);
  }

  @override
  Future<void> dispose() {
    return _channel.invokeMethod('dispose');
  }
}
