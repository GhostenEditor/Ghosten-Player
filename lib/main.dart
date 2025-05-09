import 'dart:js_interop';
import 'dart:ui';
import 'dart:ui_web';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:scaled_app/scaled_app.dart';

import 'const.dart';
import 'pages/home.dart';
import 'pages_tv/home.dart';
import 'platform_api.dart';
import 'providers/user_config.dart';
import 'theme.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.initialized();
  PlatformApi.deviceType = DeviceType.web;
  final userConfig = await UserConfig.init();
  Provider.debugCheckInvalidValueType = null;
  runWidget(ChangeNotifierProvider(
      create: (_) => userConfig,
      child: MultiViewApp(
        viewBuilder: (BuildContext context) {
          final int viewId = View.of(context).viewId;
          final index = views.getInitialData(viewId)! as JSNumber;
          return MainApp(index: index.toDartInt);
        },
      )));
}

class MultiViewApp extends StatefulWidget {
  const MultiViewApp({super.key, required this.viewBuilder});

  final WidgetBuilder viewBuilder;

  @override
  State<MultiViewApp> createState() => _MultiViewAppState();
}

class _MultiViewAppState extends State<MultiViewApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateViews();
  }

  @override
  void didUpdateWidget(MultiViewApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    _views.clear();
    _updateViews();
  }

  @override
  void didChangeMetrics() {
    _updateViews();
  }

  Map<Object, Widget> _views = <Object, Widget>{};

  void _updateViews() {
    final Map<Object, Widget> newViews = <Object, Widget>{};
    for (final FlutterView view in WidgetsBinding.instance.platformDispatcher.views) {
      final Widget viewWidget = _views[view.viewId] ?? _createViewWidget(view);
      newViews[view.viewId] = viewWidget;
    }
    setState(() {
      _views = newViews;
    });
  }

  Widget _createViewWidget(FlutterView view) {
    return View(
      view: view,
      child: Builder(
        builder: widget.viewBuilder,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewCollection(views: _views.values.toList(growable: false));
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: index != 2 ? lightTheme : tvTheme,
      darkTheme: index != 2 ? darkTheme : tvDarkTheme,
      themeMode: context.watch<UserConfig>().themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: context.watch<UserConfig>().locale,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: [routeObserver],
      home: index != 2 ? const HomeView() : const TVHomePage(),
      themeAnimationCurve: Curves.easeOut,
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(context).scale().copyWith(
              textScaler: NoScaleTextScaler(),
              padding: index != 2 ? const EdgeInsets.only(top: 24, bottom: 12) : null,
            ),
        child: widget!,
      ),
    );
  }
}

class NoScaleTextScaler extends TextScaler {
  @override
  double scale(double fontSize) {
    return fontSize * textScaleFactor;
  }

  @override
  double get textScaleFactor => 1;
}
