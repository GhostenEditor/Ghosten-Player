import 'dart:convert';

import 'package:api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'adaptive/adaptive.dart';
import 'constants.dart';
import 'dialogs/event_snack_bar.dart';
import 'l10n/app_localizations.dart';
import 'platform_api.dart';
import 'providers/user_config.dart';
import 'routers.dart';
import 'utils/check_update.dart';
import 'utils/utils.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key, this.onGenerateInitialRoutes, required this.initialized});

  final bool initialized;
  final InitialRouteListFactory? onGenerateInitialRoutes;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;
  static final _stream = ReplaySubject<ScheduleTaskEventData>(maxSize: 1)
    ..addStream(Api.scheduleTaskEvent())
    ..stream.asBroadcastStream();

  @override
  void initState() {
    super.initState();
    if (!widget.initialized) {
      return;
    }
    final UserConfig userConfig = context.read<UserConfig>();
    if (!kIsWeb && userConfig.shouldCheckUpdate()) {
      Future.microtask(() async {
        final UpdateData? data = await checkUpdate(userConfig.updatePrerelease);
        if (data != null && mounted) {
          await navigatorKey.currentContext!.pushNamed(.settingsUpdater);
        }
      });
      if (!kIsTV) {
        PlatformApi.deeplinkEvent.listen(_scanToLogin);
      }
    }

    _stream.listen((data) {
      if (_snackBarController == null) {
        _snackBarController = ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: EventSnackBar(stream: _stream),
            persist: true,
            width: 360,
            behavior: .floating,
            showCloseIcon: true,
          ),
        );
        _snackBarController!.closed.whenComplete(() {
          _snackBarController = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserConfig userConfig = context.watch<UserConfig>();
    return MaterialApp(
      title: appName,
      navigatorKey: navigatorKey,
      showPerformanceOverlay: userConfig.showPerformanceOverlay,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: widget.initialized ? RouteName.home.name : RouteName.settingsUpdater.name,
      onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
      onGenerateRoute: onGenerateRoute,
      themeMode: userConfig.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: userConfig.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: [routeObserver],
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        if (kIsTV) const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      themeAnimationCurve: Curves.easeOut,
      builder: (context, widget) => PageWrapper(child: widget!),
    );
  }

  Future<void> _scanToLogin(String link) async {
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    if (await showConfirm(context, AppLocalizations.of(context)!.confirmTextLogin) != true) {
      return;
    }
    try {
      final Uri url = Uri.parse(link);
      final String data = utf8.decode(base64.decode(url.path.split('/').last));
      if (context.mounted) {
        await showNotification(context, Api.storageInsert(.webdav, jsonDecode(data)).last);
      }
      if (context.mounted) {
        await context.pushNamed(.settingsStorage);
      }
    } catch (_) {}
  }
}

class UpdateToLatest extends StatelessWidget {
  const UpdateToLatest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: context.watch<UserConfig>().themeMode,
      locale: context.watch<UserConfig>().locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        extendBodyBehindAppBar: true,
        body: Center(
          child: Builder(
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Text(AppLocalizations.of(context)!.versionDeprecatedTip, textAlign: TextAlign.center),
                  FilledButton.tonal(
                    onPressed: () => context.pushNamed(.external, arguments: repoUrl),
                    child: Text(AppLocalizations.of(context)!.updateNow),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
