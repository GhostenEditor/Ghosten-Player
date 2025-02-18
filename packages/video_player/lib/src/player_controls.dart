import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'cast.dart';
import 'models.dart';
import 'player.dart';
import 'player_cast.dart';
import 'player_platform_interface.dart';

class PlayerSpeed {
  final String text;
  final double value;

  const PlayerSpeed({required this.value, required this.text});
}

const playerSpeedList = [
  PlayerSpeed(text: '0.25x', value: 0.25),
  PlayerSpeed(text: '0.5x', value: 0.5),
  PlayerSpeed(text: '0.75x', value: 0.75),
  PlayerSpeed(text: '1.0x', value: 1),
  PlayerSpeed(text: '1.25x', value: 1.25),
  PlayerSpeed(text: '1.5x', value: 1.5),
  PlayerSpeed(text: '2.0x', value: 2),
  PlayerSpeed(text: '3.0x', value: 3),
  PlayerSpeed(text: '5.0x', value: 5),
];

enum ControlsStreamStatus { show, showInfinite, hide }

class PlayerControls extends StatefulWidget {
  final bool isTV;
  final int? theme;
  final void Function(int, Duration, Duration)? onMediaChange;
  final PlayerController controller;
  final List<ListTile> Function(BuildContext)? actions;
  final PlayerLocalizations localizations;
  final bool? showThumbnails;
  final Map<String, dynamic>? options;
  final Cast? cast;
  final Widget Function(BuildContext, int index, void Function(int) onTap)? playlistItemBuilder;

