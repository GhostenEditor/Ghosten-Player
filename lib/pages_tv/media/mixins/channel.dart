import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shimmer/shimmer.dart';

import '../../../components/placeholder.dart';
import '../../components/future_builder_handler.dart';
import '../../components/loading.dart';

class MediaChannel<T> extends StatelessWidget {
  const MediaChannel({
    super.key,
    required this.label,
    required this.height,
    required this.builder,
    required this.future,
    this.loadingBuilder,
    this.itemExtent,
  });

  final double? itemExtent;
  final String label;
  final double height;
  final Widget Function(BuildContext, T) builder;
  final Widget Function(BuildContext)? loadingBuilder;
  final Future<List<T>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilderSliverHandler(
      future: future,
      loadingBuilder:
          loadingBuilder != null
              ? (context, snapshot) => Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.surfaceContainerLow,
                highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: IgnorePointer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const GPlaceholderRect(
                        width: 100,
                        height: 18,
                        padding: EdgeInsets.only(left: 48, right: 48, top: 12),
                      ),
                      SizedBox(
                        height: height,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemExtent: itemExtent,
                          padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 12),
                          itemCount: 6,
                          itemBuilder: (context, index) => loadingBuilder!(context),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : null,
      builder:
          (context, snapshot) => SliverToBoxAdapter(
            child:
                snapshot.requireData.isNotEmpty
                    ? Actions(
                      actions: {
                        DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
                          onInvoke: (indent) {
                            final currentNode = FocusManager.instance.primaryFocus;
                            if (currentNode != null) {
                              final nearestScope = currentNode.nearestScope!;
                              final focusedChild = nearestScope.focusedChild;
                              switch (indent.direction) {
                                case TraversalDirection.up:
                                case TraversalDirection.down:
                                  if (focusedChild == null || !focusedChild.focusInDirection(indent.direction)) {
                                    FocusTraversalGroup.of(context).inDirection(nearestScope.parent!, indent.direction);
                                  }
                                case TraversalDirection.right:
                                case TraversalDirection.left:
                                  focusedChild?.focusInDirection(indent.direction);
                              }
                            }
                            return null;
                          },
                        ),
                      },
                      child: FocusScope(
                        onFocusChange: (f) {
                          if (f) {
                            FocusManager.instance.primaryFocus?.nearestScope?.children.first.requestFocus();
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(padding: const EdgeInsets.only(left: 48, right: 48, top: 12), child: Text(label)),
                            SizedBox(
                              height: height,
                              child: ListView.builder(
                                itemExtent: itemExtent,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 12),
                                itemCount: snapshot.requireData.length,
                                itemBuilder: (context, index) => builder(context, snapshot.requireData[index]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : const SizedBox(),
          ),
    );
  }
}

class MediaGridChannel<T> extends StatefulWidget {
  const MediaGridChannel({
    super.key,
    required this.label,
    required this.itemBuilder,
    required this.onQuery,
    required this.gridDelegate,
  });

  final String label;
  final SliverGridDelegate gridDelegate;
  final ItemWidgetBuilder<T> itemBuilder;
  final Future<PageData<T>> Function(int) onQuery;

  @override
  State<MediaGridChannel<T>> createState() => _MediaGridChannelState<T>();
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
      if (mounted) {
        setState(() {
          _state = _state.copyWith(
            pages: [...?_state.pages, data.data],
            keys: [...?_state.keys, newKey],
            hasNextPage: hasNextPage,
            isLoading: false,
          );
          _count = data.count;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _state = _state.copyWith(error: error, isLoading: false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers:
          _count != 0
              ? [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 48, right: 48, top: 12),
                    child: Text('${widget.label}${_count != null ? ' ($_count)' : ''}'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 12),
                  sliver: PagedSliverGrid(
                    showNewPageProgressIndicatorAsGridChild: false,
                    showNoMoreItemsIndicatorAsGridChild: false,
                    builderDelegate: PagedChildBuilderDelegate<T>(
                      itemBuilder: widget.itemBuilder,
                      noMoreItemsIndicatorBuilder:
                          (context) => const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text(
                              'THE END',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                      firstPageProgressIndicatorBuilder: (context) => const Loading(),
                      newPageProgressIndicatorBuilder:
                          (context) => const Padding(padding: EdgeInsets.only(top: 16), child: Loading()),
                    ),
                    gridDelegate: widget.gridDelegate,
                    fetchNextPage: _fetchNextPage,
                    state: _state,
                  ),
                ),
              ]
              : [],
    );
  }
}
