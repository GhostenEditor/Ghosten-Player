import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'components/updater.dart';
import 'const.dart';
import 'pages/account/account.dart';
import 'pages/home.dart';
import 'pages/player/singleton_player.dart';
import 'platform_api.dart';
import 'providers/user_config.dart';
import 'theme.dart';
import 'utils/notification.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.initialized();
  if (kIsWeb) {
    BrowserContextMenu.disableContextMenu();
    PlatformApi.deviceType = DeviceType.web;
  } else {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    HttpOverrides.global = MyHttpOverrides();
    await PlatformApi.getDeviceType();
    kIsAndroidTV = PlatformApi.isAndroidTV();
  }
  final externalUrl = kIsWeb ? null : await PlatformApi.externalUrl;
  if (externalUrl == null) {
    setPreferredOrientations(false);
    final userConfig = await UserConfig.init();
    Provider.debugCheckInvalidValueType = null;
    if (!kIsWeb && userConfig.shouldCheckUpdate()) {
      Api.checkUpdate(
        updateUrl,
        Version.fromString(appVersion),
        needUpdate: (data, url) => showModalBottomSheet(
            context: navigatorKey.currentContext!,
            constraints: const BoxConstraints(minWidth: double.infinity, maxHeight: 320),
            builder: (context) => UpdateBottomSheet(data, url: url)),
      );
    }
    runApp(ChangeNotifierProvider(create: (_) => userConfig, child: const MainApp()));
    PlatformApi.deeplinkEvent.listen(scanToLogin);
  } else {
    runApp(PlayerApp(url: externalUrl));
  }
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
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      home: const QuitConfirm(child: HomeView()),
      themeAnimationCurve: Curves.easeOut,
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: NoScaleTextScaler()),
        child: widget!,
      ),
    );
  }
}

class PlayerApp extends StatelessWidget {
  final String url;

  const PlayerApp({super.key, required this.url});

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
      home: QuitConfirm(child: SingletonPlayer(url: url, isTV: PlatformApi.isAndroidTV())),
      builder: (context, widget) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: NoScaleTextScaler()),
        child: widget!,
      ),
    );
  }
}

class QuitConfirm extends StatefulWidget {
  final Widget child;

  const QuitConfirm({super.key, required this.child});

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
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }
              if (confirmed) {
                confirmed = false;
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
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
    if (context.mounted) await showNotification(context, Api.driverInsert(jsonDecode(data)));
    if (context.mounted) navigateTo(context, const AccountManage());
  } catch (_) {}
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => host == 'image.tmdb.org';
  }
}
