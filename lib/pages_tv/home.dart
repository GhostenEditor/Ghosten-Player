import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'components/clock.dart';
import 'components/icon_button.dart';
import 'media/live_list.dart';
import 'media/movie_list.dart';
import 'media/tv_list.dart';
import 'settings/settings.dart';
import 'utils/utils.dart';

class TVHomePage extends StatefulWidget {
  const TVHomePage({super.key});

  @override
  State<TVHomePage> createState() => _HomeState();
}

class _HomeState extends State<TVHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  int tabIndex = 0;
  bool reverse = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      skipTraversal: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.contextMenu:
              if (!_scaffoldKey.currentState!.isEndDrawerOpen) {
                _scaffoldKey.currentState!.openEndDrawer();
                return KeyEventResult.handled;
              }
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: StreamBuilder(
            stream: Api.progress$,
            builder: (context, snapshot) => switch (snapshot.data) {
                  null => const SizedBox(),
                  0 => const LinearProgressIndicator(backgroundColor: Colors.transparent),
                  -1 => LinearProgressIndicator(color: Theme.of(context).colorScheme.error, value: 1),
                  _ => TweenAnimationBuilder(
                      tween: Tween(end: snapshot.data),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      builder: (BuildContext context, double value, Widget? child) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.transparent,
                      ),
                    )
                }),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leadingWidth: 160,
          leading: Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                label: Text(AppLocalizations.of(context)!.search),
                onPressed: null,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  iconColor: Colors.white,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(color: Colors.white),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.mic_rounded, size: 20, color: Colors.grey),
              ),
            ),
          ),
          title: _HomeTabs(
              tabs: [
                AppLocalizations.of(context)!.homeTabTV,
                AppLocalizations.of(context)!.homeTabMovie,
                AppLocalizations.of(context)!.homeTabLive,
              ],
              onTabChange: (index) {
                setState(() {
                  reverse = true;
                  tabIndex = index;
                });
              }),
          actions: [
            TVIconButton(
                onPressed: () {
                  _scaffoldKey.currentState!.openEndDrawer();
                },
                icon: const Icon(Icons.settings_outlined)),
            const SizedBox(width: 12),
            const Clock(),
            const SizedBox(width: 48),
          ],
        ),
        endDrawer: NavigatorPopHandler(
          onPop: () => _navigatorKey.currentState!.maybePop(),
          child: Container(
            width: 360,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Navigator(
              key: _navigatorKey,
              onGenerateRoute: (settings) => FadeInPageRoute(builder: (context) => const SettingsPage(), settings: settings),
            ),
          ),
        ),
        body: PageTransitionSwitcher(
          reverse: reverse,
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) => SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.transparent,
            child: child,
          ),
          child: switch (tabIndex) {
            0 => TVListPage(endDrawerNavigatorKey: _navigatorKey),
            1 => MovieListPage(endDrawerNavigatorKey: _navigatorKey),
            2 => const LiveListPage(),
            _ => const SizedBox(),
          },
        ),
      ),
    );
  }
}

class _HomeTabs extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onTabChange;

  const _HomeTabs({required this.tabs, required this.onTabChange});

  @override
  State<_HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<_HomeTabs> {
  double lineWidth = 0;
  double lineOffset = 0;
  bool tabFocused = false;
  int active = 0;
  late final tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(const Duration(milliseconds: 10)).then((_) => setState(() {
          updateActiveLine(tabKeys[active].currentContext!);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onFocusChange: (f) {
        if (tabFocused != f) {
          setState(() {
            tabFocused = f;
          });
        }
      },
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowLeft:
              if (active > 0) {
                active -= 1;
                widget.onTabChange(active);
                updateActiveLine(tabKeys[active].currentContext!);
                setState(() {});
                return KeyEventResult.handled;
              }

            case LogicalKeyboardKey.arrowRight:
              if (active < widget.tabs.length - 1) {
                active += 1;
                widget.onTabChange(active);
                updateActiveLine(tabKeys[active].currentContext!);
              } else {
                final siblings = node.parent!.children.toList();
                final index = siblings.indexOf(node);
                siblings[index + 1].requestFocus();
              }
              setState(() {});
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.tabs.indexed
                  .map((tab) => GestureDetector(
                        onTap: () {
                          active = tab.$1;
                          widget.onTabChange(active);
                          updateActiveLine(tabKeys[active].currentContext!);
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          child: Text(
                            tab.$2,
                            key: tabKeys[tab.$1],
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: tab.$1 == active && tabFocused ? Colors.white : Colors.grey),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              width: tabFocused ? lineWidth : lineWidth * 0.6,
              height: 2,
              margin: EdgeInsets.only(left: tabFocused ? lineOffset : lineOffset + lineWidth * 0.2),
              decoration: BoxDecoration(
                  color: tabFocused ? Colors.white : Colors.grey,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(2))),
            )
          ],
        ),
      ),
    );
  }

  updateActiveLine(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(Offset.zero, ancestor: box.parent?.parent?.parent?.parent);
    box.size.width;
    lineWidth = box.size.width;
    lineOffset = -offset.dx;
  }
}
