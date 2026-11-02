import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scaled_app/scaled_app.dart';

import '../../components/components.dart ';
import '../../providers/user_config.dart';

class PageWrapper extends StatelessWidget {
  const PageWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .scale()
          .copyWith(textScaler: _NoScaleTextScaler(), devicePixelRatio: MediaQuery.of(context).devicePixelRatio),
      child: ThemeBuilder(context.read<UserConfig>().themeColor, builder: (context) => child),
    );
  }
}

class _NoScaleTextScaler extends TextScaler {
  @override
  double scale(double fontSize) {
    return fontSize * textScaleFactor;
  }

  @override
  double get textScaleFactor => 1;
}
