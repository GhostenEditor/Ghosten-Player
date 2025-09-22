import 'package:flutter/material.dart';

class ThemeBuilder extends StatelessWidget {
  const ThemeBuilder(this.themeColor, {super.key, required this.builder});

  final int? themeColor;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme:
            themeColor == null
                ? null
                : ColorScheme.fromSeed(seedColor: Color(themeColor!), brightness: Theme.of(context).brightness),
      ),
      child: Builder(builder: builder),
    );
  }
}
