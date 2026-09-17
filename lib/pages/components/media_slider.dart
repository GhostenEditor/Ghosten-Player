import 'package:flutter/material.dart';

import '../../components/scrollbar.dart';

class MediaSlider<T> extends StatelessWidget {
  const MediaSlider({
    super.key,
    required this.items,
    required this.label,
    required this.height,
    required this.itemBuilder,
    this.onMoreClick,
  });

  final List<T> items;
  final String label;
  final double height;
  final VoidCallback? onMoreClick;
  final NullableIndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return items.isNotEmpty
        ? SliverMainAxisGroup(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                    if (onMoreClick != null)
                      IconButton(
                        style: IconButton.styleFrom(
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: onMoreClick,
                        icon: const Icon(Icons.chevron_right),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: height,
                child: ScrollbarListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  itemCount: items.length,
                  itemBuilder: itemBuilder,
                  separatorBuilder: (context, _) => const SizedBox(width: 16),
                ),
              ),
            ),
          ],
        )
        : const SliverToBoxAdapter();
  }
}
