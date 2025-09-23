import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'openlist_platform_interface.dart';

class MethodChannelOpenlist extends OpenlistPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('com.ghosten.player/openlist');

  @override
  Future<void> init() {
    return methodChannel.invokeMethod('init');
  }

  @override
  Future<void> shutdown() {
    return methodChannel.invokeMethod('shutdown');
  }

  @override
  Future<bool> isRunning() {
    return methodChannel.invokeMethod<bool>('isRunning').then((f) => f ?? false);
  }

  @override
  Future<void> setAdminPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('openlist.adminPassword', password);
    return methodChannel.invokeMethod('setAdminPassword', password);
  }

  @override
  Future<String> getAdminPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('openlist.adminPassword') ?? '';
  }
}