  const PlayerControls({
    super.key,
    required this.controller,
    required this.localizations,
    this.onMediaChange,
    this.actions,
    this.isTV = false,
    this.theme,
    this.options,
    this.showThumbnails,
    this.cast,
    this.playlistItemBuilder,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  late final _controller = widget.controller;
  late final _progressController = PlayerProgressController(
    getVideoThumbnail: _controller.getVideoThumbnail,
    theme: widget.theme,
    showThumbnails: widget.showThumbnails,
  );
  final _progressFocusNode = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _isShowControls = ValueNotifier(false);
  final _isLocked = ValueNotifier(false);
  final _controlsStream = StreamController<ControlsStreamStatus>();
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    _controller.status.addListener(() => _progressController.setStatus(_controller.status.value));
    _controller.position.addListener(() => _progressController.setPosition(_controller.position.value));
    _controller.duration.addListener(() => _progressController.setDuration(_controller.duration.value));
    _controller.bufferedPosition.addListener(() => _progressController.setBuffered(_controller.bufferedPosition.value));
    _subscription = _controlsStream.stream.switchMap((status) {
      switch (status) {
        case ControlsStreamStatus.show:
          return ConcatStream([Stream.value(true), TimerStream(false, const Duration(seconds: 5))]);
        case ControlsStreamStatus.showInfinite:
          return Stream.value(true);
        case ControlsStreamStatus.hide:
          return Stream.value(false);
      }
    }).listen((show) {
      _isShowControls.value = show;
    });
    _controlsStream.add(ControlsStreamStatus.showInfinite);
    _controller.status.addListener(() {
      switch (_controller.status.value) {
        case PlayerStatus.playing:
          if (_isShowControls.value) _controlsStream.add(ControlsStreamStatus.show);
        case PlayerStatus.paused:
        case PlayerStatus.ended:
        case PlayerStatus.error:
        case PlayerStatus.idle:
          _controlsStream.add(ControlsStreamStatus.showInfinite);
        case PlayerStatus.buffering:
      }
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (widget.onMediaChange != null) {
      _controller.mediaChange.addListener(() {
        final data = _controller.mediaChange.value!;
        widget.onMediaChange!(data.$1.index, data.$1.position, data.$2);
      });
    }
    _controller.willSkip.addListener(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Align(
          alignment: Alignment.bottomRight,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
              child: Text(widget.localizations.willSkipEnding),
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 15),
      ));
    });
    _controller.error.addListener(() {
      if (_controller.error.value != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            _controller.error.value!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          showCloseIcon: true,
          closeIconColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // todo: bug when SDK < 29
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _subscription?.cancel();
    _isShowControls.dispose();
    _isLocked.dispose();
    _progressFocusNode.dispose();
    _controlsStream.close();
    _progressController.dispose();
    super.dispose();
  }

  Widget _buildDraw(BuildContext context) {
    return Drawer(child: PlayerSettings(controller: _controller, actions: widget.actions, localizations: widget.localizations));
  }

  Widget _buildControlsPanel(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black26, Colors.black26, Colors.transparent],
              stops: [0, 0.3, 0.7, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.isTV ? 72 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PlayerInfoView(_controller),
                      const SizedBox(height: 30),
                      PlayerButtons(
                        controller: _controller,
                        isTV: widget.isTV,
                        onActionPlaylist: _showPlaylist,
                        onActionMore: _showActionMore,
                        cast: widget.cast,
                      ),
                      PlayerProgressView(
                        _progressController,
                        seekStart: () => _controller.pause(),
                        seekEnd: (position) {
                          _controller.seekTo(position);
                          _controller.play();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!widget.isTV)
            Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    onPressed: () {
                      _isLocked.value = !_isLocked.value;
                    },
                    icon: const Icon(Icons.lock_open))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: widget.theme != null ? Color(widget.theme!) : Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      child: Builder(builder: (context) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          endDrawerEnableOpenDragGesture: false,
          endDrawer: _buildDraw(context),
          resizeToAvoidBottomInset: false,
          floatingActionButton: !widget.isTV
              ? ListenableBuilder(
                  listenable: Listenable.merge([_isShowControls, _isLocked]),
                  builder: (context, _) => PageTransitionSwitcher(
                        reverse: !_isShowControls.value,
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation,
                        ) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.vertical,
                            fillColor: Colors.transparent,
                            child: child,
                          );
                        },
                        child: _isShowControls.value && !_isLocked.value
                            ? Container(margin: const EdgeInsets.only(top: 16), child: const BackButton())
                            : const SizedBox(),
                      ))
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
          body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) {
                return;
              } else if (_scaffoldKey.currentState!.isEndDrawerOpen) {
                _scaffoldKey.currentState!.closeEndDrawer();
              } else if (_isLocked.value) {
                _controlsStream.add(ControlsStreamStatus.show);
              } else if (_progressController.seeking) {
                _progressController.endSeek(context);
                _controller.play();
              } else if (!kIsWeb &&
                  widget.isTV &&
                  _isShowControls.value &&
                  (_controller.status.value == PlayerStatus.playing || _controller.status.value == PlayerStatus.buffering)) {
                _controlsStream.add(ControlsStreamStatus.hide);
              } else {
                if (widget.onMediaChange != null && _controller.duration.value > Duration.zero) {
                  widget.onMediaChange!(_controller.index.value, _controller.position.value, _controller.duration.value);
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Stack(
              children: [
                ListenableBuilder(
                    listenable: _controller.isCasting,
                    builder: (context, _) {
                      if (!_controller.isCasting.value) {
                        return PlayerPlatformView(options: widget.options);
                      } else {
                        return const SizedBox();
                      }
                    }),
                ListenableBuilder(
                    listenable: Listenable.merge([_isLocked, _controller.pipMode]),
                    builder: (context, _) {
                      if (_isLocked.value && !_controller.pipMode.value) {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _toggleControls,
                          child: PlayerZoomWrapper(
                            controller: _controller,
                            child: ListenableBuilder(
                                listenable: Listenable.merge([_isShowControls, _controller.pipMode]),
                                builder: (context, child) => _isShowControls.value && !_controller.pipMode.value
                                    ? Align(alignment: Alignment.centerRight, child: child)
                                    : const SizedBox.expand(),
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(onPressed: () => _isLocked.value = !_isLocked.value, icon: const Icon(Icons.lock_outline)))),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: _toggleControls,
                          child: FocusScope(
                            autofocus: true,
                            canRequestFocus: true,
                            onKeyEvent: (node, event) {
                              if (!_isShowControls.value && event is KeyUpEvent) {
                                switch (event.logicalKey) {
                                  case LogicalKeyboardKey.arrowUp:
                                  case LogicalKeyboardKey.arrowDown:
                                  case LogicalKeyboardKey.arrowLeft:
                                  case LogicalKeyboardKey.arrowRight:
                                  case LogicalKeyboardKey.select:
                                    _controlsStream.add(ControlsStreamStatus.show);
                                  case LogicalKeyboardKey.contextMenu:
                                    _showPlaylist(context);
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: ListenableBuilder(
                                listenable: Listenable.merge([_isShowControls, _controller.pipMode]),
                                builder: (context, child) => PageTransitionSwitcher(
                                      reverse: !_isShowControls.value,
                                      duration: const Duration(milliseconds: 500),
                                      transitionBuilder: (
                                        Widget child,
                                        Animation<double> animation,
                                        Animation<double> secondaryAnimation,
                                      ) {
                                        return SharedAxisTransition(
                                          animation: animation,
                                          secondaryAnimation: secondaryAnimation,
                                          transitionType: SharedAxisTransitionType.vertical,
                                          fillColor: Colors.transparent,
                                          child: child,
                                        );
                                      },
                                      child: _isShowControls.value && !_controller.pipMode.value
                                          ? child!
                                          : PlayerGestureOverlay(
                                              controller: _controller,
                                              child: ListenableBuilder(
                                                listenable: _controller.status,
                                                builder: (context, child) =>
                                                    _controller.status.value == PlayerStatus.buffering ? child! : const SizedBox.expand(),
                                                child: Center(
                                                    child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const SizedBox.square(dimension: 24, child: CircularProgressIndicator()),
                                                    const SizedBox(width: 10),
                                                    ListenableBuilder(
                                                        listenable: _controller.networkSpeed,
                                                        builder: (context, _) => Text(_controller.networkSpeed.value.toNetworkSpeed(),
                                                            style: Theme.of(context).textTheme.labelLarge))
                                                  ],
                                                )),
                                              ),
                                            ),
                                    ),
                                child: _buildControlsPanel(context)),
                          ),
                        );
                      }
                    }),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _toggleControls() {
    if (_isShowControls.value) {
      _controlsStream.add(ControlsStreamStatus.hide);
    } else {
      _controlsStream.add(ControlsStreamStatus.show);
    }
  }

  _showPlaylist(BuildContext context) async {
    _controlsStream.add(ControlsStreamStatus.showInfinite);
    await showDialog(
        context: context,
        builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                height: 200,
                child: PlayerPlaylistView(
                  activeIndex: _controller.index.value,
                  playlist: _controller.playlist,
                  onTap: _controller.next,
                  playlistItemBuilder: widget.playlistItemBuilder,
                ),
              ),
            ));
    _controlsStream.add(ControlsStreamStatus.show);
  }

  _showActionMore() {
    _scaffoldKey.currentState!.openEndDrawer();
  }
}

class PlayerGestureOverlay extends StatefulWidget {
  final Widget child;
  final PlayerController controller;

  const PlayerGestureOverlay({super.key, required this.child, required this.controller});

  @override
  State<PlayerGestureOverlay> createState() => _PlayerGestureOverlayState();
}

class _PlayerGestureOverlayState extends State<PlayerGestureOverlay> {
  final position = ValueNotifier(Duration.zero);
  final duration = ValueNotifier(Duration.zero);
  late final volume = ValueNotifier(widget.controller.volume.value);
  final showPositionOverlay = ValueNotifier(false);
  final showVolumeOverlay = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: (details) {
            if (details.globalPosition.dy > 100 && MediaQuery.of(context).size.height - details.globalPosition.dy > 100) {
              showVolumeOverlay.value = true;
            }
          },
          onVerticalDragUpdate: (details) {
            if (showVolumeOverlay.value) {
              volume.value -= details.delta.dy / 300;
              volume.value = volume.value.clamp(0, 1);
              widget.controller.setVolume(volume.value);
            }
          },
          onVerticalDragEnd: (details) {
            if (showVolumeOverlay.value) {
              showVolumeOverlay.value = false;
            }
          },
          onHorizontalDragStart: (details) {
            if (details.globalPosition.dx > 100 && MediaQuery.of(context).size.width - details.globalPosition.dx > 100) {
              position.value = widget.controller.position.value;
              duration.value = widget.controller.duration.value;
              showPositionOverlay.value = true;
            }
          },
          onHorizontalDragUpdate: (details) {
            if (showPositionOverlay.value) {
              position.value += Duration(seconds: details.delta.dx.toInt());
              position.value = position.value.clamp(Duration.zero, duration.value);
            }
          },
          onHorizontalDragEnd: (details) {
            if (showPositionOverlay.value) {
              showPositionOverlay.value = false;
              widget.controller.seekTo(position.value);
            }
          },
          onHorizontalDragCancel: () {
            showPositionOverlay.value = false;
          },
          child: widget.child,
        ),
        ListenableBuilder(
          listenable: showPositionOverlay,
          builder: (context, child) => showPositionOverlay.value ? child! : Container(),
          child: IgnorePointer(
            child: Center(
              child: Container(
                clipBehavior: Clip.antiAlias,
                constraints: const BoxConstraints(maxWidth: 200),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                child: ListenableBuilder(
                    listenable: position,
                    builder: (context, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                            child: Text('${position.value.toDisplay()} / ${duration.value.toDisplay()}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          ),
                          LinearProgressIndicator(value: position.value / duration.value, minHeight: 6)
                        ],
                      );
                    }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PlayerZoomWrapper extends StatefulWidget {
  final PlayerController controller;
  final Widget child;

  const PlayerZoomWrapper({super.key, required this.controller, required this.child});

  @override
  State<PlayerZoomWrapper> createState() => _PlayerZoomWrapperState();
}

class _PlayerZoomWrapperState extends State<PlayerZoomWrapper> {
  late final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
  final _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    widget.controller.setTransform([1, 0, 0, 0, 1, 0, 0, 0, 1]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(300),
          onInteractionUpdate: (details) {
            final matrix = _transformationController.value;
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
          },
          child: const SizedBox.expand(),
        ),
        widget.child,
      ],
    );
  }
}

class PlayerButtons extends StatelessWidget {
  final PlayerController controller;
  final bool isTV;
  final VoidCallback? onActionMore;
  final Function(BuildContext)? onActionPlaylist;
  final Cast? cast;

  const PlayerButtons({
    super.key,
    required this.controller,
    required this.isTV,
    this.onActionMore,
    this.onActionPlaylist,
    this.cast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ListenableBuilder(
            listenable: controller.isFirst,
            builder: (context, child) => controller.isFirst.value ? const SizedBox() : child!,
            child: IconButton(onPressed: () => controller.next(controller.index.value - 1), icon: const Icon(Icons.skip_previous_rounded))),
        if (isTV)
          ListenableBuilder(
              listenable: controller.status,
              builder: (context, _) {
                return IconButton(
                  onPressed: switch (controller.status.value) {
                    PlayerStatus.playing || PlayerStatus.paused || PlayerStatus.buffering => () =>
                        controller.seekTo(controller.position.value - const Duration(seconds: 10)),
                    _ => null,
                  },
                  icon: const Icon(Icons.fast_rewind_rounded),
                );
              }),
        ListenableBuilder(
            listenable: controller.status,
            builder: (context, _) {
              return switch (controller.status.value) {
                PlayerStatus.playing => IconButton(onPressed: controller.pause, icon: const Icon(Icons.pause)),
                PlayerStatus.buffering => SizedBox(width: 48, child: Center(child: Transform.scale(scale: 0.5, child: const CircularProgressIndicator()))),
                PlayerStatus.paused ||
                PlayerStatus.idle ||
                PlayerStatus.ended =>
                  IconButton(onPressed: controller.play, icon: const Icon(Icons.play_arrow_rounded)),
                PlayerStatus.error => IconButton(onPressed: null, icon: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error)),
              };
            }),
        if (isTV)
          ListenableBuilder(
              listenable: controller.status,
              builder: (context, _) {
                return IconButton(
                  onPressed: switch (controller.status.value) {
                    PlayerStatus.playing || PlayerStatus.paused || PlayerStatus.buffering => () =>
                        controller.seekTo(controller.position.value + const Duration(seconds: 10)),
                    _ => null,
                  },
                  icon: const Icon(Icons.fast_forward_rounded),
                );
              }),
        ListenableBuilder(
            listenable: controller.isLast,
            builder: (context, child) => controller.isLast.value ? const SizedBox() : child!,
            child: IconButton(onPressed: () => controller.next(controller.index.value + 1), icon: const Icon(Icons.skip_next_rounded))),
        const SizedBox(width: 12),
        const Spacer(),
        if (!isTV && cast != null)
          IconButton(
              onPressed: () async {
                final device = await _showCastModal(context);
                if (device != null) {
                  await controller.pause();
                  if (!context.mounted) return;
                  if (controller.currentItem.sourceType != PlaylistItemSourceType.hls) {
                    controller.playlist[controller.index.value] = controller.currentItem
                        .copyWith(start: controller.position.value > controller.currentItem.start ? controller.position.value : controller.currentItem.start);
                  }
                  controller.isCasting.value = true;
                  final resp = await Navigator.of(context).push<(int, Duration)>(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => PlayerCast(
                      device: device,
                      playlist: controller.playlist,
                      index: controller.index.value,
                      isTV: isTV,
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeOut;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ));
                  if (resp != null && context.mounted) {
                    if (controller.isCasting.value) {
                      controller.index.value = resp.$1;
                      if (controller.playlist[resp.$1].sourceType != PlaylistItemSourceType.hls) {
                        controller.playlist[resp.$1] = controller.playlist[resp.$1]
                            .copyWith(start: resp.$2 > controller.playlist[resp.$1].start ? resp.$2 : controller.playlist[resp.$1].start);
                      }
                      controller.isCasting.value = false;
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                    }
                  }
                }
              },
              icon: const Icon(Icons.airplay_rounded)),
        if (onActionPlaylist != null && controller.playlist.length > 1)
          IconButton(onPressed: () => onActionPlaylist!(context), icon: const Icon(Icons.playlist_play_rounded)),
        ListenableBuilder(
            listenable: controller.canPip,
            builder: (context, child) => controller.canPip.value ? child! : const SizedBox(),
            child: IconButton(onPressed: _requestPip, icon: const Icon(Icons.picture_in_picture_rounded))),
        if (kIsWeb) IconButton(onPressed: () => controller.requestFullscreen(), icon: const Icon(Icons.fullscreen_rounded)),
        if (onActionMore != null) IconButton(onPressed: onActionMore, icon: const Icon(Icons.more_vert))
      ],
    );
  }

  void _requestPip() async {
    await controller.requestPip();
  }

  Future<CastDevice?> _showCastModal(BuildContext context) {
    return showModalBottomSheet<CastDevice>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(3.0))),
      builder: (context) => PlayerCastSearcher(cast!),
    );
  }
}

