import 'package:flutter/material.dart';

const fontFamily = 'Roboto Condensed';
const _bottomSheetTheme = BottomSheetThemeData(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(3.0))),
);
const _dialogTheme = DialogThemeData(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3.0))),
);
final lightTheme = ThemeData(
  bottomSheetTheme: _bottomSheetTheme,
  dialogTheme: _dialogTheme,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3558C4), primary: const Color(0xFF3558C4)),
  dividerTheme: const DividerThemeData(space: 1, color: Colors.black12),
  cardTheme: const CardThemeData(elevation: 0.75),
  appBarTheme: const AppBarTheme(
    scrolledUnderElevation: 0.75,
    shadowColor: Color(0xFFFCFCFF),
    backgroundColor: Color(0xFFFCFCFF),
  ),
  navigationBarTheme: const NavigationBarThemeData(elevation: 0.7, backgroundColor: Color(0xFFF4F4F4)),
  drawerTheme: const DrawerThemeData(endShape: ContinuousRectangleBorder()),
  scaffoldBackgroundColor: const Color(0xFFFCFCFF),
);

final darkTheme = ThemeData(
  bottomSheetTheme: _bottomSheetTheme,
  dialogTheme: _dialogTheme,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF98C2FF), brightness: Brightness.dark),
  dividerTheme: const DividerThemeData(space: 1, color: Colors.white12),
  cardTheme: const CardThemeData(elevation: 4, shadowColor: Colors.transparent),
  appBarTheme: const AppBarTheme(scrolledUnderElevation: 0.75),
  navigationBarTheme: const NavigationBarThemeData(elevation: 0.75, backgroundColor: Color(0xFF111318)),
  drawerTheme: const DrawerThemeData(endShape: ContinuousRectangleBorder()),
);

final tvTheme = ThemeData(
  fontFamily: fontFamily,
  bottomSheetTheme: _bottomSheetTheme,
  dialogTheme: _dialogTheme,
  drawerTheme: const DrawerThemeData(shape: RoundedRectangleBorder(), endShape: RoundedRectangleBorder()),
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF98C2FF)),
  dividerTheme: const DividerThemeData(color: Colors.black12),
  scrollbarTheme: const ScrollbarThemeData(radius: Radius.circular(10)),
);

final tvDarkTheme = ThemeData(
  fontFamily: fontFamily,
  bottomSheetTheme: _bottomSheetTheme,
  dialogTheme: _dialogTheme,
  drawerTheme: const DrawerThemeData(shape: RoundedRectangleBorder(), endShape: RoundedRectangleBorder()),
  scaffoldBackgroundColor: Colors.black,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF98C2FF), brightness: Brightness.dark),
  dividerTheme: const DividerThemeData(color: Colors.white12),
  scrollbarTheme: const ScrollbarThemeData(radius: Radius.circular(10)),
);
