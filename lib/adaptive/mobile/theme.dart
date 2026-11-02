import 'package:flutter/material.dart';

import '../../components/components.dart';
import '../../extensions/extensions.dart';
import '../../medias/media_list_theme.dart';

const _bottomSheetTheme = BottomSheetThemeData(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
);
const _dialogTheme = DialogThemeData(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3.0))),
);

final _actionIconTheme = ActionIconThemeData(
  backButtonIconBuilder: (context) => const Icon(Icons.chevron_left_rounded),
  endDrawerButtonIconBuilder: (context) => const Icon(Icons.more_vert_rounded),
);
const _cardTheme = CardThemeData(elevation: 6, clipBehavior: .antiAlias);
const _filledButtonTheme = FilledButtonThemeData(style: ButtonStyle());
final List<AppTheme> _extensions = [_mobileAppTheme];
const _drawerTheme = DrawerThemeData(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
  endShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
);

const _snackBarTheme = SnackBarThemeData(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
  elevation: 2,
);

final lightTheme = ThemeData(
  actionIconTheme: _actionIconTheme,
  bottomSheetTheme: _bottomSheetTheme,
  cardTheme: _cardTheme,
  dialogTheme: _dialogTheme,
  dividerTheme: const DividerThemeData(color: Colors.black12),
  dividerColor: Colors.black12,
  drawerTheme: _drawerTheme,
  filledButtonTheme: _filledButtonTheme,
  extensions: _extensions,
  snackBarTheme: _snackBarTheme,
  textTheme: const TextTheme(labelSmall: TextStyle(color: Color(0xFF666666))),
);

final darkTheme = ThemeData(
  actionIconTheme: _actionIconTheme,
  bottomSheetTheme: _bottomSheetTheme,
  cardTheme: _cardTheme,
  brightness: .dark,
  dialogTheme: _dialogTheme,
  dividerColor: Colors.white12,
  dividerTheme: const DividerThemeData(color: Colors.white12),
  drawerTheme: _drawerTheme,
  filledButtonTheme: _filledButtonTheme,
  extensions: _extensions,
  snackBarTheme: _snackBarTheme,
  textTheme: const TextTheme(labelSmall: TextStyle(color: Color(0xFFAAAAAA))),
);

const _mobileAppTheme = AppTheme(
  horizontalListTheme: HorizontalListThemeData(
    headerPadding: EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
    padding: EdgeInsets.only(left: 12, right: 12, bottom: 8),
    itemSpacing: 4,
  ),
  wrapListTheme: WrapListThemeData(
    headerPadding: EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
    padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
    spacing: 4,
    runSpacing: 4,
  ),
  settingPageTheme: SettingPageThemeData(contentPadding: .zero),
  aspectRatioGridTheme: AspectRatioGridThemeData(crossAxisSpacing: 4, mainAxisSpacing: 16),
  movieCardTheme: MediaCardThemeData(minWidth: 120, aspectRatio: 2 / 3, heightExtent: 66),
  seriesCardTheme: MediaCardThemeData(minWidth: 120, aspectRatio: 2 / 3, heightExtent: 66),
  seasonCardTheme: MediaCardThemeData(minWidth: 120, aspectRatio: 2 / 3, heightExtent: 66),
  episodeCardTheme: MediaCardThemeData(minWidth: 188, aspectRatio: 16 / 9, heightExtent: 80),
  castCardTheme: MediaCardThemeData(minWidth: 90, aspectRatio: 2 / 3, heightExtent: 98),
  crewCardTheme: MediaCardThemeData(minWidth: 90, aspectRatio: 2 / 3, heightExtent: 98),
  channelsContentPadding: .zero,
  channelsListViewPadding: .zero,
  mediaListTheme: MediaListThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
  numberPickerTheme: NumberPickerThemeData(),
);
