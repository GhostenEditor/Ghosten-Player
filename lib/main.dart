import 'dart:js_interop';
import 'dart:math';
import 'dart:ui';
import 'dart:ui_web';

import 'package:api/api.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:scaled_app/scaled_app.dart';

import 'const.dart';
import 'pages/home.dart';
import 'pages_tv/home.dart';
import 'platform_api.dart';
import 'providers/shortcut_tv.dart';
import 'providers/user_config.dart';
import 'theme.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.initialized();
  PlatformApi.deviceType = DeviceType.web;
  final userConfig = await UserConfig.init();
  final shortcutTV = await ShortcutTV.init();
  Provider.debugCheckInvalidValueType = null;
  runWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => userConfig),
      ChangeNotifierProvider(create: (_) => shortcutTV),
    ],
    child: MultiViewApp(
      viewBuilder: (BuildContext context) {
        final int viewId = View.of(context).viewId;
        final index = views.getInitialData(viewId)! as JSNumber;
        return MainApp(index: index.toDartInt);
      },
    ),
  ));
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
    final child = MaterialApp(
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
              padding: index != 2 ? const EdgeInsets.only(top: 36, bottom: 12) : null,
            ),
        child: widget!,
      ),
    );
    return index != 2
        ? Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                child,
                IgnorePointer(
                    child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  darkTheme: ThemeData.dark(),
                  themeMode: context.watch<UserConfig>().themeMode,
                  home: const StatusBar(),
                )),
              ],
            ),
          )
        : child;
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

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: IconTheme(
        data: IconThemeData(
            size: 18,
            color: switch (Theme.of(context).brightness) {
              Brightness.dark => Colors.white,
              Brightness.light => Colors.black,
            }),
        child: Align(
          alignment: Alignment.topCenter,
          child: Row(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(),
              DefaultTextStyle(
                style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
                child: StreamBuilder(
                  initialData: formatDate(DateTime.now(), [HH, ':', nn]),
                  stream: Stream.periodic(const Duration(seconds: 10)).map((_) => formatDate(DateTime.now(), [HH, ':', nn])).distinct(),
                  builder: (context, snapshot) => Text(snapshot.requireData),
                ),
              ),
              const Icon(Icons.near_me_rounded, size: 16),
              const Spacer(),
              const Icon(Icons.signal_cellular_alt),
              const Icon(Icons.five_g_rounded),
              const Icon(Icons.wifi_rounded),
              Transform.rotate(angle: pi / 2, child: Icon(Icons.battery_6_bar_rounded, size: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
