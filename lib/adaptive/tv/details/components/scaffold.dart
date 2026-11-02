import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../components/components.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../menus/abstract.dart';
import '../../../../routers.dart';
import '../../../../utils/utils.dart';
import '../../components/setting_page.dart';

class DetailScaffold<T extends MediaBase> extends StatefulWidget {
  const DetailScaffold({
    super.key,
    required this.item,
    this.navigatorKey,
    required this.builder,
    this.showSide,
    this.menus,
  });

  final T item;
  final GlobalKey<NavigatorState>? navigatorKey;
  final WidgetBuilder builder;
  final ValueNotifier<bool>? showSide;
  final Menu? menus;

  @override
  State<DetailScaffold<T>> createState() => _DetailScaffoldState();
}

class _DetailScaffoldState<T extends MediaBase> extends State<DetailScaffold<T>> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _drawerNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      widget.item.themeColor,
      builder: (context) {
        return Stack(
          children: [
            if (widget.showSide != null)
              ListenableBuilder(
                listenable: widget.showSide!,
                builder: (context, _) => _buildBackground(context, widget.item, widget.showSide!.value),
              )
            else
              _buildBackground(context, widget.item, true),
            Focus(
              skipTraversal: true,
              onKeyEvent: (FocusNode node, KeyEvent event) {
                if (event is KeyDownEvent || event is KeyRepeatEvent) {
                  switch (event.logicalKey) {
                    case LogicalKeyboardKey.contextMenu:
                      if (_scaffoldKey.currentState?.isEndDrawerOpen == false) {
                        _scaffoldKey.currentState?.openEndDrawer();
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
                  if (_scaffoldKey.currentState!.isEndDrawerOpen) {
                    if (!_drawerNavigatorKey.currentState!.canPop()) {
                      _scaffoldKey.currentState!.closeEndDrawer();
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: Colors.transparent,
                  resizeToAvoidBottomInset: false,
                  endDrawer: widget.menus != null
                      ? Builder(
                          builder: (context) => Drawer(
                            child: AppNavigator(
                              navigatorKey: _drawerNavigatorKey,
                              onGenerateRoute: onGenerateRoute,
                              onUnknownRoute: (settings) => FadeInPageRoute(
                                settings: settings,
                                builder: (context) => SettingPage.list(
                                  title: Text(AppLocalizations.of(context)!.buttonMore),
                                  children: widget.menus!.buildSettingItems(context),
                                ),
                              ),
                            ),
                          ),
                        )
                      : null,
                  body: Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 20),
                          child: Builder(builder: widget.builder),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: AppNavigator(
                          navigatorKey: widget.navigatorKey,
                          routeDirectionalTraversalEdgeBehavior: .parentScope,
                          onGenerateRoute: (settings) =>
                              FadeInPageRoute(builder: (context) => const SizedBox(), settings: settings),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackground(BuildContext context, T item, bool overlay) {
    final placeholder = Image.asset(
      'assets/images/${switch (Theme.of(context).brightness) {
        Brightness.dark => 'bg-pixel.webp',
        Brightness.light => 'bg-pixel-light.webp',
      }}',
      repeat: ImageRepeat.repeat,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        if (item.backdrop != null) AsyncImage(item.backdrop!, errorWidget: (_, _, _) => placeholder) else placeholder,
        if (item.logo != null)
          Align(
            alignment: const Alignment(0.9, -0.8),
            child: AsyncImage(
              item.logo!,
              width: 160,
              height: 160,
              needLoading: false,
              fit: BoxFit.contain,
              alignment: Alignment.topRight,
              showErrorWidget: false,
            ),
          ),
        if (item.backdrop != null)
          DecoratedBox(
            decoration: overlay
                ? BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLow.withAlpha(0xEE))
                : BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.surfaceContainerLow.withAlpha(0xEE),
                        Theme.of(context).colorScheme.surfaceContainerLow.withAlpha(0xDD),
                        Theme.of(context).colorScheme.surfaceContainerLow.withAlpha(0xAA),
                        Theme.of(context).colorScheme.surfaceContainerLow.withAlpha(0x66),
                      ],
                      stops: const [0.3, 0.5, 0.7, 0.8],
                    ),
                  ),
          )
        else
          ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerLow.withAlpha(0xAA)),
      ],
    );
  }
}