class PlayerLocalizations {
  final String settingsTitle;
  final String videoSettingsVideo;
  final String videoSettingsAudio;
  final String videoSettingsSubtitle;
  final String videoSettingsSpeeding;
  final String videoSettingsNone;
  final String videoSize;
  final String tagUnknown;
  final String willSkipEnding;

  const PlayerLocalizations({
    required this.settingsTitle,
    required this.videoSettingsVideo,
    required this.videoSettingsAudio,
    required this.videoSettingsSubtitle,
    required this.videoSettingsSpeeding,
    required this.videoSettingsNone,
    required this.videoSize,
    required this.tagUnknown,
    required this.willSkipEnding,
  });
}

class PlayerSettings extends StatelessWidget {
  final PlayerController controller;
  final PlayerLocalizations localizations;

  final List<ListTile> Function(BuildContext)? actions;

  const PlayerSettings({
    super.key,
    required this.controller,
    this.actions,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: controller.trackGroup,
        builder: (context, _) => ListView(
              children: [
                const Focus(autofocus: true, child: SizedBox()),
                DrawerHeader(child: Text(localizations.settingsTitle)),
                if (controller.trackGroup.value.video.isNotEmpty)
                  _buildTrackSelector(context,
                      label: localizations.videoSettingsVideo,
                      tracks: controller.trackGroup.value.video,
                      selected: controller.trackGroup.value.selectedVideo,
                      onSelected: (id) => controller.setTrack('video', id)),
                if (controller.trackGroup.value.audio.isNotEmpty)
                  _buildTrackSelector(context,
                      label: localizations.videoSettingsAudio,
                      tracks: controller.trackGroup.value.audio,
                      selected: controller.trackGroup.value.selectedAudio,
                      onSelected: (id) => controller.setTrack('audio', id)),
                if (controller.trackGroup.value.sub.isNotEmpty)
                  _buildTrackSelector(context,
                      label: localizations.videoSettingsSubtitle,
                      tracks: controller.trackGroup.value.sub,
                      selected: controller.trackGroup.value.selectedSub,
                      onSelected: (id) => controller.setTrack('sub', id)),
                ListenableBuilder(
                    listenable: controller.playbackSpeed,
                    builder: (context, _) => PopupMenuButton(
                          onSelected: (speed) => controller.setPlaybackSpeed(speed),
                          child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [Text(localizations.videoSettingsSpeeding), Text(' ${controller.playbackSpeed.value}x')],
                              ),
                              trailing: const Icon(Icons.chevron_right)),
                          itemBuilder: (context) => playerSpeedList
                              .map((playerSpeed) => CheckedPopupMenuItem(
                                  checked: controller.playbackSpeed.value == playerSpeed.value, value: playerSpeed.value, child: Text(playerSpeed.text)))
                              .toList(),
                        )),
                const Divider(),
                ListenableBuilder(
                    listenable: controller.aspectRatio,
                    builder: (context, _) {
                      return PopupMenuButton(
                        onSelected: (aspectRatio) {
                          controller.aspectRatio.value = aspectRatio;
                          controller.setAspectRatio(aspectRatio.value(context));
                        },
                        child: ListTile(
                          leading: const Icon(Icons.aspect_ratio_rounded),
                          title: Text(localizations.videoSize),
                          trailing: Text(controller.aspectRatio.value.label(context)),
                        ),
                        itemBuilder: (context) => AspectRatioType.values
                            .map((aspectRatio) => CheckedPopupMenuItem(
                                  checked: controller.aspectRatio.value == aspectRatio,
                                  value: aspectRatio,
                                  child: Text(aspectRatio.label(context)),
                                ))
                            .toList(),
                      );
                    }),
                const Divider(),
                if (actions != null) ...actions!(context),
                if (actions != null) const Divider(),
                ListenableBuilder(
                  listenable: controller.mediaInfo,
                  builder: (context, _) => controller.mediaInfo.value == null
                      ? Container()
                      : DefaultTextStyle(
                          style: Theme.of(context).textTheme.bodySmall!,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Table(
                              columnWidths: const <int, TableColumnWidth>{
                                0: FixedColumnWidth(60),
                                1: FlexColumnWidth(),
                              },
                              children: [
                                TableRow(children: [Text('Video', style: Theme.of(context).textTheme.titleSmall), Container()]),
                                TableRow(children: [const Text('Codecs'), Text(controller.mediaInfo.value!.videoCodecs ?? localizations.tagUnknown)]),
                                TableRow(children: [const Text('Mime'), Text(controller.mediaInfo.value!.videoMime ?? localizations.tagUnknown)]),
                                TableRow(children: [const Text('FPS'), Text(controller.mediaInfo.value!.videoFPS?.toString() ?? localizations.tagUnknown)]),
                                TableRow(children: [const Text('Size'), Text(controller.mediaInfo.value!.videoSize ?? localizations.tagUnknown)]),
                                TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('Audio', style: Theme.of(context).textTheme.titleSmall),
                                  ),
                                  Container()
                                ]),
                                TableRow(children: [const Text('Codecs'), Text(controller.mediaInfo.value!.audioCodecs ?? localizations.tagUnknown)]),
                                TableRow(children: [const Text('Mime'), Text(controller.mediaInfo.value!.audioMime ?? localizations.tagUnknown)]),
                                TableRow(
                                    children: [const Text('Bitrate'), Text(controller.mediaInfo.value!.audioBitrate?.toString() ?? localizations.tagUnknown)]),
                              ],
                            ),
                          ),
                        ),
                ),
                const Focus(child: SizedBox()),
              ],
            ));
  }

  Widget _buildTrackSelector(
    BuildContext context, {
    required String label,
    required List<MediaTrack> tracks,
    dynamic selected,
    required Function(String?) onSelected,
  }) {
    final selectedTrack = tracks.firstWhereOrNull((v) => v.id == selected);
    return PopupMenuButton(
        onSelected: onSelected,
        itemBuilder: (context) => [
              CheckedPopupMenuItem(
                checked: selected == null,
                value: null,
                child: Text(localizations.videoSettingsNone),
              ),
              ...tracks.map((e) => CheckedPopupMenuItem(
                    checked: selected == e.id,
                    value: e.id,
                    child: Text(e.label ?? localizations.tagUnknown),
                  ))
            ],
        child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(selectedTrack?.label ?? localizations.videoSettingsNone, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right)));
  }
}

