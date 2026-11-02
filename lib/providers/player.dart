import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/player.dart';

import 'user_config.dart';

class PlayerConfig extends ChangeNotifier {
  PlayerConfig(this.prefs)
    : autoPip = prefs.getBool('playerConfig.autoPip') ?? false,
      playerType = PlayerType.fromString(prefs.getString('playerConfig.playerType')),
      themeMode = FromString.fromString(prefs.getString('playerConfig.themeMode')),
      mpvVersion = prefs.getString('playerConfig.mpvVersion'),
      autoForceLandscape = prefs.getBool('playerConfig.autoForceLandscape') ?? false,
      extensionRendererMode = prefs.getInt('playerConfig.extensionRendererMode') ?? 1,
      fastForwardSpeed = prefs.getInt('playerConfig.fastForwardSpeed') ?? 30,
      enableDecoderFallback = prefs.getBool('playerConfig.enableDecoderFallback') ?? false,
      showThumbnails = prefs.getBool('playerConfig.showThumbnails') ?? false,
      subtitleSettings =
          prefs.getString('playerConfig.subtitleSettings')?.split(',').map(int.parse).toList() ??
          [0xFFFFFFFF, 0xFF000000, 0, 0, 0xFFFFFFFF],
      showLiteProgressbar = prefs.getBool('playerConfig.showLiteProgressbar') ?? false,
      preferredSubtitleLanguage = prefs.getString('playerConfig.preferredSubtitleLanguage'),
      preferredAudioLanguage = prefs.getString('playerConfig.preferredAudioLanguage');
  final SharedPreferences prefs;
  int extensionRendererMode;
  int fastForwardSpeed;
  bool enableDecoderFallback;
  bool showThumbnails;
  List<int> subtitleSettings;
  bool showLiteProgressbar;
  bool autoForceLandscape;
  bool autoPip;
  PlayerType playerType;
  String? mpvVersion;
  ThemeMode themeMode;
  String? preferredSubtitleLanguage;
  String? preferredAudioLanguage;

  void setExtensionRendererMode(int mode) {
    extensionRendererMode = mode;
    notifyListeners();
    prefs.setInt('playerConfig.extensionRendererMode', mode);
  }

  void setFastForwardSpeed(int speed) {
    fastForwardSpeed = speed;
    notifyListeners();
    prefs.setInt('playerConfig.fastForwardSpeed', speed);
  }

  void setEnableDecoderFallback(bool enabled) {
    enableDecoderFallback = enabled;
    notifyListeners();
    prefs.setBool('playerConfig.enableDecoderFallback', enabled);
  }

  void setShowThumbnails(bool show) {
    showThumbnails = show;
    notifyListeners();
    prefs.setBool('playerConfig.showThumbnails', show);
  }

  void setSubtitleSettings(List<int> settings) {
    subtitleSettings = settings;
    notifyListeners();
    prefs.setString('playerConfig.subtitleSettings', settings.join(','));
  }

  void setShowLiteProgressbar(bool show) {
    showLiteProgressbar = show;
    notifyListeners();
    prefs.setBool('playerConfig.show', show);
  }

  void setPlayerType(PlayerType playerType) {
    this.playerType = playerType;
    notifyListeners();
    prefs.setString('playerConfig.playerType', playerType.name);
  }

  void setMpvVersion(String? mpvVersion) {
    this.mpvVersion = mpvVersion;
    notifyListeners();
    if (mpvVersion != null) {
      prefs.setString('playerConfig.mpvVersion', mpvVersion);
    } else {
      prefs.remove('playerConfig.mpvVersion');
    }
  }

  void setAutoForceLandscape(bool a) {
    autoForceLandscape = a;
    notifyListeners();
    prefs.setBool('playerConfig.autoForceLandscape', autoForceLandscape);
  }

  void setAutoPip(bool a) {
    autoPip = a;
    notifyListeners();
    prefs.setBool('playerConfig.autoPip', autoPip);
  }

  void setTheme(ThemeMode themeMode) {
    this.themeMode = themeMode;
    notifyListeners();
    prefs.setString('playerConfig.themeMode', themeMode.name);
  }

  void setPreferredSubtitleLanguage(String? language) {
    preferredSubtitleLanguage = language;
    notifyListeners();
    if (language != null) {
      prefs.setString('playerConfig.preferredSubtitleLanguage', language);
    } else {
      prefs.remove('playerConfig.preferredSubtitleLanguage');
    }
  }

  void setPreferredAudioLanguage(String? language) {
    preferredAudioLanguage = language;
    notifyListeners();
    if (language != null) {
      prefs.setString('playerConfig.preferredAudioLanguage', language);
    } else {
      prefs.remove('playerConfig.preferredAudioLanguage');
    }
  }
}
