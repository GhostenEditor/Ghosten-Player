import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/utils/utils.dart';

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
  UserConfig(this.prefs)
    : language = SupportedLanguages.fromString(prefs.getString('system.language')),
      themeMode = FromString.fromString(prefs.getString('system.themeMode')),
      themeColor = prefs.getInt('system.themeColor') ?? 0xFFFFFFFF,
      autoUpdateFrequency = AutoUpdateFrequency.fromString(prefs.getString('system.autoUpdateFrequency')),
      lastCheckUpdateTime = DateTime.tryParse(prefs.getString('system.lastCheckUpdateTime') ?? ''),
      updatePrerelease = prefs.getBool('system.updatePrerelease') ?? false,
      githubProxy = /*prefs.getString('system.githubProxy') ??*/ '',
      displayScale = prefs.getDouble('system.displayScale') ?? 1,
      showPerformanceOverlay = prefs.getBool('system.showPerformanceOverlay') ?? false;
  final SharedPreferences prefs;
  SupportedLanguages language;
  ThemeMode themeMode;
  int themeColor;
  AutoUpdateFrequency autoUpdateFrequency;
  bool updatePrerelease;
  String githubProxy;
  DateTime? lastCheckUpdateTime;

  double displayScale;
  bool showPerformanceOverlay;

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

  void setTheme(ThemeMode themeMode) {
    this.themeMode = themeMode;
    notifyListeners();
    prefs.setString('system.themeMode', themeMode.name);
  }

  void setThemeColor(int themeColor) {
    this.themeColor = themeColor;
    notifyListeners();
    prefs.setInt('system.themeColor', themeColor);
  }

  void setLanguage(SupportedLanguages language) {
    this.language = language;
    notifyListeners();
    prefs.setString('system.language', language.name);
  }

  void setDisplayScale(double s) {
    if (displayScale != s) {
      displayScale = s;
      ScaledWidgetsFlutterBinding.instance.scaleFactor = (deviceSize) => displayScale;
      prefs.setDouble('system.displayScale', displayScale);
    }
  }

  void setShowPerformanceOverlay(bool showPerformanceOverlay) {
    this.showPerformanceOverlay = showPerformanceOverlay;
    notifyListeners();
    prefs.setBool('system.showPerformanceOverlay', showPerformanceOverlay);
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
      SupportedLanguages.zhCn => const Locale('zh', 'CN'),
      SupportedLanguages.enUs => const Locale('en', 'US'),
      SupportedLanguages.auto => null,
    };
  }
}
