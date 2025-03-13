import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/player.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../utils/utils.dart';

enum _GestureMode {
  none,
  volume,
  seek,
  brightness;
}

class PlayerControlsGesture extends StatefulWidget {
  const PlayerControlsGesture({super.key, required this.controller, required this.child});

  final PlayerController<dynamic> controller;
  final Widget child;

  @override
  State<PlayerControlsGesture> createState() => _PlayerControlsGestureState();
}

class _PlayerControlsGestureState extends State<PlayerControlsGesture> {
  late final _controller = widget.controller;

  final _gestureMode = ValueNotifier(_GestureMode.none);
  final _gestureValue = ValueNotifier<double?>(null);

  @override
  void initState() {
    super.initState();
    VolumeController.instance.showSystemUI = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onDoubleTap: () {
            switch (_controller.status.value) {
              case PlayerStatus.playing:
              case PlayerStatus.buffering:
                _controller.pause();
              case PlayerStatus.paused:
                _controller.play();
              default:
            }
          },
          onHorizontalDragStart: (details) {
            final offset = details.localPosition;
            final box = context.findRenderObject()! as RenderBox;
            final validRect = box.paintBounds.deflate(30);
            if ((_controller.status.value == PlayerStatus.playing ||
                    _controller.status.value == PlayerStatus.buffering ||
                    _controller.status.value == PlayerStatus.paused) &&
                _controller.duration.value.inSeconds > 15 &&
                validRect.contains(offset)) {
              _gestureMode.value = _GestureMode.seek;
              _gestureValue.value = _controller.position.value.inSeconds.toDouble();
            }
          },
          onHorizontalDragUpdate: (details) {
            if (_gestureMode.value == _GestureMode.seek) {
              _gestureValue.value = (_gestureValue.value ?? 0) + details.delta.dx;
              _gestureValue.value = _gestureValue.value!.clamp(0, _controller.duration.value.inSeconds.toDouble());
            }
          },
          onHorizontalDragEnd: (details) {
            if (_gestureMode.value == _GestureMode.seek && _gestureValue.value != null) {
              _controller.seekTo(Duration(seconds: _gestureValue.value!.toInt()));
            }
            _gestureMode.value = _GestureMode.none;
          },
          onHorizontalDragCancel: () {
            _gestureMode.value = _GestureMode.none;
          },
          onVerticalDragStart: (details) async {
            final offset = details.localPosition;
            final box = context.findRenderObject()! as RenderBox;
            final validRect = box.paintBounds.deflate(30);
            final halfWidth = box.size.width / 2;
            if (validRect.contains(offset)) {
              if (offset.dx < halfWidth) {
                _gestureMode.value = _GestureMode.brightness;
                _gestureValue.value = await ScreenBrightness.instance.application;
              } else {
                _gestureMode.value = _GestureMode.volume;
                _gestureValue.value = await VolumeController.instance.getVolume();
              }
            }
          },
          onVerticalDragUpdate: (details) {
            switch (_gestureMode.value) {
              case _GestureMode.volume:
                _gestureValue.value = (_gestureValue.value ?? 0) - details.delta.dy / 300;
                _gestureValue.value = _gestureValue.value!.clamp(0, 1);
                VolumeController.instance.setVolume(_gestureValue.value!);
              case _GestureMode.brightness:
                _gestureValue.value = (_gestureValue.value ?? 0) - details.delta.dy / 300;
                _gestureValue.value = _gestureValue.value!.clamp(0, 1);
                ScreenBrightness.instance.setApplicationScreenBrightness(_gestureValue.value!);
              default:
            }
          },
          onVerticalDragEnd: (details) {
            _gestureMode.value = _GestureMode.none;
          },
          onVerticalDragCancel: () {
            _gestureMode.value = _GestureMode.none;
          },
          child: widget.child,
        ),
        IgnorePointer(
          child: Center(
            child: ListenableBuilder(
                listenable: _gestureMode,
                builder: (context, _) => PageTransitionSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                      ) {
                        return FadeThroughTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          fillColor: Colors.transparent,
                          child: child,
                        );
                      },
                      child: switch (_gestureMode.value) {
                        _GestureMode.seek => ListenableBuilder(
                            listenable: _gestureValue,
                            builder: (context, _) => Container(
                              clipBehavior: Clip.antiAlias,
                              constraints: const BoxConstraints(maxWidth: 160),
                              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                        '${Duration(seconds: _gestureValue.value?.toInt() ?? 0).toDisplay()} / ${_controller.duration.value.toDisplay()}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  LinearProgressIndicator(value: (_gestureValue.value?.toInt() ?? 0) / _controller.duration.value.inSeconds, minHeight: 4)
                                ],
                              ),
                            ),
                          ),
                        _GestureMode.volume => ListenableBuilder(
                            listenable: _gestureValue,
                            builder: (context, _) => Container(
                                  clipBehavior: Clip.antiAlias,
                                  constraints: const BoxConstraints(maxWidth: 160),
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 8,
                                    children: [
                                      if (_gestureValue.value == 0)
                                        const Icon(Icons.volume_mute_rounded)
                                      else if (_gestureValue.value! < 0.5)
                                        const Icon(Icons.volume_down_rounded)
                                      else
                                        const Icon(Icons.volume_up_rounded),
                                      Expanded(
                                        child: Material(
                                          shape: const StadiumBorder(),
                                          clipBehavior: Clip.antiAlias,
                                          child: LinearProgressIndicator(
                                            value: _gestureValue.value,
                                            minHeight: 4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                        _GestureMode.brightness => ListenableBuilder(
                            listenable: _gestureValue,
                            builder: (context, _) => Container(
                                  clipBehavior: Clip.antiAlias,
                                  constraints: const BoxConstraints(maxWidth: 160),
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 8,
                                    children: [
                                      const Icon(Icons.light_mode_rounded),
                                      Expanded(
                                        child: Material(
                                            shape: const StadiumBorder(),
                                            clipBehavior: Clip.antiAlias,
                                            child: LinearProgressIndicator(
                                              value: _gestureValue.value,
                                              minHeight: 4,
                                            )),
                                      ),
                                    ],
                                  ),
                                )),
                        _GestureMode.none => const SizedBox(),
                      },
                    )),
          ),
        ),
      ],
    );
  }
}
