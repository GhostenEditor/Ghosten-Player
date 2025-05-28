import 'package:api/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';
import '../views/image_viewer.dart';

class AsyncImage extends StatelessWidget {
  const AsyncImage(
    this.src, {
    super.key,
    this.width,
    this.height,
    this.radius = BorderRadius.zero,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
    this.ink = false,
    this.needLoading = true,
    this.errorIconSize = 36,
    this.padding = EdgeInsets.zero,
    this.httpHeaders,
    this.viewable = false,
    this.showErrorWidget = true,
  });

  final String src;
  final double? width;
  final double? height;
  final BorderRadius radius;
  final Alignment alignment;
  final BoxFit fit;
  final bool ink;
  final bool needLoading;
  final double errorIconSize;
  final EdgeInsets padding;
  final Map<String, String>? httpHeaders;
  final bool viewable;
  final bool showErrorWidget;

  @override
  Widget build(BuildContext context) {
    final image = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: radius),
      child: CachedNetworkImage(
        imageUrl: _resoleSrc(),
        alignment: alignment,
        fit: fit,
        filterQuality: FilterQuality.medium,
        width: width,
        height: height,
        httpHeaders: httpHeaders,
        errorWidget:
            (context, url, error) =>
                showErrorWidget
                    ? Center(
                      child: Icon(
                        Icons.broken_image,
                        size: errorIconSize,
                        color: Theme.of(context).colorScheme.error.withAlpha(0x33),
                      ),
                    )
                    : const SizedBox(),
        placeholder: (context, _) => needLoading ? const _AnimatedLoading() : const SizedBox(),
        imageBuilder:
            ink
                ? (context, imageProvider) {
                  return Padding(
                    padding: padding,
                    child: Ink(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        image: DecorationImage(image: imageProvider, fit: fit, alignment: alignment),
                      ),
                    ),
                  );
                }
                : null,
      ),
    );
    return viewable
        ? GestureDetector(
          onLongPress: () => navigateTo(navigatorKey.currentContext!, ImageViewer(url: Uri.parse(src))),
          child: image,
        )
        : image;
  }

  String _resoleSrc() {
    if (src.startsWith('/file/download')) {
      return '${Api.baseUrl}$src';
    } else {
      return src;
    }
  }
}

class _AnimatedLoading extends StatefulWidget {
  const _AnimatedLoading();

  @override
  State<_AnimatedLoading> createState() => _AnimatedLoadingState();
}

class _AnimatedLoadingState extends State<_AnimatedLoading> with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder:
          (context, _) => DecoratedBox(
            decoration: BoxDecoration(
              color: Color.lerp(
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceContainerHigh,
                _animationController.value,
              ),
            ),
          ),
    );
  }
}
