import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/player.dart';

import 'const.dart';
import 'l10n/app_localizations.dart';
import 'pages/account/account.dart';
import 'pages/components/updater.dart';
import 'pages/home.dart';
import 'pages/player/singleton_player.dart';
import 'pages/utils/notification.dart';
import 'pages/utils/utils.dart';
import 'platform_api.dart';
import 'providers/user_config.dart';
import 'theme.dart';
import 'utils/utils.dart';

void main(List<String> args) async {
  ScaledWidgetsFlutterBinding.ensureInitialized();
  final initialized = await Api.initialized();
  if (initialized ?? false) {
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
      PlatformApi.deviceType = DeviceType.web;
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      HttpOverrides.global = MyHttpOverrides();
      PlatformApi.deviceType = DeviceType.fromString(args[0]);
    }
    setPreferredOrientations(false);
    final userConfig = await UserConfig.init();
    ScaledWidgetsFlutterBinding.instance.scaleFactor =
        (deviceSize) => max(1, deviceSize.width / 1140) * userConfig.displayScale;
    Provider.debugCheckInvalidValueType = null;
    if (!kIsWeb && userConfig.shouldCheckUpdate()) {
      Future.microtask(() async {
        final data = await Api.checkUpdate(
          '${userConfig.githubProxy}$updateUrl',
          userConfig.updatePrerelease,
          Version.fromString(appVersion),
        );
        if (data != null) {
          showModalBottomSheet(
            context: navigatorKey.currentContext!,
            constraints: const BoxConstraints(minWidth: double.infinity),
            builder: (context) => UpdateBottomSheet(data),
          );
        }
      });
    }
    runApp(ChangeNotifierProvider(create: (_) => userConfig, child: const MainApp()));
    PlatformApi.deeplinkEvent.listen(scanToLogin);
  } else {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    runApp(const UpdateToLatest());
  }
}

@pragma('vm:entry-point')
// ignore: avoid_void_async
void player(List<String> args) async {
  ScaledWidgetsFlutterBinding.ensureInitialized();
  PlatformApi.deviceType = DeviceType.fromString(args[0]);
  final userConfig = await UserConfig.init();
  ScaledWidgetsFlutterBinding.instance.scaleFactor =
      (deviceSize) => max(1, deviceSize.width / 1140) * userConfig.displayScale;
  runApp(ChangeNotifierProvider(create: (_) => userConfig, child: PlayerApp(url: args[1])));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: context.watch<UserConfig>().themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: context.watch<UserConfig>().locale,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: [routeObserver],
      home: const QuitConfirm(child: HomeView()),
      themeAnimationCurve: Curves.easeOut,
      builder:
          (context, widget) => MediaQuery(
            data: MediaQuery.of(context).scale().copyWith(textScaler: NoScaleTextScaler()),
            child: widget!,
          ),
    );
  }
}

class PlayerApp extends StatelessWidget {
  const PlayerApp({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      home: QuitConfirm(child: SingletonPlayer(playlist: [PlaylistItemDisplay(url: Uri.parse(url), source: null)])),
      builder:
          (context, widget) =>
              MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: NoScaleTextScaler()), child: widget!),
    );
  }
}

class QuitConfirm extends StatefulWidget {
  const QuitConfirm({super.key, required this.child});

  final Widget child;

  @override
  State<QuitConfirm> createState() => _QuitConfirmState();
}

class _QuitConfirmState extends State<QuitConfirm> {
  bool confirmed = false;

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? widget.child
        : PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              return;
            }
            if (Navigator.of(context).canPop()) {
              return;
            }
            if (confirmed) {
              confirmed = false;
              SystemNavigator.pop();
            } else {
              confirmed = true;
              final controller = ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.confirmTextExit, textAlign: TextAlign.center),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  width: 200,
                ),
              );
              controller.closed.then((_) => confirmed = false);
            }
          },
          child: widget.child,
        );
  }
}

class UpdateToLatest extends StatelessWidget {
  const UpdateToLatest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(),
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
                    onPressed: () {
                      launchUrlString(
                        'https://github.com/$repoAuthor/$repoName',
                        browserConfiguration: const BrowserConfiguration(showTitle: true),
                      );
                    },
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

class NoScaleTextScaler extends TextScaler {
  @override
  double scale(double fontSize) {
    return fontSize * textScaleFactor;
  }

  @override
  double get textScaleFactor => 1;
}

Future<void> scanToLogin(String link) async {
  final context = navigatorKey.currentContext;
  if (context == null) return;
  if (await showConfirm(context, AppLocalizations.of(context)!.confirmTextLogin) != true) return;
  try {
    final url = Uri.parse(link);
    final data = utf8.decode(base64.decode(url.path.split('/').last));
    if (context.mounted) await showNotification(context, Api.driverInsert(jsonDecode(data)).last);
    if (context.mounted) navigateTo(context, const AccountManage());
  } catch (_) {}
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => host == 'image.tmdb.org';
  }
}
