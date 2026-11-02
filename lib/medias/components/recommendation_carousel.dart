import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../adaptive/adaptive.dart';

class RecommendationCarousel extends StatelessWidget {
  const RecommendationCarousel({super.key, required this.onChanged, required this.items, this.onPressed});

  final ValueChanged<int> onChanged;
  final List<MediaRecommendation> items;
  final Function(int)? onPressed;

  @override
  Widget build(BuildContext context) {
    if (items.isNotEmpty) {
      Future.microtask(() => onChanged(0));
    }
    return SliverSafeArea(
      bottom: false,
      sliver: SliverToBoxAdapter(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double height = min(max(constraints.maxWidth / 2, 200.0), MediaQuery.of(context).size.height * 0.7);
            return SizedBox(
              height: height,
              child: Carousel(
                itemCount: items.length,
                onChange: onChanged,
                itemBuilder: (context, index) => CarouselItem(
                  key: ValueKey(items[index].id),
                  item: items[index],
                  onPressed: onPressed != null ? () => onPressed!(index) : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
