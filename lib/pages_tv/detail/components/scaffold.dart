import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components/async_image.dart';
import '../../../pages/components/theme_builder.dart';
import '../../utils/utils.dart';

class DetailScaffold<T extends MediaBase> extends StatefulWidget {
  const DetailScaffold({
    super.key,
    required this.item,
    this.navigatorKey,
    required this.child,
    this.endDrawer,
    this.scaffoldKey,
    this.showSide,
    this.drawerNavigatorKey,
  });

  final T item;
  final Key? navigatorKey;
  final Key? scaffoldKey;
  final Key? drawerNavigatorKey;
  final Widget child;
  final Widget? endDrawer;
  final ValueNotifier<bool>? showSide;

  @override
  State<DetailScaffold<T>> createState() => _DetailScaffoldState();
}

class _DetailScaffoldState<T extends MediaBase> extends State<DetailScaffold<T>> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.showSide != null)
          ListenableBuilder(
            listenable: widget.showSide!,
            builder: (context, _) => _buildBackground(context, widget.item, widget.showSide!.value),
          )
        else
          _buildBackground(context, widget.item, true),
        ThemeBuilder(
          widget.item.themeColor,
          builder: (context) {
            return Focus(
              skipTraversal: true,
              onKeyEvent: (FocusNode node, KeyEvent event) {
                if (event is KeyDownEvent || event is KeyRepeatEvent) {
                  switch (event.logicalKey) {
                    case LogicalKeyboardKey.contextMenu:
                      if (widget.scaffoldKey is GlobalKey<ScaffoldState>) {
                        final k = widget.scaffoldKey! as GlobalKey<ScaffoldState>;
                        if (k.currentState?.isEndDrawerOpen == false) {
                          k.currentState?.openEndDrawer();
                          return KeyEventResult.handled;
                        }
                      }
                  }
                }
                return KeyEventResult.ignored;
              },
              child: Scaffold(
                key: widget.scaffoldKey,
                backgroundColor: Colors.transparent,
                endDrawer:
                    widget.endDrawer != null
                        ? Builder(
                          builder:
                              (context) => Container(
                                width: 360,
                                color: Theme.of(context).colorScheme.surfaceContainerLow,
                                child: Navigator(
                                  key: widget.drawerNavigatorKey,
                                  onGenerateRoute:
                                      (settings) => FadeInPageRoute(builder: (context) => widget.endDrawer!),
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
                        child: widget.child,
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Actions(
                        actions: {
                          DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
                            onInvoke: (indent) {
                              final currentNode = FocusManager.instance.primaryFocus;
                              if (currentNode != null) {
                                final nearestScope = currentNode.nearestScope!;
                                final focusedChild = nearestScope.focusedChild;
                                if (focusedChild == null || !focusedChild.focusInDirection(indent.direction)) {
                                  switch (indent.direction) {
                                    case TraversalDirection.left:
                                      nearestScope.parent?.focusInDirection(indent.direction);
                                    default:
                                  }
                                }
                              }
                              return null;
                            },
                          ),
                        },
                        child: Navigator(
                          key: widget.navigatorKey,
                          requestFocus: false,
                          onGenerateRoute:
                              (settings) => FadeInPageRoute(builder: (context) => const SizedBox(), settings: settings),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBackground(BuildContext context, T item, bool overlay) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (item.backdrop != null)
          AsyncImage(item.backdrop!)
        else
          Image.asset(switch (Theme.of(context).brightness) {
            Brightness.dark => 'assets/tv/images/bg-pixel.webp',
            Brightness.light => 'assets/tv/images/bg-pixel-light.webp',
          }, repeat: ImageRepeat.repeat),
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
            ),
          ),
        DecoratedBox(
          decoration:
              overlay
                  ? BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor.withAlpha(item.backdrop != null ? 0xDD : 0xAA),
                  )
                  : BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).scaffoldBackgroundColor.withAlpha(item.backdrop != null ? 0xEE : 0xAA),
                        Theme.of(context).scaffoldBackgroundColor.withAlpha(0x66),
                      ],
                      stops: const [0.3, 0.8],
                    ),
                  ),
        ),
      ],
    );
  }
}
