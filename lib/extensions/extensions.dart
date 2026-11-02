import 'package:flutter/material.dart';

import '../components/components.dart';
import '../medias/media_list_theme.dart';

class AppTheme extends ThemeExtension<AppTheme> {
  const AppTheme({
    required this.channelsContentPadding,
    required this.channelsListViewPadding,
    required this.movieCardTheme,
    required this.seriesCardTheme,
    required this.seasonCardTheme,
    required this.episodeCardTheme,
    required this.castCardTheme,
    required this.crewCardTheme,
    required this.horizontalListTheme,
    required this.aspectRatioGridTheme,
    required this.wrapListTheme,
    required this.settingPageTheme,
    required this.mediaListTheme,
    required this.numberPickerTheme,
  });

  final HorizontalListThemeData horizontalListTheme;
  final AspectRatioGridThemeData aspectRatioGridTheme;
  final MediaListThemeData mediaListTheme;
  final SettingPageThemeData settingPageTheme;
  final WrapListThemeData wrapListTheme;
  final NumberPickerThemeData numberPickerTheme;
  final MediaCardThemeData movieCardTheme;
  final MediaCardThemeData seriesCardTheme;
  final MediaCardThemeData seasonCardTheme;
  final MediaCardThemeData episodeCardTheme;
  final MediaCardThemeData castCardTheme;
  final MediaCardThemeData crewCardTheme;
  final EdgeInsets channelsContentPadding;
  final EdgeInsets channelsListViewPadding;

  @override
  AppTheme copyWith({EdgeInsets? settingPageContentPadding}) {
    throw UnimplementedError();
  }

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) {
      return this;
    }
    return this;
  }
}