class PlayerPlaylistView extends StatefulWidget {
  final List<PlaylistItem> playlist;
  final void Function(int) onTap;
  final int activeIndex;
  final Widget Function(BuildContext, int index, void Function(int) onTap)? playlistItemBuilder;

  const PlayerPlaylistView({super.key, required this.playlist, required this.onTap, required this.activeIndex, this.playlistItemBuilder});

  @override
  State<PlayerPlaylistView> createState() => _PlayerPlaylistViewState();
}

class _PlayerPlaylistViewState extends State<PlayerPlaylistView> {
  late final _controller = ScrollController(initialScrollOffset: widget.activeIndex * 200 - 100);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 48),
        itemCount: widget.playlist.length,
        itemBuilder: (context, index) {
          if (widget.playlistItemBuilder != null) {
            return widget.playlistItemBuilder!(context, index, widget.onTap);
          }
          final item = widget.playlist[index];
          return SizedBox(
            width: 200,
            child: InkWell(
              autofocus: index == widget.activeIndex,
              onTap: () => widget.onTap(index),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: item.poster != null
                        ? Image.network(item.poster!)
                        : Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(0x11),
                            child: const Icon(Icons.image_not_supported, size: 50)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.title != null) Text(item.title!, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                        if (item.description != null) Text(item.description!, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 16),
      ),
    );
  }
}

