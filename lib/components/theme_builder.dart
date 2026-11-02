import 'package:flutter/material.dart';

class ThemeBuilder extends StatelessWidget {
  const ThemeBuilder(this.themeColor, {super.key, required this.builder});

  final int? themeColor;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return themeColor != null ? _themeWidget(context, themeColor!) : builder(context);
  }

  Widget _themeWidget(BuildContext context, int themeColor) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Color(themeColor), brightness: Theme.of(context).brightness);
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
        cardColor: colorScheme.surface,
      ),
      child: Builder(builder: builder),
    );
  }
}
