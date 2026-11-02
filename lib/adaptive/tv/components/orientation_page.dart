import 'package:flutter/material.dart';

import '../../../components/keyboard_scroll.dart';

class OrientationPage extends StatefulWidget {
  const OrientationPage({
    super.key,
    required this.section1,
    this.section2,
    this.title,
    this.actions,
    this.autoScroll = false,
  });

  final Widget? section1;
  final Widget? section2;
  final Widget? title;
  final List<Widget>? actions;
  final bool autoScroll;

  @override
  State<OrientationPage> createState() => _OrientationPageState();
}

class _OrientationPageState extends State<OrientationPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Scrollbar(
      controller: _scrollController,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverSafeArea(bottom: false, sliver: SliverToBoxAdapter()),
          SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 32), sliver: widget.section2),
          const SliverSafeArea(top: false, sliver: SliverToBoxAdapter()),
        ],
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(switch (Theme.of(context).brightness) {
                Brightness.dark => 'assets/images/bg-stripe.png',
                Brightness.light => 'assets/images/bg-stripe-light.png',
              }),
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withAlpha(0xaa),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: const [0.2, 0.5],
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
            automaticallyImplyLeading: false,
            title: widget.title,
            actions: widget.actions,
            titleSpacing: 32,
            actionsPadding: const EdgeInsets.only(right: 16),
          ),
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Row(
            children: [
              Expanded(
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: widget.section1),
              ),
              Expanded(
                child: widget.autoScroll ? KeyboardScroll(controller: _scrollController, child: content) : content,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