class PlayerPlatformView extends StatefulWidget {
  final Map<String, dynamic>? options;

  const PlayerPlatformView({super.key, this.options});

  @override
  State<PlayerPlatformView> createState() => _PlayerPlatformViewState();
}

class _PlayerPlatformViewState extends State<PlayerPlatformView> {
  @override
  void didChangeDependencies() {
    PlayerPlatform.instance.init({
      ...?widget.options,
      'language': Localizations.localeOf(context).languageCode,
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    PlayerPlatform.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class PlayerInfoView extends StatelessWidget {
  final PlayerController _controller;
  final bool showPoster;

  const PlayerInfoView(this._controller, {super.key, this.showPoster = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: ListenableBuilder(
          builder: (context, _) => OrientationBuilder(builder: (context, orientation) {
                return switch (MediaQuery.of(context).orientation) {
                  Orientation.portrait => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_controller.title.value != null)
                          Text(_controller.title.value!, style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 10),
                        Text(_controller.subTitle.value, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                        ListenableBuilder(
                            listenable: _controller.status,
                            builder: (context, _) {
                              return switch (_controller.status.value) {
                                PlayerStatus.buffering => ListenableBuilder(
                                    listenable: _controller.networkSpeed,
                                    builder: (context, child) =>
                                        Text(_controller.networkSpeed.value.toNetworkSpeed(), style: Theme.of(context).textTheme.labelSmall)),
                                _ => Text(' ', style: Theme.of(context).textTheme.labelSmall),
                              };
                            }),
                        if (_controller.fatalError.value != null)
                          Text(_controller.fatalError.value!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  Orientation.landscape => Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (showPoster && _controller.currentItem.poster != null) _AsyncImage(_controller.currentItem.poster!, height: 100, radius: 4),
                        if (showPoster && _controller.currentItem.poster != null) const SizedBox(width: 30),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_controller.title.value != null)
                                Text(_controller.title.value!, style: Theme.of(context).textTheme.displaySmall, overflow: TextOverflow.ellipsis, maxLines: 2),
                              const SizedBox(height: 10),
                              Text(_controller.subTitle.value, style: Theme.of(context).textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
                              ListenableBuilder(
                                  listenable: _controller.status,
                                  builder: (context, _) {
                                    return switch (_controller.status.value) {
                                      PlayerStatus.buffering => ListenableBuilder(
                                          listenable: _controller.networkSpeed,
                                          builder: (context, child) =>
                                              Text(_controller.networkSpeed.value.toNetworkSpeed(), style: Theme.of(context).textTheme.labelSmall)),
                                      _ => Text(' ', style: Theme.of(context).textTheme.labelSmall),
                                    };
                                  }),
                              if (_controller.fatalError.value != null)
                                Text(_controller.fatalError.value!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            ],
                          ),
                        ),
                      ],
                    )
                };
              }),
          listenable: Listenable.merge([_controller.title, _controller.fatalError])),
    );
  }
}

class _ThumbnailsList extends StatefulWidget {
  final ScrollController scrollController;
  final int itemCount;
  final Future<String?> Function(int) getVideoThumbnail;
  final int? theme;

