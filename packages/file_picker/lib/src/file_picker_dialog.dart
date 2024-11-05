import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FilePickerDialog<T> extends StatefulWidget {
  final String? title;
  final Widget? empty;
  final Widget Function(AsyncSnapshot<List<T>>)? errorBuilder;
  final Widget Function(
    BuildContext context,
    T item, {
    required VoidCallback onPage,
    required ValueChanged<T?> onSubmit,
    required VoidCallback onRefresh,
    T? groupValue,
  }) childBuilder;
  final Future<List<T>> Function(T? item) onFetch;

  const FilePickerDialog({
    super.key,
    this.title,
    this.empty = const SizedBox(),
    required this.onFetch,
    this.errorBuilder,
    required this.childBuilder,
  });

  @override
  State<FilePickerDialog<T>> createState() => _FilePickerDialogState();
}

class _FilePickerDialogState<T> extends State<FilePickerDialog<T>> {
  final _stream = StreamController<List<T>>();
  final List<T?> _routes = [];
  bool _reverse = false;
  T? _selectedFolder;

  @override
  void initState() {
    _page(null);
    super.initState();
  }

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title != null ? Text(widget.title!) : null,
        leading: BackButton(onPressed: _pageBack),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) _pageBack();
        },
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: StreamBuilder<List<T>>(
              stream: _stream.stream,
              builder: (context, snapshot) {
                return PageTransitionSwitcher(
                  reverse: _reverse,
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
                  child: switch (snapshot.connectionState) {
                    ConnectionState.waiting => snapshot.hasError
                        ? widget.errorBuilder != null
                            ? widget.errorBuilder!(snapshot)
                            : const SizedBox()
                        : const Center(child: CircularProgressIndicator()),
                    ConnectionState.none || ConnectionState.active || ConnectionState.done => snapshot.hasError
                        ? widget.errorBuilder != null
                            ? widget.errorBuilder!(snapshot)
                            : const SizedBox()
                        : snapshot.hasData
                            ? snapshot.requireData.isEmpty
                                ? widget.empty!
                                : _ListViewWithScrollbar(
                                    key: UniqueKey(),
                                    itemBuilder: (BuildContext context, int index) {
                                      final item = snapshot.requireData[index];
                                      return widget.childBuilder(
                                        context,
                                        item,
                                        groupValue: _selectedFolder,
                                        onPage: () => _page(item),
                                        onSubmit: _submit,
                                        onRefresh: () => _refresh(),
                                      );
                                    },
                                    separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
                                    itemCount: snapshot.requireData.length)
                            : const SizedBox(),
                  },
                );
              }),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    try {
      final res = await widget.onFetch(_routes.last);
      _stream.add(res);
    } catch (e) {
      _stream.addError(e);
    }
  }

  Future<void> _page(T? item, [reverse = false]) async {
    try {
      final res = await widget.onFetch(item);
      _reverse = reverse;
      _routes.add(item);
      _stream.add(res);
    } catch (e) {
      _routes.add(null);
      _stream.addError(e);
    }
  }

  _pageBack() {
    if (_routes.length > 1) {
      _routes.removeLast();
      _page(_routes.removeLast(), true);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submit(T? file) async {
    if (file == null) return;
    setState(() => _selectedFolder = file);
    Navigator.of(context).pop(file);
  }
}

class _ListViewWithScrollbar extends StatefulWidget {
  final NullableIndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  final int itemCount;

  const _ListViewWithScrollbar({
    super.key,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.itemCount,
  });

  @override
  State<_ListViewWithScrollbar> createState() => _ListViewWithScrollbarState();
}

class _ListViewWithScrollbarState extends State<_ListViewWithScrollbar> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(listTileTheme: const ListTileThemeData(contentPadding: EdgeInsetsDirectional.only(start: 16, end: 16))),
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.separated(
          controller: _scrollController,
          itemBuilder: widget.itemBuilder,
          separatorBuilder: widget.separatorBuilder,
          itemCount: widget.itemCount,
        ),
      ),
    );
  }
}
