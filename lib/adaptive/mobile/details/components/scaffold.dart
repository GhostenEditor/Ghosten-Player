import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../../menus/abstract.dart';
import '../../../../utils/utils.dart';

class DetailScaffold extends StatefulWidget {
  const DetailScaffold({
    super.key,
    this.scrollController,
    this.imageAspectRatio,
    this.image,
    this.themeColor,
    required this.menus,
    required this.slivers,
    required this.onRefresh,
  });

  final int? themeColor;
  final List<Widget> slivers;
  final Menu menus;
  final Widget? image;
  final double? imageAspectRatio;
  final ScrollController? scrollController;
  final RefreshCallback onRefresh;

  @override
  State<DetailScaffold> createState() => _DetailScaffoldState();
}

class _DetailScaffoldState extends State<DetailScaffold> {
  late final ScrollController _scrollController = widget.scrollController ?? ScrollController();
  final ValueNotifier<double> _bgOffset = ValueNotifier(0.0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double w = MediaQuery.sizeOf(context).width;
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        _bgOffset.value = (_scrollController.offset / w).clamp(0, 1);
      }
    });
  }

  @override
  void dispose() {
    if (widget.scrollController != null) {
      _scrollController.dispose();
    }
    _bgOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      widget.themeColor,
      builder: (context) {
        return RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Theme.of(context).colorScheme.surfaceDim,
            appBar: AppBar(
              forceMaterialTransparency: true,
              actions: [
                EndDrawerButton(onPressed: () => context.showContextMenu(widget.menus.buildSettingItems(context))),
              ],
            ),
            body: Scrollbar(
              controller: _scrollController,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 400,
                      child: RepaintBoundary(
                        child: ValueListenableBuilder(
                          valueListenable: _bgOffset,
                          builder: (context, value, child) {
                            final Color scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
                            return Transform.translate(
                              offset: _scrollController.hasClients
                                  ? Offset(0, -_scrollController.offset / 2)
                                  : Offset.zero,
                              child: ShaderMask(
                                blendMode: BlendMode.dstIn,
                                shaderCallback: (Rect bounds) => LinearGradient(
                                  colors: [
                                    scaffoldBackgroundColor.withAlpha((0xFF * (1 - value)).toInt()),
                                    scaffoldBackgroundColor.withAlpha((0x66 * (1 - value)).toInt()),
                                    scaffoldBackgroundColor.withAlpha((0x00 * (1 - value)).toInt()),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.3, 0.6, 0.9],
                                ).createShader(bounds),
                                child: child,
                              ),
                            );
                          },
                          child: widget.image,
                        ),
                      ),
                    ),
                  ),
                  CustomScrollView(controller: _scrollController, slivers: [...widget.slivers]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