  const _ThumbnailsList({
    required this.scrollController,
    required this.itemCount,
    required this.getVideoThumbnail,
    this.theme,
  });

  @override
  State<_ThumbnailsList> createState() => _ThumbnailsListState();
}

class _ThumbnailsListState extends State<_ThumbnailsList> with TickerProviderStateMixin {
  late final _scrollController = widget.scrollController;
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
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: widget.theme != null ? Color(widget.theme!) : Colors.blue, brightness: Brightness.dark),
      ),
      child: Builder(builder: (context) {
        return Center(
          child: SizedBox(
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ListView.separated(
                  cacheExtent: 0,
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - 150) / 2),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => AspectRatio(
                    aspectRatio: 1.5,
                    child: FutureBuilder(
                      future: widget.getVideoThumbnail(30000 * index + 15000),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (kIsWeb) {
                            return Image.network(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, _) => Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: Icon(Icons.broken_image_outlined, size: 40, color: Theme.of(context).colorScheme.primaryContainer),
                              ),
                            );
                          } else {
                            return Image.file(
                              File(snapshot.data!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, _) => Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: Icon(Icons.broken_image_outlined, size: 40, color: Theme.of(context).colorScheme.primaryContainer),
                              ),
                            );
                          }
                        } else {
                          if (snapshot.connectionState != ConnectionState.done) {
                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, _) => Container(
                                color: Color.lerp(
                                  Theme.of(context).colorScheme.surface,
                                  Theme.of(context).colorScheme.surfaceContainerHighest,
                                  _animationController.value,
                                ),
                                child: Icon(Icons.image_outlined, size: 40, color: Theme.of(context).colorScheme.primaryContainer),
                              ),
                            );
                          } else {
                            return Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: Icon(Icons.broken_image_outlined, size: 40, color: Theme.of(context).colorScheme.primaryContainer),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  itemCount: widget.itemCount,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
                ),
                AspectRatio(
                  aspectRatio: 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 4, color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}

