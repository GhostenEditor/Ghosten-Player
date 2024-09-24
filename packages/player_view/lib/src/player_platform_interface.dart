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

  Future<void> setTrack(String type, dynamic id) {
    throw UnimplementedError('setTrack() has not been implemented.');
  }

  Future<void> setVolume(double volume) {
    throw UnimplementedError('setVolume() has not been implemented.');
  }

  Future<bool?> requestPip() {
    throw UnimplementedError('requestPip() has not been implemented.');
  }

  Future<void> requestFullscreen() {
    throw UnimplementedError('requestFullscreen() has not been implemented.');
  }

  Future<void> setSkipPosition(String type, List<int> list) {
    throw UnimplementedError('setSkipPosition() has not been implemented.');
  }

  Future<void> setSources(List<Map<String, dynamic>> playlist, int index) {
    throw UnimplementedError('setSources() has not been implemented.');
  }

  Future<void> updateSource(Map<String, dynamic> source, int index) {
    throw UnimplementedError('updateSource() has not been implemented.');
  }

  Future<void> hide() {
    throw UnimplementedError('hide() has not been implemented.');
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

  void setMethodCallHandler(Future<dynamic> Function(MethodCall call)? handler) {
    throw UnimplementedError('setMethodCallHandler() has not been implemented.');
  }

  void initWeb() {
    throw UnimplementedError('setMethodCallHandler() has not been implemented.');
  }

  void destroyWeb() {
    throw UnimplementedError('setMethodCallHandler() has not been implemented.');
  }
}
