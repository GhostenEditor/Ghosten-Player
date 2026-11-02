import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:video_player/player.dart';

class PlayerZoomWrapper extends StatefulWidget {
  const PlayerZoomWrapper({
    super.key,
    required this.controller,
    required this.child,
    this.minScale = 0.3,
    this.maxScale = 3,
    required this.onZoomChanged,
  });

  final PlayerController controller;
  final Widget child;
  final double minScale;
  final double maxScale;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<PlayerZoomWrapper> createState() => PlayerZoomWrapperState();
}

class PlayerZoomWrapperState extends State<PlayerZoomWrapper> {
  late final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
  final _controller = TransformationController();
  late Matrix4 _initialMatrix;
  late Offset _initialFocalPoint;
  late double _initialScale;

  @override
  void initState() {
    super.initState();
    _controller.value = Matrix4.identity();
    _initialMatrix = Matrix4.identity();
    _initialFocalPoint = Offset.zero;
    _initialScale = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        ScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
          () => ScaleGestureRecognizer(),
          (instance) => instance
            ..onStart = _handleScaleStart
            ..onUpdate = _handleScaleUpdate,
        ),
      },
      behavior: HitTestBehavior.opaque,
      child: Transform(transform: _controller.value, alignment: Alignment.center, child: widget.child),
    );
  }

  void reset() {
    if (_controller.value != Matrix4.identity()) {
      widget.controller.setTransform([1, 0, 0, 0, 1, 0, 0, 0, 1]);
      _controller.value = Matrix4.identity();
      widget.onZoomChanged(false);
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (details.pointerCount != 2) {
      return;
    }
    _initialMatrix = _controller.value.clone();
    _initialFocalPoint = details.localFocalPoint;
    _initialScale = _controller.value.getMaxScaleOnAxis();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount != 2) {
      return;
    }
    final double newScale = (_initialScale * details.scale).clamp(widget.minScale, widget.maxScale);

    final double scaleFactor = newScale / _initialScale;

    final focalPointVector = vm.Vector3(_initialFocalPoint.dx, _initialFocalPoint.dy, 0);

    final vm.Vector3 transformedFocalPoint = _initialMatrix.perspectiveTransform(focalPointVector);
    final focalOffset = Offset(transformedFocalPoint.x, transformedFocalPoint.y);

    final matrix = Matrix4.identity()
      ..translateByVector2(vm.Vector2(focalOffset.dx, focalOffset.dy))
      ..scaleByVector3(vm.Vector3.all(scaleFactor))
      ..translateByVector2(vm.Vector2(-focalOffset.dx, -focalOffset.dy))
      ..multiply(_initialMatrix);

    widget.controller.setTransform([
      matrix.storage[0],
      0,
      matrix.storage[12] * devicePixelRatio,
      0,
      matrix.storage[5],
      matrix.storage[13] * devicePixelRatio,
      0,
      0,
      1,
    ]);
    widget.onZoomChanged(true);
    _controller.value = matrix;
  }
}
