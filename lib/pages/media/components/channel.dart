import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/no_data.dart';
import '../../../components/scrollbar.dart';
import '../../components/theme_builder.dart';
import 'carousel.dart';

class MediaCarousel<B extends StateStreamable<S>, S> extends StatefulWidget {
  const MediaCarousel({
    super.key,
    required this.onChanged,
    required this.noDataBuilder,
    required this.selector,
    required this.itemBuilder,
  });

  final ValueChanged<int> onChanged;
  final WidgetBuilder noDataBuilder;
  final NullableIndexedWidgetBuilder itemBuilder;
  final BlocWidgetSelector<S?, int?> selector;

  @override
  State<MediaCarousel<B, S>> createState() => _MediaCarouselState<B, S>();
}

class _MediaCarouselState<B extends StateStreamable<S>, S> extends State<MediaCarousel<B, S>> {
  final _carouselIndex = ValueNotifier<int?>(null);

  @override
  void dispose() {
    _carouselIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<B, S, int?>(
        selector: widget.selector,
        builder: (context, count) {
          if (count != null && count > 0) Future.microtask(() => widget.onChanged(0));

          return count != 0
              ? SliverToBoxAdapter(
                  child: LayoutBuilder(builder: (context, constraints) {
                    final height = max(min(constraints.maxWidth / 1.8, 300.0), 200.0);
                    return ConstrainedBox(
                      constraints: constraints.copyWith(
                        maxHeight: height,
                        minHeight: height,
                      ),
                      child: ListenableBuilder(
                          listenable: _carouselIndex,
                          builder: (context, _) {
                            return count != null
                                ? Carousel(
                                    index: _carouselIndex.value ?? 0,
                                    count: count,
                                    onChange: (index) {
                                      widget.onChanged(index);
                                      _carouselIndex.value = index;
                                    },
                                    itemBuilder: widget.itemBuilder,
                                  )
                                : const SizedBox();
                          }),
                    );
                  }),
                )
              : SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: NoData(action: widget.noDataBuilder(context))),
                );
        });
  }
}

class MediaChannel<B extends StateStreamable<S>, S> extends StatelessWidget {
  const MediaChannel({
    super.key,
    required this.label,
    required this.height,
    required this.builder,
    required this.selector,
    this.more,
  });

  final String label;
  final double height;
  final Widget? more;
  final Widget Function(BuildContext, int) builder;
  final BlocWidgetSelector<S?, int> selector;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<B, S, int>(
        selector: selector,
        builder: (context, count) {
          return count != 0
              ? SliverMainAxisGroup(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(label, style: Theme.of(context).textTheme.titleMedium),
                          if (more != null) more!,
                        ],
                      )),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: height,
                        child: ScrollbarListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          itemCount: count,
                          itemBuilder: (context, index) => builder(context, index),
                          separatorBuilder: (context, _) => const SizedBox(width: 16),
                        ),
                      ),
                    ),
                  ],
                )
              : const SliverToBoxAdapter();
        });
  }
}

class MediaGridChannel<B extends StateStreamable<S>, S> extends StatelessWidget {
  const MediaGridChannel({
    super.key,
    required this.label,
    required this.builder,
    required this.selector,
  });

  final String label;
  final Widget Function(BuildContext, int) builder;
  final BlocWidgetSelector<S?, int> selector;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<B, S, int>(
      selector: selector,
      builder: (context, count) => SliverMainAxisGroup(
        slivers: count != 0
            ? [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(label, style: Theme.of(context).textTheme.titleMedium),
                        Text(' ($count)', style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid.builder(
                    itemCount: count,
                    addAutomaticKeepAlives: false,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 120,
                      childAspectRatio: 0.5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) => builder(context, index),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ]
            : [],
      ),
    );
  }
}

class MediaBadges<T extends Media> extends StatelessWidget {
  const MediaBadges({super.key, required this.item});

  final T item;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ThemeBuilder(item.themeColor, builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 4,
            children: [
              if (item.favorite)
                Material(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.favorite_border_rounded, color: Colors.white, size: 12),
                  ),
                ),
              if (item.watched)
                Material(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 12),
                  ),
                ),
              if (item.voteAverage != null && item.voteAverage != 0)
                Material(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const StadiumBorder(),
                  child: Badge(
                    label: Text(item.voteAverage!.toStringAsFixed(1)),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
