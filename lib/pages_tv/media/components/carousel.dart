import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../components/async_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../../pages/components/theme_builder.dart';
import '../../../utils/utils.dart';
import '../../components/filled_button.dart';

class Carousel extends StatelessWidget {
  const Carousel({
    super.key,
    required this.len,
    required this.index,
    required this.child,
    required this.onChange,
    this.onFocusChange,
  });

  final ValueChanged<bool>? onFocusChange;
  final ValueChanged<int> onChange;
  final int len;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (
              Widget child,
              Animation<double> primaryAnimation,
              Animation<double> secondaryAnimation,
            ) {
              return SharedAxisTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                fillColor: Colors.transparent,
                child: child,
              );
            },
            child: child,
          ),
        ),
        CarouselPagination(len: len, index: index, onChange: onChange, onFocusChange: onFocusChange),
      ],
    );
  }
}

class CarouselPlaceholder extends StatelessWidget {
  const CarouselPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4));
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerLow,
      highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 48, right: 48, top: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          spacing: 8,
                          children: List.generate(
                            5,
                            (index) => Container(width: 36, height: 12, decoration: decoration),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FractionallySizedBox(widthFactor: 0.6, child: Container(height: 42, decoration: decoration)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(width: 60, height: 12, decoration: decoration),
                            const SizedBox(width: 20),
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Container(width: 20, height: 12, decoration: decoration),
                            const SizedBox(width: 20),
                            Container(width: 36, height: 12, decoration: decoration),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 7,
                          children: List.generate(
                            4,
                            (index) => FractionallySizedBox(
                              widthFactor: Random().nextDouble() * 0.2 + 0.7,
                              child: Container(height: 12, decoration: decoration.copyWith(color: Colors.black87)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TVFilledButton.icon(
                          onPressed: null,
                          label: Text(AppLocalizations.of(context)!.buttonWatchNow),
                          icon: const Icon(Icons.play_arrow_rounded),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.width / 5 / 2 * 3,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CarouselPagination(len: 9, index: 0, onChange: (_) {}),
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
  });

  final Function(int) onChange;
  final ValueChanged<bool>? onFocusChange;
  final int len;
  final int index;

  @override
  State<CarouselPagination> createState() => _CarouselPaginationState();
}

class _CarouselPaginationState extends State<CarouselPagination> with RouteAware {
  bool _focused = false;
  final _timer = Stream.periodic(const Duration(seconds: 15));
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
      onFocusChange: (f) {
        if (_focused != f) {
          setState(() => _focused = f);
          if (widget.onFocusChange != null) widget.onFocusChange!(f);
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
            side:
                _focused
                    ? BorderSide(color: Theme.of(context).colorScheme.inverseSurface, width: 4, strokeAlign: 2)
                    : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:
                  List.generate(
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

class CarouselBackground extends StatelessWidget {
  const CarouselBackground({super.key, required this.src});

  final String? src;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: PageTransitionSwitcher(
            duration: const Duration(seconds: 2),
            layoutBuilder: (List<Widget> entries) => Stack(fit: StackFit.expand, children: entries),
            transitionBuilder: (
              Widget child,
              Animation<double> primaryAnimation,
              Animation<double> secondaryAnimation,
            ) {
              return SharedAxisTransition(
                animation: primaryAnimation.drive(CurveTween(curve: Curves.easeOut)),
                secondaryAnimation: secondaryAnimation.drive(CurveTween(curve: Curves.easeOut)),
                transitionType: SharedAxisTransitionType.horizontal,
                fillColor: Colors.transparent,
                child: child,
              );
            },
            child: Container(
              key: UniqueKey(),
              child:
                  src != null
                      ? AsyncImage(key: UniqueKey(), src!)
                      : Image.asset(switch (Theme.of(context).brightness) {
                        Brightness.dark => 'assets/tv/images/bg-pixel.webp',
                        Brightness.light => 'assets/tv/images/bg-pixel-light.webp',
                      }, repeat: ImageRepeat.repeat),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withAlpha(0xEE),
                Theme.of(context).scaffoldBackgroundColor.withAlpha(0x66),
              ],
              stops: const [0.3, 0.7],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withAlpha(0),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: const [0.7, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class CarouselItem extends StatelessWidget {
  const CarouselItem({super.key, required this.item, this.onPressed});

  final MediaRecommendation item;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      item.themeColor,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 48, right: 48, top: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.labelSmall!,
                      child: Row(
                        children:
                            item.genres
                                .map(
                                  (genre) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(genre.name, style: Theme.of(context).textTheme.labelSmall),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.displaySmall!,
                      child: Text(item.displayTitle()),
                    ),
                    const SizedBox(height: 6),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                      child: Row(
                        children: [
                          Text(item.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                          const SizedBox(width: 20),
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown),
                          const SizedBox(width: 20),
                          Text(AppLocalizations.of(context)!.seriesStatus(item.status.name)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (item.overview != null)
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(0xB3),
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        child: Text(item.overview!),
                      ),
                    const SizedBox(height: 24),
                    Focus(
                      skipTraversal: true,
                      child: TVFilledButton.icon(
                        onPressed: onPressed,
                        label: Text(AppLocalizations.of(context)!.buttonWatchNow),
                        icon: const Icon(Icons.play_arrow_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child:
                      item.poster != null
                          ? AsyncImage(
                            item.poster!,
                            width: MediaQuery.of(context).size.width / 5,
                            radius: BorderRadius.circular(6),
                          )
                          : const SizedBox(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
