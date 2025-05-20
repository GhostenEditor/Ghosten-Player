import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'player_method_channel.dart';

abstract class PlayerPlatform extends PlatformInterface {
  PlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static PlayerPlatform _instance = MethodChannelPlayer();

  static PlayerPlatform get instance => _instance;

  static set instance(PlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> play() {
    throw UnimplementedError('play() has not been implemented.');
  }

  Future<void> pause() {
    throw UnimplementedError('pause() has not been implemented.');
  }

  Future<void> next(int index) {
    throw UnimplementedError('next() has not been implemented.');
  }

  Future<void> seekTo(Duration position) {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  Future<void> setPlaybackSpeed(double speed) {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  Future<void> setTrack(String type, String? id) {
    throw UnimplementedError('setTrack() has not been implemented.');
  }

  Future<bool?> requestPip() {
    throw UnimplementedError('requestPip() has not been implemented.');
  }

  Future<void> setTransform(List<double> matrix) {
    throw UnimplementedError('setTransform() has not been implemented.');
  }

  Future<void> setAspectRatio(double? aspectRatio) {
    throw UnimplementedError('setAspectRatio() has not been implemented.');
  }

  Future<void> setSource(Map<String, dynamic>? item) {
    throw UnimplementedError('setSource() has not been implemented.');
  }

  Future<void> updateSource(Map<String, dynamic> source, int index) {
    throw UnimplementedError('updateSource() has not been implemented.');
  }

  Future<String?> getVideoThumbnail(int position) {
    throw UnimplementedError('getVideoThumbnail() has not been implemented.');
  }

  Future<String?> getLocalIpAddress() {
    throw UnimplementedError('getLocalIpAddress() has not been implemented.');
  }

  Future<bool?> canPip() {
    throw UnimplementedError('canPip() has not been implemented.');
  }

  Future<void> enterFullscreen() {
    throw UnimplementedError('enterFullscreen() has not been implemented.');
  }

  Future<void> exitFullscreen() {
    throw UnimplementedError('enterFullscreen() has not been implemented.');
  }

  Future<void> setPlayerOption(String optionName, dynamic optionValue) {
    throw UnimplementedError('setPlayerOption() has not been implemented.');
  }

  Future<void> setSubtitleStyle(List<int> style) {
    throw UnimplementedError('setSubtitleStyle() has not been implemented.');
  }

  void setMethodCallHandler(Future<dynamic> Function(MethodCall call)? handler) {
    throw UnimplementedError('setMethodCallHandler() has not been implemented.');
  }

  Future<void> init(Map<String, dynamic> args) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}
