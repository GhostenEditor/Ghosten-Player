import 'dart:async';

import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/async_image.dart';
import '../../../utils/utils.dart';
import '../../components/filled_button.dart';

class Carousel extends StatelessWidget {
  final ValueChanged<bool>? onFocusChange;
  final ValueChanged<int> onChange;
  final int len;
  final int index;
  final Widget child;

  const Carousel({
    super.key,
    required this.len,
    required this.index,
    required this.child,
    required this.onChange,
    this.onFocusChange,
  });

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
        CarouselPagination(
          len: len,
          index: index,
          onChange: onChange,
          onFocusChange: onFocusChange,
        ),
      ],
    );
  }
}

class CarouselPagination extends StatefulWidget {
  final Function(int) onChange;
  final ValueChanged<bool>? onFocusChange;
  final int len;
  final int index;

  const CarouselPagination({
    super.key,
    required this.onChange,
    required this.len,
    required this.index,
    this.onFocusChange,
  });

  @override
  State<CarouselPagination> createState() => _CarouselPaginationState();
}

class _CarouselPaginationState extends State<CarouselPagination> with RouteAware {
  bool focused = false;
  final timer = Stream.periodic(const Duration(seconds: 15));
  StreamSubscription<dynamic>? subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    subscription?.cancel();
    super.dispose();
  }

  @override
  void didPopNext() {
    subscription?.resume();
  }

  @override
  void didPushNext() {
    subscription?.pause();
  }

  @override
  void initState() {
    super.initState();
    subscription = timer.listen((_) {
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
        if (focused != f) {
          setState(() => focused = f);
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
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: focused ? Colors.white : Colors.transparent, width: 4),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.len, (index) {
              return GestureDetector(
                onTap: () {
                  widget.onChange(index);
                },
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
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class CarouselBackground extends StatelessWidget {
  final String? src;

  const CarouselBackground({super.key, required this.src});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageTransitionSwitcher(
          duration: const Duration(seconds: 2),
          layoutBuilder: (List<Widget> entries) => Stack(
            fit: StackFit.expand,
            children: entries,
          ),
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
            child: src != null
                ? AsyncImage(key: UniqueKey(), src!, fit: BoxFit.cover)
                : Image.asset(
                    'assets/images/bg-pixel.webp',
                    repeat: ImageRepeat.repeat,
                  ),
          ),
        ),
        DecoratedBox(
            decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withAlpha(0xee),
              Colors.black.withAlpha(0x66),
            ],
            stops: const [0.3, 0.7],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        )),
        const DecoratedBox(
            decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent,
            Color(0xFF000000),
          ], stops: [
            0.7,
            1
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        )),
      ],
    );
  }
}

class CarouselItem extends StatelessWidget {
  final MediaRecommendation item;
  final VoidCallback? onPressed;

  const CarouselItem({super.key, required this.item, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: item.themeColor == null ? null : ColorScheme.fromSeed(seedColor: Color(item.themeColor!), brightness: Theme.of(context).brightness),
      ),
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
                  DefaultTextStyle(
                      style: Theme.of(context).textTheme.labelSmall!,
                      child: Row(
                          children: item.genres
                              .map((genre) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(genre.name, style: Theme.of(context).textTheme.labelSmall),
                                  ))
                              .toList())),
                  const SizedBox(height: 6),
                  DefaultTextStyle(style: Theme.of(context).textTheme.displaySmall!, child: Text(item.displayTitle())),
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
                      )),
                  const SizedBox(height: 18),
                  if (item.overview != null)
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      child: Text(item.overview!),
                    ),
                  const SizedBox(height: 24),
                  Focus(
                    skipTraversal: true,
                    child: TVFilledButton.icon(
                        onPressed: onPressed, label: Text(AppLocalizations.of(context)!.buttonWatchNow), icon: const Icon(Icons.play_arrow_rounded)),
                  ),
                ],
              ),
            ),
            Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: item.poster != null
                      ? AsyncImage(
                          item.poster!,
                          width: MediaQuery.of(context).size.width / 5,
                          radius: BorderRadius.circular(6),
                        )
                      : const SizedBox(),
                )),
          ],
        ),
      ),
    );
  }
}
