import 'dart:math';

import 'package:flutter/material.dart';

class ScrollbarListView extends StatefulWidget {
  ScrollbarListView({
    super.key,
    this.scrollDirection = Axis.vertical,
    List<Widget> children = const <Widget>[],
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.padding,
  }) : childrenDelegate = SliverChildListDelegate(
         children,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
       );

  ScrollbarListView.builder({
    super.key,
    required NullableIndexedWidgetBuilder itemBuilder,
    this.scrollDirection = Axis.vertical,
    ChildIndexGetter? findChildIndexCallback,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.padding,
  }) : childrenDelegate = SliverChildBuilderDelegate(
         itemBuilder,
         findChildIndexCallback: findChildIndexCallback,
         childCount: itemCount,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
       );

  ScrollbarListView.separated({
    super.key,
    required NullableIndexedWidgetBuilder itemBuilder,
    required IndexedWidgetBuilder separatorBuilder,
    this.scrollDirection = Axis.vertical,
    ChildIndexGetter? findChildIndexCallback,
    required int itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    this.padding,
  }) : childrenDelegate = SliverChildBuilderDelegate(
         (BuildContext context, int index) {
           final int itemIndex = index ~/ 2;
           if (index.isEven) {
             return itemBuilder(context, itemIndex);
           }
           return separatorBuilder(context, itemIndex);
         },
         findChildIndexCallback: findChildIndexCallback,
         childCount: _computeActualChildCount(itemCount),
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
         semanticIndexCallback: (Widget widget, int index) {
           return index.isEven ? index ~/ 2 : null;
         },
       );
  final SliverChildDelegate childrenDelegate;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;

  static int _computeActualChildCount(int itemCount) {
    return max(0, itemCount * 2 - 1);
  }

  @override
  State<ScrollbarListView> createState() => _ScrollbarListViewState();
}

class _ScrollbarListViewState extends State<ScrollbarListView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: ListView.custom(
        controller: _scrollController,
        childrenDelegate: widget.childrenDelegate,
        scrollDirection: widget.scrollDirection,
        padding: widget.padding,
      ),
    );
  }
}