class PlayerProgressController extends ChangeNotifier {
  Duration duration = Duration.zero;
  Duration buffered = Duration.zero;
  Duration position = Duration.zero;
  Duration cachedPosition = Duration.zero;
  PlayerStatus status = PlayerStatus.buffering;
  bool seeking = false;
  final Future<String?> Function(int)? getVideoThumbnail;
  final int? theme;
  final bool showThumbnails;
  ScrollController scrollController = ScrollController();

  PlayerProgressController({
    this.getVideoThumbnail,
    showThumbnails,
    this.theme,
  }) : showThumbnails = showThumbnails ?? false;

  @override
  void dispose() {
    if (entry.mounted) entry.dispose();
    scrollController.dispose();
    super.dispose();
  }

  late final entry = OverlayEntry(
    builder: (context) => Theme(
        data: Theme.of(context),
        child: _ThumbnailsList(
          scrollController: scrollController,
          getVideoThumbnail: getVideoThumbnail!,
          itemCount: (duration.inMilliseconds / 30000).ceil(),
          theme: theme,
        )),
  );

  setStatus(PlayerStatus status) {
    if (this.status != status) {
      this.status = status;
      notifyListeners();
    }
  }

  setPosition(Duration position) {
    if (this.position != position) {
      this.position = position;
      notifyListeners();
    }
  }

  setDuration(Duration duration) {
    if (this.duration != duration) {
      this.duration = duration;
      notifyListeners();
    }
  }

  setBuffered(Duration buffered) {
    if (this.buffered != buffered) {
      this.buffered = buffered;
      notifyListeners();
    }
  }

  startSeek(BuildContext context) {
    if (status == PlayerStatus.error || status == PlayerStatus.idle) {
      return;
    }
    if (duration == Duration.zero) {
      return;
    }
    seeking = true;
    cachedPosition = position;
    scrollController.dispose();
    scrollController = ScrollController(initialScrollOffset: calcOffset());
    notifyListeners();
    if (showThumbnails) {
      if (entry.mounted) entry.remove();
      Overlay.maybeOf(context)?.insert(entry);
    }
  }

