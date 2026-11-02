import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../extensions/extensions.dart';

@immutable
class SettingPageThemeData with Diagnosticable {
  const SettingPageThemeData({this.contentPadding});

  final EdgeInsets? contentPadding;
}

class SettingPageTheme extends InheritedTheme {
  const SettingPageTheme({super.key, required this.data, required super.child});

  final SettingPageThemeData data;

  static SettingPageThemeData of(BuildContext context) {
    final SettingPageTheme? theme = context.dependOnInheritedWidgetOfExactType<SettingPageTheme>();
    return theme?.data ?? Theme.of(context).extension<AppTheme>()!.settingPageTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return SettingPageTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(SettingPageTheme oldWidget) => data != oldWidget.data;
}
