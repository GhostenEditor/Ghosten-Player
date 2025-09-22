import 'package:shared_preferences/shared_preferences.dart';

class PlayerConfig {
  static int getExtensionRendererMode(SharedPreferences prefs) {
    return prefs.getInt('playerConfig.extensionRendererMode') ?? 1;
  }

  static void setExtensionRendererMode(SharedPreferences prefs, int mode) {
    prefs.setInt('playerConfig.extensionRendererMode', mode);
  }

  static int getFastForwardSpeed(SharedPreferences prefs) {
    return prefs.getInt('playerConfig.fastForwardSpeed') ?? 30;
  }

  static void setFastForwardSpeed(SharedPreferences prefs, int speed) {
    prefs.setInt('playerConfig.fastForwardSpeed', speed);
  }

  static bool getEnableDecoderFallback(SharedPreferences prefs) {
    return prefs.getBool('playerConfig.enableDecoderFallback') ?? false;
  }

  static void setEnableDecoderFallback(SharedPreferences prefs, bool enableDecoderFallback) {
    prefs.setBool('playerConfig.enableDecoderFallback', enableDecoderFallback);
  }

  static bool getShowThumbnails(SharedPreferences prefs) {
    return prefs.getBool('playerConfig.showThumbnails') ?? false;
  }

  static void setShowThumbnails(SharedPreferences prefs, bool showThumbnails) {
    prefs.setBool('playerConfig.showThumbnails', showThumbnails);
  }

  static List<int> getSubtitleSettings(SharedPreferences prefs) {
    return prefs.getString('playerConfig.subtitleSettings')?.split(',').map(int.parse).toList() ?? [0xFFFFFFFF, 0xFF000000, 0, 0, 0xFFFFFFFF];
  }

  static void setSubtitleSettings(SharedPreferences prefs, List<int> settings) {
    prefs.setString('playerConfig.subtitleSettings', settings.join(','));
  }
}