  updateSeek(BuildContext context, Duration position) {
    cachedPosition = position.clamp(Duration.zero, duration);
    notifyListeners();
    if (showThumbnails && scrollController.hasClients) {
      final offset = calcOffset();
      if (offset != scrollController.offset) {
        scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  endSeek(BuildContext context) {
    seeking = false;
    notifyListeners();
    if (showThumbnails) {
      if (entry.mounted) entry.remove();
    }
  }

  double calcOffset() {
    const width = 150.0;
    const gap = 10;
    final index = (cachedPosition.inMilliseconds / 30000).floor();
    final offset = (width + gap) * index;
    final max = (duration.inMilliseconds / 30000 + 1).floor() * (width + gap) - gap;
    return offset.clamp(0.0, max);
  }
}

class PlayerProgressView extends StatefulWidget {
  final VoidCallback? seekStart;
  final Function(Duration)? seekEnd;
  final PlayerProgressController controller;

  const PlayerProgressView(this.controller, {super.key, this.seekStart, this.seekEnd});

  @override
  State<PlayerProgressView> createState() => _PlayerProgressViewState();
}

class _PlayerProgressViewState extends State<PlayerProgressView> {
  late final PlayerProgressController _controller = widget.controller;

  @override
  void initState() {
    _controller.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Center(
        child: AnimatedScale(
          scale: _controller.seeking ? 1.05 : 1,
          duration: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  onTapDown: (e) {
                    if (!_controller.seeking) {
                      _controller.startSeek(context);
                      if (_controller.seeking) {
                        widget.seekStart?.call();
                      }
                    }
                  },
                  onHorizontalDragStart: (e) {
                    if (!_controller.seeking) {
                      _controller.startSeek(context);
                      if (_controller.seeking) {
                        widget.seekStart?.call();
                      }
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_controller.seeking) {
                      final RenderBox box = context.findRenderObject()! as RenderBox;
                      final frac = details.delta.dx / box.size.width;
                      _controller.updateSeek(context, _controller.cachedPosition + _controller.duration * frac);
                    }
                  },
                  onHorizontalDragEnd: (e) {
                    if (_controller.seeking) {
                      widget.seekEnd?.call(_controller.cachedPosition);
                      _controller.endSeek(context);
                    }
                  },
                  onTapUp: (e) {
                    if (_controller.seeking) {
                      widget.seekEnd?.call(_controller.cachedPosition);
                      _controller.endSeek(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: _controller.seeking ? 16 : 12,
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Container(color: Theme.of(context).colorScheme.surface),
                          AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 200),
                              widthFactor: _controller.buffered / _controller.duration ?? 0,
                              child: Container(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
                          if (_controller.status == PlayerStatus.error || _controller.status == PlayerStatus.idle)
                            Container(color: Theme.of(context).colorScheme.errorContainer)
                          else if (_controller.seeking)
                            AnimatedFractionallySizedBox(
                                duration: const Duration(milliseconds: 100),
                                widthFactor: _controller.cachedPosition / _controller.duration ?? 0,
                                child: Container(color: Theme.of(context).colorScheme.primary))
                          else
                            FractionallySizedBox(
                                widthFactor: max(_controller.position / _controller.duration ?? 0, 0),
                                child: Container(color: Theme.of(context).colorScheme.primary))
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_controller.seeking ? _controller.cachedPosition.toDisplay() : _controller.position.toDisplay()),
                    if (!_controller.seeking) Text(_controller.duration.toDisplay()),
                    if (_controller.seeking) Text('-${(_controller.duration - _controller.cachedPosition).toDisplay()}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  update() {
    setState(() {});
  }
}

extension DurationDivision on Duration {
  double? operator /(Duration other) {
    if (other == Duration.zero) {
      return null;
    } else {
      return inMilliseconds / other.inMilliseconds;
    }
  }
}

extension on Duration {
  String toDisplay() {
    if (inHours > 0) {
      return '$inHours:${inMinutes.remainder(60).toString().padLeft(2, '0')}:${inSeconds.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return '${inMinutes.remainder(60).toString().padLeft(2, '0')}:${inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
  }

  Duration clamp(Duration min, Duration max) {
    assert(min <= max);
    if (this < min) {
      return min;
    } else if (this > max) {
      return max;
    } else {
      return this;
    }
  }
}

class _AsyncImage extends StatelessWidget {
  final String src;
  final double? height;
  final double radius;

  const _AsyncImage(
    this.src, {
    this.height,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: CachedNetworkImage(
        imageUrl: src,
        alignment: Alignment.center,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        height: height,
        httpHeaders: const {_headerUserAgent: _ua},
        errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, size: 36)),
      ),
    );
  }
}

const _headerUserAgent = 'User-Agent';
const _ua = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.83 Safari/537.36';

extension on int {
  String toNetworkSpeed() {
    return switch (this) {
      < 1000 => '$this B/s',
      < 1000000 => '${double.parse((this / 1000).toStringAsFixed(2))} KB/s',
      < 1000000000 => '${double.parse((this / 1000000).toStringAsFixed(2))} MB/s',
      < 1000000000000 => '${double.parse((this / 1000000000).toStringAsFixed(2))} GB/s',
      _ => '',
    };
  }
}
