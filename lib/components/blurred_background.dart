import 'dart:math';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BlurredBackground extends StatefulWidget {
  final String background;
  final Color? defaultColor;

  const BlurredBackground({super.key, required this.background, this.defaultColor});

  @override
  State<BlurredBackground> createState() => _BlurredBackgroundState();
}

class _BlurredBackgroundState extends State<BlurredBackground> with SingleTickerProviderStateMixin {
  late final size = MediaQuery.of(context).size;
  final blurSize = 50.0;
  final scaleSize = 4;
  Offset offset = Offset.zero;
  Offset vector = const Offset(1, 1);
  Size imageSize = Size.zero;
  Size imageSizeFixed = Size.zero;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: FutureBuilder(
          future: background(),
          builder: (context, snapshot) {
            return AnimatedOpacity(
                opacity: snapshot.hasData ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => Transform(
                    transform: transform(),
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    child: child,
                  ),
                  child: snapshot.hasData ? snapshot.requireData : Container(color: widget.defaultColor ?? Theme.of(context).colorScheme.surface),
                ));
          }),
    );
  }

  Future<Widget> background() async {
    final data = await widgetToUiImage(
        ImageFiltered(imageFilter: ui.ImageFilter.blur(sigmaX: blurSize, sigmaY: blurSize), child: CachedNetworkImage(imageUrl: widget.background)));
    imageSize = Size(data.width.toDouble(), data.height.toDouble());
    imageSizeFixed = Size(
      imageSize.aspectRatio > size.aspectRatio ? size.width : size.height * imageSize.aspectRatio,
      imageSize.aspectRatio < size.aspectRatio ? size.height : size.width / imageSize.aspectRatio,
    );
    return Image.memory((await data.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List(), fit: BoxFit.contain);
  }

  Matrix4 transform() {
    final offsetLimitation = Size(
          max(imageSizeFixed.width * scaleSize - size.width, 0),
          max(imageSizeFixed.height * scaleSize - size.height, 0),
        ) /
        2;
    offset += vector;
    if (offset.dx < -offsetLimitation.width || offset.dx > offsetLimitation.width) {
      vector = Offset(-vector.dx, vector.dy);
    }
    if (offset.dy < -offsetLimitation.height || offset.dy > offsetLimitation.height) {
      vector = Offset(vector.dx, -vector.dy);
    }
    offset = Offset(
      clampDouble(offset.dx, -offsetLimitation.width, offsetLimitation.width),
      clampDouble(offset.dy, -offsetLimitation.height, offsetLimitation.height),
    );
    final matrix = Matrix4.translationValues(-size.width / 2, -size.height / 2, 0).scaled(scaleSize.toDouble(), scaleSize.toDouble(), 1.0);
    matrix.translate((offset.dx + size.width / 2) / scaleSize, (offset.dy + size.height / 2) / scaleSize, 0);
    return matrix;
  }

  static Future<ui.Image> widgetToUiImage(
    Widget widget, {
    Duration delay = Duration.zero,
    double? pixelRatio,
    BuildContext? context,
    Size? targetSize,
  }) async {
    int retryCounter = 3;
    bool isDirty = false;

    Widget child = widget;

    if (context != null) {
      child = InheritedTheme.captureAll(
        context,
        MediaQuery(
            data: MediaQuery.of(context),
            child: Material(
              color: Colors.transparent,
              child: child,
            )),
      );
    }

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final fallBackView = platformDispatcher.views.first;
    final view = context == null ? fallBackView : View.maybeOf(context) ?? fallBackView;
    Size logicalSize = targetSize ?? view.physicalSize / view.devicePixelRatio;
    Size imageSize = targetSize ?? view.physicalSize;

    assert(logicalSize.aspectRatio.toStringAsPrecision(5) == imageSize.aspectRatio.toStringAsPrecision(5));

    final RenderView renderView = RenderView(
      view: view,
      child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints(
          maxWidth: logicalSize.width,
          maxHeight: logicalSize.height,
        ),
        devicePixelRatio: pixelRatio ?? 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager(), onBuildScheduled: () => isDirty = true);

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(container: repaintBoundary, child: Directionality(textDirection: TextDirection.ltr, child: child))
            .attachToRenderTree(buildOwner);

    buildOwner.buildScope(
      rootElement,
    );
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    ui.Image? image;

    do {
      isDirty = false;
      image = await repaintBoundary.toImage(pixelRatio: pixelRatio ?? (imageSize.width / logicalSize.width));

      await Future.delayed(delay);

      if (isDirty) {
        buildOwner.buildScope(
          rootElement,
        );
        buildOwner.finalizeTree();
        pipelineOwner.flushLayout();
        pipelineOwner.flushCompositingBits();
        pipelineOwner.flushPaint();
      }
      retryCounter--;
    } while (isDirty && retryCounter >= 0);
    try {
      buildOwner.finalizeTree();
    } catch (e) {}

    return image;
  }
}
