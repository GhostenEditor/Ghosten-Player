import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../adaptive/adaptive.dart';
import '../platform_api.dart';
import '../providers/player.dart';

extension NavigatorExtension on BuildContext {
  Future<T?> pushNamed<T extends Object?>(RouteName routeName, {Object? arguments}) {
    if (routeName == .external) {
      return launchUrlString(
        arguments! as String,
        mode: .inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(showTitle: true),
      ).then((_) => null);
    }
    return _resolveRoute(
      this,
      routeName,
      (navigatorState) => navigatorState.pushNamed(routeName.name, arguments: arguments),
    );
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    RouteName routeName, {
    TO? result,
    Object? arguments,
  }) {
    return _resolveRoute(
      this,
      routeName,
      (navigatorState) =>
          navigatorState.pushReplacementNamed<dynamic, TO>(routeName.name, arguments: arguments, result: result),
    );
  }

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    RouteName routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return _resolveRoute(
      this,
      routeName,
      (navigatorState) => navigatorState.pushNamedAndRemoveUntil(routeName.name, predicate, arguments: arguments),
    );
  }
}

Future<T?> _resolveRoute<T extends Object?>(
  BuildContext context,
  RouteName routeName,
  Future<dynamic> Function(NavigatorState navigatorState) runner,
) async {
  final NavigatorState state = await getNavigatorState(context, routeName);
  if (routeName == .player) {
    await _setPreferredOrientations(true);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  final dynamic re = await runner(state);
  if (routeName == .player) {
    await _setPreferredOrientations(false);
    // TODO(GhostenEditor): bug when SDK < 29
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  return re as T?;
}

Future<void> _setPreferredOrientations(bool fullscreen) {
  if (PlatformApi.isAndroidPhone()) {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      if (fullscreen) DeviceOrientation.landscapeLeft,
      if (fullscreen) DeviceOrientation.landscapeRight,
    ]);
  } else {
    return Future.value();
  }
}

enum RouteName {
  home,
  tv,
  movie,
  live,
  liveEdit,
  liveDetail,
  settings,
  detailSeries,
  detailSeries2,
  detailSeason,
  detailEpisode,
  detailMovie,
  search,
  scrape,
  media,
  player,
  livePlayer,
  castPlayer,
  castSearcher,
  subtitle,
  subtitleAdd,
  setSkipTime,
  imageViewer,
  storagePicker,
  metadataSeries,
  metadataSeason,
  metadataEpisode,
  metadataMovie,
  fileRename,
  settingsStorage,
  settingsStorageAdd,
  settingsStoragePreference,
  settingsLibraryTv,
  settingsLibraryMovie,
  settingsPlay,
  settingsHistory,
  settingsDownload,
  settingsServer,
  settingsServerAdd,
  settingsDiagnostics,
  settingsLog,
  settingsOther,
  settingsPlayer,
  settingsPlayerKernel,
  settingsSync,
  settingsDns,
  settingsDnsEdit,
  settingsShortcut,
  settingsHelp,
  settingsHelpDetail,
  settingsSponsor,
  settingsAbout,
  settingsUpdater,
  external;

  static RouteName? fromStringOrNull(String? s) {
    return RouteName.values.firstWhereOrNull((item) => item.name == s);
  }
}

enum RouteType {
  material,
  player,
  noTransition,
  fadeIn,
  modalBottomSheet,
  modalBottomSheetWithHandle,
  modalBottomSheetFull,
}

Future<T?> navigateToSlideLeft<T extends Object?>(BuildContext context, Widget page) {
  return Navigator.of(context).push(FadeInPageRoute<T>(builder: (context) => page));
}

class PlayerPageRoute<T> extends MaterialPageRoute<T> {
  PlayerPageRoute({required super.builder, super.settings});

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final ThemeData theme = switch (context.read<PlayerConfig>().themeMode) {
      ThemeMode.system => switch (Theme.brightnessOf(context)) {
        Brightness.dark => darkTheme.copyWith(scaffoldBackgroundColor: Colors.black),
        Brightness.light => lightTheme,
      },
      ThemeMode.light => lightTheme,
      ThemeMode.dark => darkTheme.copyWith(scaffoldBackgroundColor: Colors.black),
    };
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(backgroundColor: theme.scaffoldBackgroundColor),
          },
        ).buildTransitions<T>(this, context, animation, ReverseAnimation(animation), child),
      ),
    );
  }
}

class NoTransitionPageRoute<T> extends PageRoute<T> {
  NoTransitionPageRoute({required this.builder, super.settings});

  final WidgetBuilder builder;

  @override
  final Color? barrierColor = null;

  @override
  final String? barrierLabel = null;

  @override
  final bool maintainState = true;
  @override
  final Duration transitionDuration = Duration.zero;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }
}

class FadeInPageRoute<T> extends MaterialPageRoute<T> {
  FadeInPageRoute({required super.builder, super.settings});

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(
          transitionType: .horizontal,
          fillColor: Colors.transparent,
        ),
      },
    ).buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }
}
