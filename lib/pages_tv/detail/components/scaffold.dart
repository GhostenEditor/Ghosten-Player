import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components/async_image.dart';
import '../../utils/utils.dart';

class DetailScaffold<T extends MediaBase> extends StatefulWidget {
  final T item;
  final Key? navigatorKey;
  final Key? scaffoldKey;
  final Key? drawerNavigatorKey;
  final Widget child;
  final Widget? endDrawer;
  final ValueNotifier<bool>? showSide;

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

  @override
  State<DetailScaffold<T>> createState() => _DetailScaffoldState();
}

class _DetailScaffoldState<T extends MediaBase> extends State<DetailScaffold<T>> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.showSide != null
            ? ListenableBuilder(listenable: widget.showSide!, builder: (context, _) => _buildBackground(context, widget.item, widget.showSide!.value))
            : _buildBackground(context, widget.item, true),
        Theme(
          data: Theme.of(context).copyWith(
            colorScheme: widget.item.themeColor == null
                ? null
                : ColorScheme.fromSeed(seedColor: Color(widget.item.themeColor!), brightness: Theme.of(context).brightness),
          ),
          child: Focus(
            skipTraversal: true,
            onKeyEvent: (FocusNode node, KeyEvent event) {
              if (event is KeyDownEvent || event is KeyRepeatEvent) {
                switch (event.logicalKey) {
                  case LogicalKeyboardKey.contextMenu:
                    if (widget.scaffoldKey is GlobalKey<ScaffoldState>) {
                      final k = widget.scaffoldKey as GlobalKey<ScaffoldState>;
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
              endDrawer: widget.endDrawer != null
                  ? Builder(
                      builder: (context) => Container(
                            width: 360,
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            child: Navigator(
                                key: widget.drawerNavigatorKey, onGenerateRoute: (settings) => FadeInPageRoute(builder: (context) => widget.endDrawer!)),
                          ))
                  : null,
              body: Row(
                children: [
                  Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 32, right: 32, top: 32, bottom: 20),
                        child: widget.child,
                      )),
                  Flexible(
                      flex: 3,
                      child: Actions(
                        actions: {
                          DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(onInvoke: (indent) {
                            final currentNode = FocusManager.instance.primaryFocus;
                            if (currentNode != null) {
                              final nearestScope = currentNode.nearestScope!;
                              final focusedChild = nearestScope.focusedChild;
                              if (focusedChild == null || focusedChild.focusInDirection(indent.direction) != true) {
                                switch (indent.direction) {
                                  case TraversalDirection.left:
                                    nearestScope.parent?.focusInDirection(indent.direction);
                                  default:
                                }
                              }
                            }
                            return null;
                          }),
                        },
                        child: Navigator(
                          key: widget.navigatorKey,
                          requestFocus: false,
                          onGenerateRoute: (settings) => FadeInPageRoute(builder: (context) => const SizedBox(), settings: settings),
                        ),
                      )),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBackground<T extends MediaBase>(BuildContext context, T item, bool overlay) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (item.backdrop != null)
          AsyncImage(item.backdrop!)
        else
          Image.asset(
            'assets/images/bg-pixel.webp',
            repeat: ImageRepeat.repeat,
          ),
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
        overlay
            ? item.backdrop != null
                ? const DecoratedBox(decoration: BoxDecoration(color: Colors.black87))
                : const DecoratedBox(decoration: BoxDecoration(color: Color(0xAA000000)))
            : DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.backdrop != null ? const Color(0xEE000000) : const Color(0xAA000000),
                      const Color(0x66000000),
                    ],
                    stops: const [0.3, 0.7],
                  ),
                ),
              ),
      ],
    );
  }
}
