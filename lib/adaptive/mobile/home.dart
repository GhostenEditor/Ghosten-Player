import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/components.dart';
import '../../l10n/app_localizations.dart';
import '../../routers.dart';
import '../../utils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;
  final _homeNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return QuitConfirm(
      child: Scaffold(
        appBar: switch (_tabIndex) {
          0 || 1 || 2 => UnpinnedAppBar(
            unpinned: switch (_tabIndex) {
              0 || 1 => true,
              _ => false,
            },
            appbar: AppBar(
              systemOverlayStyle: switch (Theme.brightnessOf(context)) {
                Brightness.dark => const SystemUiOverlayStyle(
                  systemNavigationBarIconBrightness: Brightness.light,
                  systemNavigationBarColor: Color(0x01000000),
                  statusBarIconBrightness: Brightness.light,
                  statusBarColor: Colors.transparent,
                ),
                Brightness.light => const SystemUiOverlayStyle(
                  systemNavigationBarIconBrightness: Brightness.dark,
                  systemNavigationBarColor: Color(0x01FFFFFF),
                  statusBarIconBrightness: Brightness.dark,
                  statusBarColor: Colors.transparent,
                ),
              },
              forceMaterialTransparency: switch (_tabIndex) {
                0 || 1 => true,
                _ => false,
              },
              title: switch (_tabIndex) {
                0 => Text(AppLocalizations.of(context)!.homeTabTV),
                1 => Text(AppLocalizations.of(context)!.homeTabMovie),
                2 => Text(AppLocalizations.of(context)!.homeTabLive),
                _ => null,
              },
              actions: [
                const ServerSwitcher(),
                IconButton(onPressed: () => context.pushNamed(.search), icon: const Icon(Icons.search_rounded)),
              ],
            ),
          ),
          _ => null,
        },
        extendBodyBehindAppBar: _tabIndex != 2,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: Container(
          margin: EdgeInsets.only(bottom: max(24, MediaQuery.paddingOf(context).bottom)),
          height: 60,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: Center(
              child: Material(
                shape: StadiumBorder(side: BorderSide(color: Theme.of(context).colorScheme.surfaceContainerHigh)),
                clipBehavior: .antiAlias,
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: NavigationBar(
                    selectedIndex: _tabIndex,
                    labelBehavior: .alwaysHide,
                    indicatorShape: const CircleBorder(),
                    onDestinationSelected: _onTabClick,
                    destinations: _destinations(context)
                        .map(
                          (destination) => NavigationDestination(
                            label: destination.label,
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selectedIcon),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: AppNavigator(
          initialRoute: RouteName.tv.name,
          navigatorKey: _homeNavigatorKey,
          onGenerateRoute: onGenerateRoute,
        ),
      ),
    );
  }

  List<_TabDestination> _destinations(BuildContext context) {
    return [
      _TabDestination(AppLocalizations.of(context)!.homeTabTV, Icons.tv_outlined, Icons.tv),
      _TabDestination(AppLocalizations.of(context)!.homeTabMovie, Icons.movie_creation_outlined, Icons.movie_creation),
      _TabDestination(AppLocalizations.of(context)!.homeTabLive, Icons.live_tv_outlined, Icons.live_tv),
      _TabDestination(AppLocalizations.of(context)!.homeTabSettings, Icons.settings_outlined, Icons.settings),
    ];
  }

  void _onTabClick(int index) {
    if (_tabIndex == index) {
      return;
    }
    setState(() => _tabIndex = index);
    _homeNavigatorKey.currentContext!.pushReplacementNamed(switch (index) {
      0 => .tv,
      1 => .movie,
      2 => .live,
      3 => .settings,
      _ => throw UnimplementedError(),
    });
  }
}

class _TabDestination {
  const _TabDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
