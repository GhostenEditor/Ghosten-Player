import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'openlist_method_channel.dart';

abstract class OpenlistPlatform extends PlatformInterface {
  OpenlistPlatform() : super(token: _token);

  static final Object _token = Object();

  static OpenlistPlatform _instance = MethodChannelOpenlist();

  static OpenlistPlatform get instance => _instance;

  static set instance(OpenlistPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> init() {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> shutdown() {
    throw UnimplementedError('shutdown() has not been implemented.');
  }

  Future<void> setAdminPassword(String password) {
    throw UnimplementedError('setAdminPassword() has not been implemented.');
  }

  Future<String> getAdminPassword() {
    throw UnimplementedError('getAdminPassword() has not been implemented.');
  }

  Future<bool> isRunning() {
    throw UnimplementedError('isRunning() has not been implemented.');
  }
}
