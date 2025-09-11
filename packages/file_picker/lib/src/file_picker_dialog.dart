import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PageData<T> {
  const PageData({required this.items, required this.limit, required this.count});

  final List<T> items;
  final int limit;
  final int count;
}

class FilePickerDialog<T> extends StatefulWidget {
  const FilePickerDialog({
    super.key,
    required this.titleBuilder,
    required this.actions,
    required this.fetchData,
    required this.itemBuilder,
    required this.controller,
    this.defaultTitle,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
  });

  final Widget? defaultTitle;
  final Widget Function(T?) titleBuilder;
  final List<Widget> actions;
  final Future<PageData<T>> Function(int) fetchData;
  final ItemWidgetBuilder<T> itemBuilder;
  final FileViewerController<T> controller;
  final WidgetBuilder? firstPageProgressIndicatorBuilder;
  final WidgetBuilder? newPageProgressIndicatorBuilder;
  final WidgetBuilder? noItemsFoundIndicatorBuilder;
  final WidgetBuilder? firstPageErrorIndicatorBuilder;

  @override
  State<FilePickerDialog<T>> createState() => _FilePickerDialogState();
}

class _FilePickerDialogState<T> extends State<FilePickerDialog<T>> {
  late final _controller = widget.controller;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.currentItem.addListener(() {
      if (_scrollController.hasClients) {
        WidgetsBinding.instance.endOfFrame.then((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        if (_controller.routers.isNotEmpty) {
          _controller.back();
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: ListenableBuilder(
            listenable: _controller.currentItem,
            builder: (context, _) => PageTransitionSwitcher(
              reverse: _controller._reverse,
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
              child: Align(
                alignment: Alignment.centerLeft,
                key: ValueKey(_controller.currentItem.value),
                child: _controller.currentItem.value == null
                    ? widget.defaultTitle
                    : widget.titleBuilder(_controller.currentItem.value),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(32),
            child: SizedBox(
              height: 32,
              child: ListenableBuilder(
                listenable: _controller.currentItem,
                builder: (context, _) {
                  return ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _controller.routers.length + 1,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: index != _controller.routers.length
                            ? () => _controller.back(_controller.routers.length - index)
                            : null,
                        child: Center(
                          child: DefaultTextStyle(
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: index == _controller.routers.length ? Theme.of(context).colorScheme.primary : null,
                              fontWeight: FontWeight.w500,
                            ),
                            child: widget.titleBuilder(index == 0 ? null : _controller.routers[index - 1]),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Icon(Icons.chevron_right),
                  );
                },
              ),
            ),
          ),
          actions: widget.actions,
        ),
        body: RefreshIndicator(
          onRefresh: () async => _controller.refresh(),
          child: StreamBuilder(
            initialData: '/',
            stream: _controller._controller.stream,
            builder: (context, snapshot) {
              return PageTransitionSwitcher(
                reverse: _controller._reverse,
                transitionBuilder:
                    (Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
                      return SharedAxisTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: _controller._refresh
                            ? SharedAxisTransitionType.vertical
                            : SharedAxisTransitionType.horizontal,
                        fillColor: Colors.transparent,
                        child: child,
                      );
                    },
                child: _FileViewer(
                  key: UniqueKey(),
                  controller: _controller,
                  itemBuilder: widget.itemBuilder,
                  fetchData: widget.fetchData,
                  firstPageProgressIndicatorBuilder: widget.firstPageProgressIndicatorBuilder,
                  newPageProgressIndicatorBuilder: widget.newPageProgressIndicatorBuilder,
                  noItemsFoundIndicatorBuilder: widget.noItemsFoundIndicatorBuilder,
                  firstPageErrorIndicatorBuilder: widget.firstPageErrorIndicatorBuilder,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FileViewerController<T> {
  FileViewerController();

  final _controller = StreamController<String?>();
  final List<T> routers = [];
  final ValueNotifier<T?> currentItem = ValueNotifier(null);
  dynamic error;
  bool _reverse = false;
  bool _refresh = false;

  void dispose() {
    _controller.close();
    currentItem.dispose();
  }

  void refresh() {
    _reverse = false;
    _refresh = true;
    _controller.add(null);
  }

  void nextPage(T item) {
    _reverse = false;
    _refresh = false;
    routers.add(item);
    _controller.add(null);
    currentItem.value = routers.lastOrNull;
  }

  void back([int n = 1]) {
    _reverse = true;
    _refresh = false;
    routers.removeRange(routers.length - n, routers.length);
    _controller.add(null);
    currentItem.value = routers.lastOrNull;
  }
}

class _FileViewer<T> extends StatefulWidget {
  const _FileViewer({
    super.key,
    required this.fetchData,
    required this.itemBuilder,
    required this.controller,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
  });

  final Future<PageData<T>> Function(int) fetchData;
  final ItemWidgetBuilder<T> itemBuilder;
  final FileViewerController<T> controller;
  final WidgetBuilder? firstPageProgressIndicatorBuilder;
  final WidgetBuilder? newPageProgressIndicatorBuilder;
  final WidgetBuilder? noItemsFoundIndicatorBuilder;
  final WidgetBuilder? firstPageErrorIndicatorBuilder;

  @override
  State<_FileViewer<T>> createState() => _FileViewerState();
}

class _FileViewerState<T> extends State<_FileViewer<T>> {
  final _scrollController = ScrollController();
  PagingState<int, T> _state = PagingState();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: PagedListView(
        scrollController: _scrollController,
        state: _state,
        fetchNextPage: _fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: widget.itemBuilder,
          firstPageProgressIndicatorBuilder: widget.firstPageProgressIndicatorBuilder,
          newPageProgressIndicatorBuilder: widget.newPageProgressIndicatorBuilder,
          noItemsFoundIndicatorBuilder: widget.noItemsFoundIndicatorBuilder,
          firstPageErrorIndicatorBuilder: widget.firstPageErrorIndicatorBuilder,
        ),
      ),
    );
  }

  Future<void> _fetchNextPage() async {
    if (_state.isLoading) return;
    await Future.value();
    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });
    widget.controller.error = null;
    try {
      final newKey = (_state.keys?.last ?? -1) + 1;

      final data = await widget.fetchData(newKey);

      final hasNextPage = (data.count / data.limit).ceil() > (newKey + 1);
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(
          pages: [...?_state.pages, data.items],
          keys: [...?_state.keys, newKey],
          hasNextPage: hasNextPage,
          isLoading: false,
        );
      });
    } catch (error) {
      setState(() {
        _state = _state.copyWith(error: error, isLoading: false);
        widget.controller.error = error;
      });
    }
  }
}
