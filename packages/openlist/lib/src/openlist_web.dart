import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'openlist_platform_interface.dart';

class OpenlistWeb extends OpenlistPlatform {
  OpenlistWeb();

  static void registerWith(Registrar registrar) {
    OpenlistPlatform.instance = OpenlistWeb();
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }
}
