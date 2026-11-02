import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'aspect_ratio_grid_theme.dart';
import 'headered_content.dart';
import 'loading.dart';
import 'media_card_theme.dart';

class AspectRatioSliverGrid<T> extends StatefulWidget {
  const AspectRatioSliverGrid({
    super.key,
    required this.itemBuilder,
    required this.onQuery,
    this.cardStyle,
    this.header,
    this.headerPadding = .zero,
    this.contentPadding = .zero,
  });

  final Widget Function(BuildContext, T, Size) itemBuilder;
  final Future<PageData<T>> Function(int) onQuery;
  final MediaCardThemeData? cardStyle;
  final Widget? header;
  final EdgeInsets headerPadding;
  final EdgeInsets contentPadding;

  @override
  State<AspectRatioSliverGrid<T>> createState() => _AspectRatioSliverGridState<T>();
}

class _AspectRatioSliverGridState<T> extends State<AspectRatioSliverGrid<T>> {
  Widget? _cachedChild;
  Size _size = .zero;
  PagingState<int, T> _state = PagingState();

  @override
  Widget build(BuildContext context) {
    final AspectRatioGridThemeData theme = AspectRatioGridTheme.of(context);
    final double crossAxisSpacing = theme.crossAxisSpacing ?? 0;
    final double mainAxisSpacing = theme.mainAxisSpacing ?? 0;
    final double itemMinWidth = widget.cardStyle?.minWidth ?? 100;
    final double aspectRatio = widget.cardStyle?.aspectRatio ?? 1;
    final double heightExtent = widget.cardStyle?.heightExtent ?? 0;
    return SliverHeaderedContent(
      header: widget.header,
      headerPadding: widget.headerPadding,
      sliver: SliverPadding(
        padding: widget.contentPadding.add(const EdgeInsets.only(bottom: 32)),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.crossAxisExtent;
            final int crossAxisCount = max(((width + crossAxisSpacing) / (itemMinWidth + crossAxisSpacing)).floor(), 1);
            final double fixedWidth = (width - crossAxisSpacing * (crossAxisCount - 1)) / crossAxisCount;
            final double fixedHeight = fixedWidth / aspectRatio;
            final fixedSize = Size(fixedWidth, fixedHeight);
            if (_size != fixedSize) {
              _size = Size(fixedWidth, fixedHeight);
              _cachedChild = PagedSliverGrid(
                builderDelegate: PagedChildBuilderDelegate<T>(
                  itemBuilder: (context, item, _) => widget.itemBuilder(context, item, _size),
                  noMoreItemsIndicatorBuilder: (context) => const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Column(
                      spacing: 16,
                      children: [
                        FractionallySizedBox(widthFactor: 0.5, child: Divider()),
                        Text(
                          'THE END',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  firstPageProgressIndicatorBuilder: (context) => const Loading(),
                  newPageProgressIndicatorBuilder: (context) =>
                      const Padding(padding: EdgeInsets.only(top: 16), child: Loading()),
                ),
                showNewPageProgressIndicatorAsGridChild: false,
                showNoMoreItemsIndicatorAsGridChild: false,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: _size.height + heightExtent,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                ),
                fetchNextPage: _fetchNextPage,
                state: _state,
              );
            }

            return _cachedChild ?? const SliverToBoxAdapter();
          },
        ),
      ),
    );
  }

  Future<void> _fetchNextPage() async {
    if (_state.isLoading) {
      return;
    }

    await Future.value();

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final int newKey = (_state.keys?.last ?? -1) + 1;
      final PageData<T> data = await widget.onQuery(newKey);
      final hasNextPage = data.data.length == data.limit;
      if (!mounted) {
        return;
      }
      setState(() {
        _size = .zero;
        _state = _state.copyWith(
          pages: [...?_state.pages, data.data],
          keys: [...?_state.keys, newKey],
          hasNextPage: hasNextPage,
          isLoading: false,
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _size = .zero;
        _state = _state.copyWith(error: error, isLoading: false);
      });
    }
  }
}

class AspectRatioSliverGrid2<T> extends StatefulWidget {
  const AspectRatioSliverGrid2({
    super.key,
    required this.itemBuilder,
    this.cardStyle,
    this.header,
    this.headerPadding = .zero,
    this.contentPadding = .zero,
    required this.fetchNextPage,
    required this.state,
  });

  final NextPageCallback fetchNextPage;
  final PagingState<int, T> state;
  final Widget Function(BuildContext, T, Size) itemBuilder;
  final MediaCardThemeData? cardStyle;
  final Widget? header;
  final EdgeInsets headerPadding;
  final EdgeInsets contentPadding;

  @override
  State<AspectRatioSliverGrid2<T>> createState() => _AspectRatioSliverGrid2State();
}

class _AspectRatioSliverGrid2State<T> extends State<AspectRatioSliverGrid2<T>> {
  Widget? _cachedChild;
  Size _size = .zero;

  @override
  void didUpdateWidget(covariant AspectRatioSliverGrid2<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      setState(() => _size = .zero);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AspectRatioGridThemeData theme = AspectRatioGridTheme.of(context);
    final double crossAxisSpacing = theme.crossAxisSpacing ?? 0;
    final double mainAxisSpacing = theme.mainAxisSpacing ?? 0;
    final double itemMinWidth = widget.cardStyle?.minWidth ?? 100;
    final double aspectRatio = widget.cardStyle?.aspectRatio ?? 1;
    final double heightExtent = widget.cardStyle?.heightExtent ?? 0;
    return SliverHeaderedContent(
      header: widget.header,
      headerPadding: widget.headerPadding,
      sliver: SliverPadding(
        padding: widget.contentPadding.add(const EdgeInsets.only(bottom: 32)),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.crossAxisExtent;
            final int crossAxisCount = max(((width + crossAxisSpacing) / (itemMinWidth + crossAxisSpacing)).floor(), 1);
            final double fixedWidth = (width - crossAxisSpacing * (crossAxisCount - 1)) / crossAxisCount;
            final double fixedHeight = fixedWidth / aspectRatio;
            final fixedSize = Size(fixedWidth, fixedHeight);
            if (_size != fixedSize) {
              _size = Size(fixedWidth, fixedHeight);
              _cachedChild = PagedSliverGrid(
                builderDelegate: PagedChildBuilderDelegate<T>(
                  itemBuilder: (context, item, _) => widget.itemBuilder(context, item, _size),
                  noMoreItemsIndicatorBuilder: (context) => const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Column(
                      spacing: 16,
                      children: [
                        FractionallySizedBox(widthFactor: 0.5, child: Divider()),
                        Text(
                          'THE END',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  firstPageProgressIndicatorBuilder: (context) => const Loading(),
                  newPageProgressIndicatorBuilder: (context) =>
                      const Padding(padding: EdgeInsets.only(top: 16), child: Loading()),
                ),
                showNewPageProgressIndicatorAsGridChild: false,
                showNoMoreItemsIndicatorAsGridChild: false,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: _size.height + heightExtent,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                ),
                fetchNextPage: widget.fetchNextPage,
                state: widget.state,
              );
            }

            return _cachedChild ?? const SliverToBoxAdapter();
          },
        ),
      ),
    );
  }
}
