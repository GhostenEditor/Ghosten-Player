import 'dart:convert';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SystemLanguage {
  zh,
  en,
  auto;

  static SystemLanguage fromString(String? str) {
    return SystemLanguage.values.firstWhere((element) => element.name == str, orElse: () => SystemLanguage.auto);
  }
}

extension FromString on ThemeMode {
  static ThemeMode fromString(String? str) {
    return ThemeMode.values.firstWhere((element) => element.name == str, orElse: () => ThemeMode.system);
  }
}

class PlayerConfig {
  int mode;
  int speed;
  bool? showThumbnails;
  bool enableDecoderFallback;

  PlayerConfig({
    required this.mode,
    required this.speed,
    required this.showThumbnails,
    required this.enableDecoderFallback,
  });

  PlayerConfig.fromJson(dynamic json)
      : mode = json?['mode'] ?? 1,
        speed = json?['speed'] ?? 30,
        enableDecoderFallback = json?['enableDecoderFallback'] ?? false,
        showThumbnails = json?['showThumbnails'] ?? false;

  Map<String, dynamic> toMap() => {
        'mode': mode,
        'speed': speed,
        'showThumbnails': showThumbnails,
        'enableDecoderFallback': enableDecoderFallback,
      };
}

class UserConfig extends ChangeNotifier {
  SystemLanguage language;
  ThemeMode themeMode;
  SortConfig tvList;
  SortConfig movieList;
  PlayerConfig playerConfig;
  bool autoUpdate;
  final SharedPreferences prefs;

  static Future<UserConfig> init() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('userConfig');
    final json = jsonDecode(data ?? '{}');
    return UserConfig._fromJson(json, prefs);
  }

  UserConfig._fromJson(dynamic json, this.prefs)
      : language = SystemLanguage.fromString(json['language']),
        themeMode = FromString.fromString(json['themeMode']),
        tvList = SortConfig.fromJson(json['tvList']),
        movieList = SortConfig.fromJson(json['movieList']),
        playerConfig = PlayerConfig.fromJson(json['playerConfig']),
        autoUpdate = json['autoUpdate'] ?? true;

  void setAutoUpdate(bool auto) {
    autoUpdate = auto;
    save();
  }

  void setMediaList(LibraryType type, SortConfig mediaList) {
    switch (type) {
      case LibraryType.tv:
        tvList = mediaList;
      case LibraryType.movie:
        movieList = mediaList;
    }
    save();
  }

  void setTheme(ThemeMode themeMode) {
    this.themeMode = themeMode;
    notifyListeners();
    save();
  }

  void setLanguage(SystemLanguage language) {
    this.language = language;
    notifyListeners();
    save();
  }

  void save() {
    prefs.setString('userConfig', toJson());
  }

  void setPlayerRendererMode(int mode) {
    playerConfig.mode = mode;
    save();
  }

  void setPlayerFastForwardSpeed(int speed) {
    playerConfig.speed = speed;
    save();
  }

  void setPlayerShowThumbnails(bool show) {
    playerConfig.showThumbnails = show;
    save();
  }

  void setPlayerEnableDecoderFallback(bool enableDecoderFallback) {
    playerConfig.enableDecoderFallback = enableDecoderFallback;
    save();
  }

  String toJson() => jsonEncode({
        'language': language.name,
        'themeMode': themeMode.name,
        'tvList': tvList.toMap(),
        'movieList': movieList.toMap(),
        'playerConfig': playerConfig.toMap(),
        'autoUpdate': autoUpdate,
      });

  Locale? get locale {
    return switch (language) {
      SystemLanguage.zh => const Locale('zh', 'CN'),
      SystemLanguage.en => const Locale('en', 'US'),
      SystemLanguage.auto => null,
    };
  }
}
