import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'headered_content.dart';
import 'horizontal_list_theme.dart';
import 'media_card_theme.dart';

class HorizontalList extends StatelessWidget {
  const HorizontalList({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.header,
    this.onTap,
    this.cardStyle,
    this.scrollCacheExtent,
    this.allowHalf = false,
  });

  final int itemCount;
  final MediaCardThemeData? cardStyle;
  final Widget header;
  final Widget Function(BuildContext, int, Size) itemBuilder;
  final GestureTapCallback? onTap;
  final ScrollCacheExtent? scrollCacheExtent;
  final bool allowHalf;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return const SizedBox();
    }
    final HorizontalListThemeData themeData = HorizontalListTheme.of(context);
    final double heightExtent = cardStyle?.heightExtent ?? 0;
    final EdgeInsets padding = themeData.padding ?? .zero;
    final EdgeInsets headerPadding = themeData.headerPadding ?? .zero;
    final double itemSpacing = themeData.itemSpacing ?? 0;
    final double itemMinWidth = cardStyle?.minWidth ?? 100;
    final double aspectRatio = cardStyle?.aspectRatio ?? 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth - (themeData.padding?.horizontal ?? 0);
        double crossAxisCount = (width + itemSpacing) / (itemMinWidth + itemSpacing);
        crossAxisCount = allowHalf ? (crossAxisCount * 2).floorToDouble() / 2 : crossAxisCount.floorToDouble();
        crossAxisCount = max(crossAxisCount, 1);
        final double fixedWidth = (width + itemSpacing) / crossAxisCount - itemSpacing;
        final double fixedHeight = fixedWidth / aspectRatio;
        return HeaderedContent(
          header: header,
          headerPadding: headerPadding,
          onTap: onTap,
          child: SizedBox(
            height: fixedHeight + heightExtent + padding.vertical,
            child: Scrollbar(
              child: ListView.builder(
                padding: padding,
                scrollDirection: Axis.horizontal,
                scrollCacheExtent: scrollCacheExtent,
                itemBuilder: (context, index) => index.isEven
                    ? itemBuilder(context, index ~/ 2, Size(fixedWidth, fixedHeight))
                    : SizedBox(width: itemSpacing),
                itemCount: max(0, itemCount * 2 - 1),
                itemExtentBuilder: (index, _) => index.isOdd ? itemSpacing : fixedWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}

class SliverHorizontalList extends StatelessWidget {
  const SliverHorizontalList({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.header,
    this.onTap,
    this.cardStyle,
    this.allowHalf = false,
  });

  final int itemCount;
  final MediaCardThemeData? cardStyle;
  final Widget header;
  final Widget Function(BuildContext, int, Size) itemBuilder;
  final GestureTapCallback? onTap;
  final bool allowHalf;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return const SliverToBoxAdapter();
    }
    final HorizontalListThemeData themeData = HorizontalListTheme.of(context);
    final double heightExtent = cardStyle?.heightExtent ?? 0;
    final EdgeInsets padding = themeData.padding ?? .zero;
    final EdgeInsets headerPadding = themeData.headerPadding ?? .zero;
    final double itemSpacing = themeData.itemSpacing ?? 0;
    final double itemMinWidth = cardStyle?.minWidth ?? 100;
    final double aspectRatio = cardStyle?.aspectRatio ?? 1;
    return SliverHeaderedContent(
      header: header,
      headerPadding: headerPadding,
      onTap: onTap,
      sliver: SliverToBoxAdapter(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth - (themeData.padding?.horizontal ?? 0);
            double crossAxisCount = (width + itemSpacing) / (itemMinWidth + itemSpacing);
            crossAxisCount = allowHalf ? (crossAxisCount * 2).floorToDouble() / 2 : crossAxisCount.floorToDouble();
            crossAxisCount = max(crossAxisCount, 1);
            final double fixedWidth = (width + itemSpacing) / crossAxisCount - itemSpacing;
            final double fixedHeight = fixedWidth / aspectRatio;
            final fixedSize = Size(fixedWidth, fixedHeight);
            return SizedBox(
              height: fixedSize.height + heightExtent + padding.vertical,
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: Scrollbar(
                  child: FocusScope(
                    child: ListView.builder(
                      padding: padding,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) =>
                          index.isEven ? itemBuilder(context, index ~/ 2, fixedSize) : SizedBox(width: itemSpacing),
                      itemCount: max(0, itemCount * 2 - 1),
                      itemExtentBuilder: (index, _) => index.isOdd ? itemSpacing : fixedSize.width,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
