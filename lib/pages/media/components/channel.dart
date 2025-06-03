import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../components/error_message.dart';
import '../../../components/future_builder_handler.dart';
import '../../../components/no_data.dart';
import '../../../components/placeholder.dart';
import '../../../components/scrollbar.dart';
import '../../components/loading.dart';
import '../../components/theme_builder.dart';
import 'carousel.dart';

class MediaCarousel<S> extends StatefulWidget {
  const MediaCarousel({
    super.key,
    required this.onChanged,
    required this.noDataBuilder,
    required this.itemBuilder,
    required this.count,
  });

  final int count;
  final ValueChanged<int> onChanged;
  final WidgetBuilder noDataBuilder;
  final NullableIndexedWidgetBuilder itemBuilder;

  @override
  State<MediaCarousel<S>> createState() => _MediaCarouselState<S>();
}

class _MediaCarouselState<S> extends State<MediaCarousel<S>> {
  final _carouselIndex = ValueNotifier<int?>(null);

  @override
  void dispose() {
    _carouselIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count > 0) Future.microtask(() => widget.onChanged(0));

    return widget.count != 0
        ? SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = max(min(constraints.maxWidth / 1.8, 300.0), 200.0);
              return ConstrainedBox(
                constraints: constraints.copyWith(maxHeight: height, minHeight: height),
                child: ListenableBuilder(
                  listenable: _carouselIndex,
                  builder: (context, _) {
                    return Carousel(
                      index: _carouselIndex.value ?? 0,
                      count: widget.count,
                      onChange: (index) {
                        widget.onChanged(index);
                        _carouselIndex.value = index;
                      },
                      itemBuilder: widget.itemBuilder,
                    );
                  },
                ),
              );
            },
          ),
        )
        : SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: NoData(action: widget.noDataBuilder(context))),
        );
  }
}

class MediaChannel<T> extends StatelessWidget {
  const MediaChannel({
    super.key,
    required this.label,
    required this.height,
    required this.builder,
    this.more,
    required this.future,
    this.loadingBuilder,
  });

  final Future<List<T>> future;
  final String label;
  final double height;
  final Widget? more;
  final Widget Function(BuildContext, T, int) builder;
  final Widget Function(BuildContext)? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilderSliverHandler(
      future: future,
      errorBuilder: (context, snapshot) => SizedBox(height: height, child: ErrorMessage(error: snapshot.error)),
      loadingBuilder:
          loadingBuilder != null
              ? (context, snapshot) =>
                  MediaChannelPlaceholder(label: label, height: height, itemBuilder: loadingBuilder!)
              : null,
      builder: (context, snapshot) {
        return snapshot.requireData.isNotEmpty
            ? SliverMainAxisGroup(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(label, style: Theme.of(context).textTheme.titleMedium), if (more != null) more!],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: height,
                    child: ScrollbarListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      itemCount: snapshot.requireData.length,
                      itemBuilder: (context, index) => builder(context, snapshot.requireData[index], index),
                      separatorBuilder: (context, _) => const SizedBox(width: 16),
                    ),
                  ),
                ),
              ],
            )
            : const SliverToBoxAdapter();
      },
    );
  }
}

class MediaChannelPlaceholder extends StatelessWidget {
  const MediaChannelPlaceholder({super.key, required this.height, required this.itemBuilder, required this.label});

  final Widget Function(BuildContext) itemBuilder;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: GPlaceholder(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(width: 100, height: 24, decoration: GPlaceholderDecoration.lite),
            ),
            SizedBox(
              height: height,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, _) => itemBuilder(context),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaGridChannel<T> extends StatefulWidget {
  const MediaGridChannel({super.key, required this.label, required this.itemBuilder, required this.onQuery});

  final String label;
  final ItemWidgetBuilder<T> itemBuilder;
  final Future<PageData<T>> Function(int) onQuery;

  @override
  State<MediaGridChannel<T>> createState() => _MediaGridChannelState();
}

class _MediaGridChannelState<T> extends State<MediaGridChannel<T>> {
  PagingState<int, T> _state = PagingState();
  int? _count;

  Future<void> _fetchNextPage() async {
    if (_state.isLoading) return;

    await Future.value();

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final newKey = (_state.keys?.last ?? -1) + 1;
      final data = await widget.onQuery(newKey);
      final hasNextPage = data.offset + data.limit < data.count;
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
          pages: [...?_state.pages, data.data],
          keys: [...?_state.keys, newKey],
          hasNextPage: hasNextPage,
          isLoading: false,
        );
        _count = data.count;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(error: error, isLoading: false);
      });
    }
  }

  @override
  void didUpdateWidget(covariant MediaGridChannel<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers:
          _count != 0
              ? [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child:
                        _count != null
                            ? Row(
                              children: [
                                Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
                                if (_count != null) Text(' ($_count)', style: Theme.of(context).textTheme.labelSmall),
                              ],
                            )
                            : GPlaceholder(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(width: 100, height: 24, decoration: GPlaceholderDecoration.base),
                              ),
                            ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: PagedSliverGrid(
                    builderDelegate: PagedChildBuilderDelegate<T>(
                      itemBuilder: widget.itemBuilder,
                      noMoreItemsIndicatorBuilder:
                          (context) => const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Column(
                              spacing: 16,
                              children: [
                                FractionallySizedBox(widthFactor: 0.5, child: Divider()),
                                Text(
                                  'THE END',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      firstPageProgressIndicatorBuilder: (context) => const Loading(),
                      newPageProgressIndicatorBuilder:
                          (context) => const Padding(padding: EdgeInsets.only(top: 16), child: Loading()),
                    ),
                    showNewPageProgressIndicatorAsGridChild: false,
                    showNoMoreItemsIndicatorAsGridChild: false,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 120,
                      childAspectRatio: 0.5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    fetchNextPage: _fetchNextPage,
                    state: _state,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ]
              : [],
    );
  }
}

class MediaBadges<T extends Media> extends StatelessWidget {
  const MediaBadges({super.key, required this.item});

  final T item;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ThemeBuilder(
        item.themeColor,
        builder: (context) {
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
        },
      ),
    );
  }
}
