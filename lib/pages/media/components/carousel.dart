import 'dart:math';

import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../components/async_image.dart';
import '../../../components/placeholder.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';

class Carousel extends StatefulWidget {
  const Carousel({
    super.key,
    required this.count,
    required this.index,
    required this.onChange,
    this.onFocusChange,
    required this.itemBuilder,
  });

  final ValueChanged<bool>? onFocusChange;
  final ValueChanged<int> onChange;
  final int count;
  final int index;
  final NullableIndexedWidgetBuilder itemBuilder;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late final _controller = PageController(initialPage: widget.index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.count,
            itemBuilder: widget.itemBuilder,
            onPageChanged: widget.onChange,
          ),
        ),
        SmoothPageIndicator(
          controller: _controller,
          count: widget.count,
          effect: switch (Theme.of(context).brightness) {
            Brightness.dark => const WormEffect(
              dotWidth: 6,
              dotHeight: 6,
              spacing: 6,
              dotColor: Colors.white38,
              activeDotColor: Colors.white,
            ),
            Brightness.light => const WormEffect(
              dotWidth: 6,
              dotHeight: 6,
              spacing: 6,
              dotColor: Colors.black38,
              activeDotColor: Colors.black,
            ),
          },
        ),
      ],
    );
  }
}

class CarouselPlaceholder extends StatelessWidget {
  const CarouselPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final imageHeight = max(min(MediaQuery.of(context).size.width / 4, 240.0), 140.0);
    final imageWidth = imageHeight * 0.667;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = max(min(constraints.maxWidth / 1.8, 300.0), 200.0);
        return SizedBox(
          height: height,
          child: GPlaceholder(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: MediaQuery.of(context).size.width / 30,
                          children: [
                            GPlaceholderImage(width: imageWidth, height: imageHeight),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    spacing: 4,
                                    children: List.generate(
                                      5,
                                      (index) =>
                                          Container(width: 24, height: 12, decoration: GPlaceholderDecoration.base),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  FractionallySizedBox(
                                    widthFactor: 0.6,
                                    child: Container(height: 20, decoration: GPlaceholderDecoration.base),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(width: 40, height: 12, decoration: GPlaceholderDecoration.base),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.star, color: Colors.amber, size: 14),
                                      const SizedBox(width: 4),
                                      Container(width: 20, height: 12, decoration: GPlaceholderDecoration.base),
                                      const SizedBox(width: 12),
                                      Container(width: 36, height: 12, decoration: GPlaceholderDecoration.base),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: List.generate(
                                      4,
                                      (index) => FractionallySizedBox(
                                        widthFactor: Random().nextDouble() * 0.2 + 0.7,
                                        child: const GPlaceholderRect(height: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SmoothIndicator(
                  offset: 0,
                  count: 9,
                  size: const Size(6, 6),
                  effect: switch (Theme.of(context).brightness) {
                    Brightness.dark => const WormEffect(
                      dotWidth: 6,
                      dotHeight: 6,
                      spacing: 6,
                      dotColor: Colors.white38,
                      activeDotColor: Colors.white,
                    ),
                    Brightness.light => const WormEffect(
                      dotWidth: 6,
                      dotHeight: 6,
                      spacing: 6,
                      dotColor: Colors.black38,
                      activeDotColor: Colors.black,
                    ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CarouselItem extends StatelessWidget {
  const CarouselItem({super.key, required this.item, this.onPressed});

  final MediaRecommendation item;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final imageHeight = max(min(MediaQuery.of(context).size.width / 4, 240.0), 140.0);
    final imageWidth = imageHeight * 0.667;
    return GestureDetector(
      onTap: onPressed,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: MediaQuery.of(context).size.width / 30,
              children: [
                if (item.poster != null)
                  AsyncImage(item.poster!, width: imageWidth, height: imageHeight, radius: BorderRadius.circular(6))
                else
                  const SizedBox(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: [
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.labelSmall!,
                        overflow: TextOverflow.ellipsis,
                        child: Text.rich(
                          TextSpan(
                            children:
                                item.genres
                                    .map(
                                      (genre) => TextSpan(
                                        text: '${genre.name} ',
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.titleMedium!,
                        overflow: TextOverflow.ellipsis,
                        child: Text(item.displayTitle()),
                      ),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: item.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                              const WidgetSpan(child: SizedBox(width: 20)),
                              const WidgetSpan(child: Icon(Icons.star, color: Colors.amber, size: 14)),
                              const WidgetSpan(child: SizedBox(width: 4)),
                              TextSpan(
                                text: item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown,
                              ),
                              const WidgetSpan(child: SizedBox(width: 20)),
                              TextSpan(text: AppLocalizations.of(context)!.seriesStatus(item.status.name)),
                            ],
                          ),
                        ),
                      ),
                      if (item.overview != null)
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(0xB3),
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          child: Text(item.overview!),
                        ),
                    ],
                  ),
                ),
              ],
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
          child: Material(
            clipBehavior: Clip.hardEdge,
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
              child: src != null ? AsyncImage(key: ValueKey(src), src!) : const SizedBox(),
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
                Theme.of(context).scaffoldBackgroundColor.withAlpha(0x66),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: const [0.3, 1.2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
