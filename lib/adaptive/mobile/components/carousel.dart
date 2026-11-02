import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../previews/previews.dart';

class Carousel extends StatefulWidget {
  const Carousel({super.key, required this.itemCount, this.onChange, required this.itemBuilder});

  final ValueChanged<int>? onChange;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.itemCount,
            itemBuilder: widget.itemBuilder,
            onPageChanged: widget.onChange,
          ),
        ),
        SmoothPageIndicator(
          controller: _controller,
          count: widget.itemCount,
          effect: switch (Theme.of(context).brightness) {
            Brightness.dark => const WormEffect(
              dotWidth: 6,
              dotHeight: 6,
              spacing: 6,
              dotColor: Colors.white38,
              activeDotColor: Colors.white,
            ),
            Brightness.light => const WormEffect(
              dotWidth: 6,
              dotHeight: 6,
              spacing: 6,
              dotColor: Colors.black38,
              activeDotColor: Colors.black,
            ),
          },
        ),
      ],
    );
  }
}

@AppPreview(group: 'Carousel (Mobile)', size: Size(800, 300))
Widget carouselPreview() {
  return Carousel(
    itemCount: 5,
    itemBuilder: (context, index) => ColoredBox(
      color: Colors.blue[(index + 1) * 100]!,
      child: Center(child: Text(index.toString(), style: Theme.of(context).textTheme.displayLarge)),
    ),
  );
}
