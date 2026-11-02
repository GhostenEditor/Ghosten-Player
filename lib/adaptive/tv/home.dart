import 'package:flutter/material.dart' hide ListTile, RadioListTile;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/shortcut_tv.dart';
import '../../routers.dart';
import '../../utils/utils.dart';
import 'components/_home_tab.dart';
import 'tv.dart';

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final initialRoute = ValueNotifier<RouteName>(.settings);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final ShortcutTV shortcuts = context.watch<ShortcutTV>();
    return QuitConfirm(
      child: Focus(
        skipTraversal: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent || event is KeyRepeatEvent) {
            if (event.logicalKey == shortcuts.menu) {
              if (!homeScaffoldKey.currentState!.isEndDrawerOpen) {
                homeScaffoldKey.currentState!.openEndDrawer();
                return KeyEventResult.handled;
              }
            }
          }
          return KeyEventResult.ignored;
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, r) {
            if (didPop) {
              return;
            }
            if (homeScaffoldKey.currentState!.isEndDrawerOpen) {
              if (!settingNavigatorKey.currentState!.canPop()) {
                homeScaffoldKey.currentState!.closeEndDrawer();
              }
            }
          },
          child: Scaffold(
            key: homeScaffoldKey,
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: false,
            appBar: _HomeAppbar(
              onTabChange: (index) => _homeNavigatorKey.currentContext!.pushReplacementNamed(switch (index) {
                0 => .tv,
                1 => .movie,
                2 => .live,
                _ => throw UnimplementedError(),
              }),
            ),
            endDrawer: Drawer(
              child: AppNavigator(
                navigatorKey: settingNavigatorKey,
                initialRoute: RouteName.settings.name,
                onGenerateRoute: onGenerateRoute,
              ),
            ),
            body: AppNavigator(
              navigatorKey: _homeNavigatorKey,
              initialRoute: RouteName.tv.name,
              routeDirectionalTraversalEdgeBehavior: .parentScope,
              onGenerateRoute: onGenerateRoute,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeAppbar extends StatefulWidget implements PreferredSizeWidget {
  const _HomeAppbar({required this.onTabChange});

  final ValueChanged<int> onTabChange;

  @override
  State<_HomeAppbar> createState() => _HomeAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeAppbarState extends State<_HomeAppbar> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return UnpinnedAppBar(
      appbar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton.filledTonal(
          onPressed: () => context.pushNamed(.search),
          icon: const Icon(Icons.search_rounded, size: 20),
        ),
        leadingWidth: 136,
        titleSpacing: 40,
        title: HomeTabs(
          activeIndex: _activeIndex,
          tabs: [
            AppLocalizations.of(context)!.homeTabTV,
            AppLocalizations.of(context)!.homeTabMovie,
            AppLocalizations.of(context)!.homeTabLive,
          ],
          onTabChange: (index) {
            _activeIndex = index;
            widget.onTabChange(index);
          },
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 48),
        actions: [
          const ServerSwitcher(),
          IconButton(
            onPressed: () => homeScaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 12),
          const Clock(),
        ],
      ),
    );
  }
}
