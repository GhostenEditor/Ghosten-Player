import 'dart:math';

import 'package:flutter/material.dart';

import '../../../components/components.dart';

class MediaScaffold extends StatefulWidget {
  const MediaScaffold({super.key, required this.slivers, required this.backdrop});

  final ValueNotifier<String?> backdrop;
  final List<Widget> slivers;

  @override
  State<MediaScaffold> createState() => _MediaScaffoldState();
}

class _MediaScaffoldState extends State<MediaScaffold> {
  final ValueNotifier<bool> _showBlur = ValueNotifier(false);
  final _controller = ScrollController();

  @override
  void initState() {
    _controller.addListener(() {
      final double halfHeight = MediaQuery.sizeOf(context).height / 2;
      _showBlur.value = _controller.offset > halfHeight;
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return AspectRatio(
              aspectRatio: max(constraints.biggest.aspectRatio, 2),
              child: ListenableBuilder(
                listenable: Listenable.merge([widget.backdrop, _showBlur]),
                builder: (context, _) => CarouselBackground(src: widget.backdrop.value, isActive: !_showBlur.value),
              ),
            );
          },
        ),
        CustomScrollView(
          controller: _controller,
          slivers: [
            ...widget.slivers,
            const SliverSafeArea(top: false, sliver: SliverToBoxAdapter()),
          ],
        ),
      ],
    );
  }
}
