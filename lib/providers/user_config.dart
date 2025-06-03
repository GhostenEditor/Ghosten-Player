import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/utils/utils.dart';

enum SystemLanguage {
  zh,
  en,
  auto;

  static SystemLanguage fromString(String? str) {
    return SystemLanguage.values.firstWhere((element) => element.name == str, orElse: () => SystemLanguage.auto);
  }
}

enum AutoUpdateFrequency {
  always,
  everyday,
  everyWeek,
  never;

  static AutoUpdateFrequency fromString(String? str) {
    return AutoUpdateFrequency.values.firstWhere(
      (element) => element.name == str,
      orElse: () => AutoUpdateFrequency.everyday,
    );
  }
}

extension FromString on ThemeMode {
  static ThemeMode fromString(String? str) {
    return ThemeMode.values.firstWhere((element) => element.name == str, orElse: () => ThemeMode.system);
  }
}

class UserConfig extends ChangeNotifier {
  UserConfig._fromPrefs(this.prefs)
    : language = SystemLanguage.fromString(prefs.getString('system.language')),
      themeMode = FromString.fromString(prefs.getString('system.themeMode')),
      autoUpdateFrequency = AutoUpdateFrequency.fromString(prefs.getString('system.autoUpdateFrequency')),
      lastCheckUpdateTime = DateTime.tryParse(prefs.getString('system.lastCheckUpdateTime') ?? ''),
      updatePrerelease = prefs.getBool('system.updatePrerelease') ?? false,
      githubProxy = prefs.getString('system.githubProxy') ?? '',
      autoPlay = prefs.getBool('playerConfig.autoPlay') ?? false,
      autoPip = prefs.getBool('playerConfig.autoPip') ?? false,
      autoForceLandscape = prefs.getBool('playerConfig.autoForceLandscape') ?? false,
      displayScale = prefs.getDouble('system.displayScale') ?? 1;
  final SharedPreferences prefs;
  SystemLanguage language;
  ThemeMode themeMode;
  AutoUpdateFrequency autoUpdateFrequency;
  bool updatePrerelease;
  String githubProxy;
  DateTime? lastCheckUpdateTime;
  bool autoPlay;
  bool autoForceLandscape;
  bool autoPip;
  double displayScale;

  static Future<UserConfig> init() async {
    final prefs = await SharedPreferences.getInstance();
    return UserConfig._fromPrefs(prefs);
  }

  void setAutoUpdate(AutoUpdateFrequency f) {
    autoUpdateFrequency = f;
    prefs.setString('system.autoUpdateFrequency', autoUpdateFrequency.name);
  }

  void setGithubProxy(String proxy) {
    githubProxy = proxy;
    prefs.setString('system.githubProxy', githubProxy);
  }

  void setUpdatePrerelease(bool f) {
    updatePrerelease = f;
    prefs.setBool('system.updatePrerelease', updatePrerelease);
  }

  void setAutoPlay(bool a) {
    autoPlay = a;
    notifyListeners();
    prefs.setBool('playerConfig.autoPlay', autoPlay);
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
    prefs.setString('system.themeMode', themeMode.name);
  }

  void setLanguage(SystemLanguage language) {
    this.language = language;
    notifyListeners();
    prefs.setString('system.language', language.name);
  }

  void setDisplayScale(double s) {
    if (displayScale != s) {
      displayScale = s;
      ScaledWidgetsFlutterBinding.instance.scaleFactor = (deviceSize) => max(1, deviceSize.width / 1140) * displayScale;
      prefs.setDouble('system.displayScale', displayScale);
    }
  }

  bool shouldCheckUpdate() {
    final now = DateTime.now();
    switch (autoUpdateFrequency) {
      case AutoUpdateFrequency.always:
        lastCheckUpdateTime = now;
        return true;
      case AutoUpdateFrequency.everyday:
        if (lastCheckUpdateTime == null || lastCheckUpdateTime!.add(const Duration(days: 1)) <= now) {
          lastCheckUpdateTime = now;
          prefs.setString('system.lastCheckUpdateTime', lastCheckUpdateTime!.toString());
          return true;
        } else {
          return false;
        }
      case AutoUpdateFrequency.everyWeek:
        if (lastCheckUpdateTime == null || lastCheckUpdateTime!.add(const Duration(days: 7)) <= now) {
          lastCheckUpdateTime = now;
          prefs.setString('system.lastCheckUpdateTime', lastCheckUpdateTime!.toString());
          return true;
        } else {
          return false;
        }
      case AutoUpdateFrequency.never:
        return false;
    }
  }

  Locale? get locale {
    return switch (language) {
      SystemLanguage.zh => const Locale('zh', 'CN'),
      SystemLanguage.en => const Locale('en', 'US'),
      SystemLanguage.auto => null,
    };
  }
}
