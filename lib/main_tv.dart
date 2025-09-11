import 'dart:io';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'const.dart';
import 'l10n/app_localizations.dart';
import 'pages_tv/home.dart';
import 'pages_tv/settings/settings_update.dart';
import 'providers/shortcut_tv.dart';
import 'providers/user_config.dart';
import 'theme.dart';
import 'utils/utils.dart';

void main() async {
  ScaledWidgetsFlutterBinding.ensureInitialized(scaleFactor: (deviceSize) => deviceSize.width / 960);
  final initialized = await Api.initialized();
  if (initialized ?? false) {
    HttpOverrides.global = MyHttpOverrides();
    final userConfig = await UserConfig.init();
    final shortcutTV = await ShortcutTV.init();
    Provider.debugCheckInvalidValueType = null;
    if (userConfig.shouldCheckUpdate()) {
      Future.microtask(() async {
        final data = await Api.checkUpdate(
          '${userConfig.githubProxy}$updateUrl',
          userConfig.updatePrerelease,
          Version.fromString(appVersion),
        );
        if (data != null) {
          navigateTo(navigatorKey.currentContext!, const SettingsUpdate());
        }
      });
    }
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => userConfig),
          ChangeNotifierProvider(create: (_) => shortcutTV),
        ],
        child: const MainApp(),
      ),
    );
  } else {
    runApp(const UpdateToLatest());
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
      themeMode: context.watch<UserConfig>().themeMode,
      theme: tvTheme,
      darkTheme: tvDarkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: context.watch<UserConfig>().locale,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: [routeObserver],
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      home: const TVHomePage(),
      themeAnimationCurve: Curves.easeOut,
      builder: (context, widget) {
        return FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(
            requestFocusCallback: (
              FocusNode node, {
              ScrollPositionAlignmentPolicy? alignmentPolicy,
              double? alignment,
              Duration? duration,
              Curve? curve,
            }) {
              node.requestFocus();
              Scrollable.ensureVisible(
                node.context!,
                alignment: alignment ?? 1,
                alignmentPolicy: alignmentPolicy ?? ScrollPositionAlignmentPolicy.explicit,
                duration: duration ?? const Duration(milliseconds: 400),
                curve: curve ?? Curves.easeOut,
              );
            },
          ),
          child: MediaQuery(data: MediaQuery.of(context).scale(), child: widget!),
        );
      },
    );
  }
}

class UpdateToLatest extends StatelessWidget {
  const UpdateToLatest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: tvTheme,
      darkTheme: tvDarkTheme,
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => host == 'image.tmdb.org';
  }
}
