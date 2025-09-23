import 'src/openlist_platform_interface.dart';
export 'src/client.dart';

class Openlist {
  static final init = OpenlistPlatform.instance.init;
  static final shutdown = OpenlistPlatform.instance.shutdown;
  static final setAdminPassword = OpenlistPlatform.instance.setAdminPassword;
  static final isRunning = OpenlistPlatform.instance.isRunning;
}
