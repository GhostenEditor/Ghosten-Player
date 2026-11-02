import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../previews/previews.dart';
import '../../../routers.dart';

class Carousel extends StatefulWidget {
  const Carousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onChange,
    this.autofocus = false,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onChange;
  final bool autofocus;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          Expanded(
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder:
                  (Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
                    return SharedAxisTransition(
                      animation: primaryAnimation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      fillColor: Colors.transparent,
                      child: child,
                    );
                  },
              child: widget.itemBuilder(context, _activeIndex),
            ),
          ),
          CarouselPagination(
            autofocus: widget.autofocus,
            len: widget.itemCount,
            index: _activeIndex,
            onChange: (index) {
              _activeIndex = index;
              setState(() {});
              if (widget.onChange != null) {
                widget.onChange!(index);
              }
            },
            onFocusChange: (f) {
              if (f) {
                Scrollable.ensureVisible(
                  FocusManager.instance.primaryFocus!.context!,
                  alignment: 1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class CarouselPagination extends StatefulWidget {
  const CarouselPagination({
    super.key,
    required this.onChange,
    required this.len,
    required this.index,
    this.onFocusChange,
    this.autofocus = false,
  });

  final Function(int) onChange;
  final ValueChanged<bool>? onFocusChange;
  final int len;
  final int index;
  final bool autofocus;

  @override
  State<CarouselPagination> createState() => _CarouselPaginationState();
}

class _CarouselPaginationState extends State<CarouselPagination> with RouteAware {
  bool _focused = false;
  final Stream<dynamic> _timer = Stream.periodic(const Duration(seconds: 1500));
  StreamSubscription<dynamic>? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.len > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        widget.onChange(0);
      });
    }
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void didPopNext() {
    _subscription?.resume();
  }

  @override
  void didPushNext() {
    _subscription?.pause();
  }

  @override
  void initState() {
    super.initState();
    _subscription = _timer.listen((_) {
      if (widget.index < widget.len - 1) {
        widget.onChange(widget.index + 1);
      } else {
        widget.onChange(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (f) {
        if (_focused != f) {
          if (f) {
            _subscription?.pause();
          } else {
            _subscription?.resume();
          }
          setState(() => _focused = f);
          if (widget.onFocusChange != null) {
            widget.onFocusChange!(f);
          }
        }
      },
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowLeft:
              if (widget.index > 0) {
                widget.onChange(widget.index - 1);
              } else {
                widget.onChange(widget.len - 1);
              }
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight:
              if (widget.index < widget.len - 1) {
                widget.onChange(widget.index + 1);
              } else {
                widget.onChange(0);
              }
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Center(
        child: Material(
          color: Colors.black54,
          shape: StadiumBorder(
            side: _focused
                ? BorderSide(color: Theme.of(context).colorScheme.inverseSurface, width: 3, strokeAlign: 2)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.len,
                (index) => GestureDetector(
                  onTap: () => widget.onChange(index),
                  child: AnimatedContainer(
                    width: index == widget.index ? 30 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index == widget.index ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  ),
                ),
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

@AppPreview(group: 'Carousel (TV)', size: Size(800, 300))
Widget homeAppbarPreview() {
  return Carousel(
    autofocus: true,
    itemCount: 5,
    itemBuilder: (context, index) => ColoredBox(
      color: Colors.blue[(index + 1) * 100]!,
      child: Center(child: Text(index.toString(), style: Theme.of(context).textTheme.displayLarge)),
    ),
  );
}
