import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class UnpinnedAppBar extends StatefulWidget implements PreferredSizeWidget {
  const UnpinnedAppBar({super.key, required this.appbar, this.unpinned = true});

  final PreferredSizeWidget appbar;
  final bool unpinned;

  @override
  State<UnpinnedAppBar> createState() => _UnpinnedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _UnpinnedAppBarState extends State<UnpinnedAppBar> {
  bool _show = true;
  ScrollNotificationObserverState? _scrollNotificationObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.unpinned) {
      _scrollNotificationObserver?.removeListener(_handleScrollNotification);
      final ScaffoldState? scaffoldState = Scaffold.maybeOf(context);

      if (scaffoldState != null && (scaffoldState.isDrawerOpen || scaffoldState.isEndDrawerOpen)) {
        return;
      }
      _scrollNotificationObserver = ScrollNotificationObserver.maybeOf(context);
      _scrollNotificationObserver?.addListener(_handleScrollNotification);
    }
  }

  @override
  void dispose() {
    if (_scrollNotificationObserver != null) {
      _scrollNotificationObserver!.removeListener(_handleScrollNotification);
      _scrollNotificationObserver = null;
    }
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification && !Scaffold.of(context).isEndDrawerOpen) {
      final bool oldShow = _show;
      final ScrollMetrics metrics = notification.metrics;
      switch (metrics.axisDirection) {
        case AxisDirection.up:
        case AxisDirection.down:
          _show = metrics.extentBefore < 100;
        case AxisDirection.right:
        case AxisDirection.left:
          break;
      }
      if (_show != oldShow) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.unpinned
        ? PageTransitionSwitcher(
            reverse: _show,
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.vertical,
                fillColor: Colors.transparent,
                child: child,
              );
            },
            child: _show
                ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: switch (Theme.of(context).brightness) {
                          Brightness.dark => [Colors.black38, Colors.transparent],
                          Brightness.light => [Colors.white38, Colors.white.withAlpha(0)],
                        },
                        begin: .topCenter,
                        end: .bottomCenter,
                      ),
                    ),
                    child: widget.appbar,
                  )
                : AppBar(forceMaterialTransparency: true, actions: const [SizedBox()]),
          )
        : widget.appbar;
  }
}
