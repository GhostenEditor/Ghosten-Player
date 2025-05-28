import 'dart:math';

import 'package:flutter/material.dart';

import '../../../components/logo.dart';
import '../../../utils/utils.dart';
import '../../components/mobile_builder.dart';
import '../../utils/utils.dart';
import '../search.dart';
import 'carousel.dart';

class MediaScaffold extends StatefulWidget {
  const MediaScaffold({super.key, required this.slivers, required this.backdrop});

  final ValueNotifier<String?> backdrop;
  final List<Widget> slivers;

  @override
  State<MediaScaffold> createState() => _MediaScaffoldState();
}

class _MediaScaffoldState extends State<MediaScaffold> {
  final _showBlur = ValueNotifier(false);
  final _controller = ScrollController();

  @override
  void initState() {
    _controller.addListener(() {
      final halfHeight = MediaQuery.of(context).size.height / 2;
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
          builder: (context, c) {
            return AspectRatio(
              aspectRatio: max(c.biggest.aspectRatio, 2),
              child: ListenableBuilder(
                listenable: widget.backdrop,
                builder: (context, _) => CarouselBackground(src: widget.backdrop.value),
              ),
            );
          },
        ),
        AspectRatio(
          aspectRatio: 2,
          child: ListenableBuilder(
            listenable: _showBlur,
            builder:
                (context, _) => AnimatedOpacity(
                  opacity: _showBlur.value ? 0.54 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: Container(width: 200, height: 200, color: Theme.of(context).scaffoldBackgroundColor),
                ),
          ),
        ),
        CustomScrollView(
          controller: _controller,
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              pinned: true,
              leading: MobileBuilder(
                builder: (context, isMobile, child) => isMobile ? child : null,
                child: const Padding(padding: EdgeInsets.all(12), child: Logo()),
              ),
              systemOverlayStyle: getSystemUiOverlayStyle(context),
              actions: [
                IconButton(
                  onPressed: () => navigateTo(context, const SearchPage(autofocus: true)),
                  icon: const Icon(Icons.search_rounded),
                ),
              ],
            ),
            ...widget.slivers,
          ],
        ),
      ],
    );
  }
}
