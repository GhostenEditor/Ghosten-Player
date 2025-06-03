import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../components/logo.dart';
import '../l10n/app_localizations.dart';
import 'components/mobile_builder.dart';
import 'media/live_list.dart';
import 'media/movie_list.dart';
import 'media/tv_list.dart';
import 'settings/settings.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int index = 0;

  Widget get child => switch (index) {
    0 => const TVListPage(),
    1 => const MovieListPage(),
    2 => BlocProvider(create: (_) => IptvCubit(), child: const LiveListPage()),
    3 => const SettingsPage(),
    _ => const Placeholder(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: MobileBuilder(
        builder: (context, isMobile, child) => isMobile ? child : null,
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() => this.index = index),
          destinations:
              _destinations(context).map((_TabDestination destination) {
                return NavigationDestination(
                  label: destination.label,
                  icon: destination.icon,
                  selectedIcon: destination.selectedIcon,
                  tooltip: '',
                );
              }).toList(),
        ),
      ),
      backgroundColor: index == 2 ? Colors.transparent : null,
      body: Row(
        children: <Widget>[
          MobileBuilder(
            builder: (context, isMobile, child) => isMobile ? null : child,
            child: Row(
              children: [
                NavigationRail(
                  leading: const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Logo(size: 36)),
                  labelType: NavigationRailLabelType.all,
                  destinations:
                      _destinations(context)
                          .map(
                            (destination) => NavigationRailDestination(
                              label: Text(destination.label),
                              icon: destination.icon,
                              selectedIcon: destination.selectedIcon,
                            ),
                          )
                          .toList(),
                  selectedIndex: index,
                  useIndicator: true,
                  onDestinationSelected: (index) => setState(() => this.index = index),
                ),
                if (index != 2) VerticalDivider(color: Theme.of(context).colorScheme.surfaceContainerHighest),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  List<_TabDestination> _destinations(BuildContext context) {
    return [
      _TabDestination(AppLocalizations.of(context)!.homeTabTV, const Icon(Icons.tv_outlined), const Icon(Icons.tv)),
      _TabDestination(
        AppLocalizations.of(context)!.homeTabMovie,
        const Icon(Icons.movie_creation_outlined),
        const Icon(Icons.movie_creation),
      ),
      _TabDestination(
        AppLocalizations.of(context)!.homeTabLive,
        const Icon(Icons.live_tv_outlined),
        const Icon(Icons.live_tv),
      ),
      _TabDestination(
        AppLocalizations.of(context)!.homeTabSettings,
        const Icon(Icons.settings_outlined),
        const Icon(Icons.settings),
      ),
    ];
  }
}

class _TabDestination {
  const _TabDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}
