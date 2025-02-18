import 'dart:async';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/player.dart';

import '../../const.dart';
import '../components/icon_button.dart';
import '../components/loading.dart';
import '../components/setting.dart';
import '../utils/utils.dart';

class PlayerControls extends StatefulWidget {
  final int? theme;
  final void Function(int, Duration, Duration)? onMediaChange;
  final PlayerController controller;
  final List<Widget> Function(BuildContext)? actions;
  final PlayerLocalizations localizations;
  final Duration seekStep;
  final bool? showThumbnails;
  final Map<String, dynamic>? options;

  final Widget Function(BuildContext, int index, void Function(int) onTap)? playlistItemBuilder;

  const PlayerControls({
    super.key,
    required this.controller,
    required this.localizations,
    this.onMediaChange,
    this.actions,
    this.theme,
    this.seekStep = const Duration(seconds: 30),
    this.options,
    this.showThumbnails,
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
  final _controlsStream = StreamController<ControlsStreamStatus>();
  final _navigatorKey = GlobalKey<NavigatorState>();
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
    _subscription?.cancel();
    _isShowControls.dispose();
    _progressFocusNode.dispose();
    _controlsStream.close();
    _progressController.dispose();
    super.dispose();
  }

  Widget _buildDraw(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) {
        _navigatorKey.currentState!.maybePop();
      },
      child: Container(
        width: 360,
        color: const Color(0xff202124),
        child: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (settings) => FadeInPageRoute(
              builder: (context) => PlayerSettings(
                    controller: _controller,
                    actions: widget.actions,
                    localizations: widget.localizations,
                  ),
              settings: settings),
        ),
      ),
    );
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
                  padding: const EdgeInsets.symmetric(horizontal: 72),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PlayerInfoView(_controller),
                      const SizedBox(height: 30),
                      PlayerButtons(
                        controller: _controller,
                        isTV: true,
                        onActionPlaylist: _showPlaylist,
                        onActionMore: _showActionMore,
                      ),
                      Focus(
                        autofocus: true,
                        focusNode: _progressFocusNode,
                        onKeyEvent: (node, event) => _onProgressKeyEvent(context, node, event),
                        onFocusChange: (focused) {
                          if (!focused) {
                            if (_progressController.seeking) {
                              _controller.play();
                            }
                            _progressController.endSeek(context);
                          }
                        },
                        child: PlayerProgressView(
                          _progressController,
                          seekStart: () => _controller.pause(),
                          seekEnd: (position) {
                            _controller.seekTo(position);
                            _controller.play();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  KeyEventResult _onProgressKeyEvent(BuildContext context, FocusNode node, KeyEvent event) {
    if (_progressFocusNode.hasFocus) {
      if (event is KeyDownEvent || event is KeyRepeatEvent) {
        _controlsStream.add(ControlsStreamStatus.show);
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowLeft:
            if (!_progressController.seeking) {
              _controller.pause();
              _progressController.startSeek(context);
            }
            _controlsStream.add(ControlsStreamStatus.showInfinite);
            _progressController.updateSeek(context, _progressController.cachedPosition - widget.seekStep);
            return KeyEventResult.handled;
          case LogicalKeyboardKey.arrowRight:
            if (!_progressController.seeking) {
              _controller.pause();
              _progressController.startSeek(context);
            }
            _controlsStream.add(ControlsStreamStatus.showInfinite);
            _progressController.updateSeek(context, _progressController.cachedPosition + widget.seekStep);
            return KeyEventResult.handled;
          case LogicalKeyboardKey.arrowUp:
            _controlsStream.add(ControlsStreamStatus.showInfinite);
            return KeyEventResult.ignored;
          case LogicalKeyboardKey.contextMenu:
            _showPlaylist(context);
            return KeyEventResult.handled;
          case LogicalKeyboardKey.select:
          case LogicalKeyboardKey.enter:
            if (_progressController.seeking) {
              _progressController.endSeek(context);
              _controller.seekTo(_progressController.cachedPosition);
              _controller.play();
            } else {
              if (_controller.status.value == PlayerStatus.playing) {
                _controller.pause();
                return KeyEventResult.handled;
              } else if (_controller.status.value == PlayerStatus.paused) {
                _controller.play();
                return KeyEventResult.handled;
              }
            }
        }
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context)
          .copyWith(colorScheme: ColorScheme.fromSeed(seedColor: widget.theme != null ? Color(widget.theme!) : Colors.blue, brightness: Brightness.dark)),
      child: Builder(builder: (context) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          endDrawerEnableOpenDragGesture: false,
          endDrawer: _buildDraw(context),
          resizeToAvoidBottomInset: false,
          body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) {
                return;
              } else if (_scaffoldKey.currentState!.isEndDrawerOpen) {
                if (!_navigatorKey.currentState!.canPop()) {
                  _scaffoldKey.currentState!.closeEndDrawer();
                }
              } else if (_progressController.seeking) {
                _progressController.endSeek(context);
                _controller.play();
              } else if (_isShowControls.value && (_controller.status.value == PlayerStatus.playing || _controller.status.value == PlayerStatus.buffering)) {
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
                GestureDetector(
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
                                  : ListenableBuilder(
                                      listenable: _controller.status,
                                      builder: (context, child) => _controller.status.value == PlayerStatus.buffering ? child! : const SizedBox.expand(),
                                      child: Center(
                                          child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Loading(color: Theme.of(context).colorScheme.primary),
                                          const SizedBox(width: 10),
                                          ListenableBuilder(
                                              listenable: _controller.networkSpeed,
                                              builder: (context, _) =>
                                                  Text(_controller.networkSpeed.value.toNetworkSpeed(), style: Theme.of(context).textTheme.labelLarge))
                                        ],
                                      )),
                                    ),
                            ),
                        child: _buildControlsPanel(context)),
                  ),
                ),
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
            child: TVIconButton(onPressed: () => controller.next(controller.index.value - 1), icon: const Icon(Icons.skip_previous_rounded))),
        if (isTV)
          ListenableBuilder(
              listenable: controller.status,
              builder: (context, _) {
                return TVIconButton(
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
                PlayerStatus.playing => TVIconButton(onPressed: controller.pause, icon: const Icon(Icons.pause)),
                PlayerStatus.buffering => SizedBox(width: 48, child: Center(child: Transform.scale(scale: 0.5, child: const CircularProgressIndicator()))),
                PlayerStatus.paused ||
                PlayerStatus.idle ||
                PlayerStatus.ended =>
                  TVIconButton(onPressed: controller.play, icon: const Icon(Icons.play_arrow_rounded)),
                PlayerStatus.error => TVIconButton(onPressed: null, icon: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error)),
              };
            }),
        if (isTV)
          ListenableBuilder(
              listenable: controller.status,
              builder: (context, _) {
                return TVIconButton(
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
            child: TVIconButton(onPressed: () => controller.next(controller.index.value + 1), icon: const Icon(Icons.skip_next_rounded))),
        const SizedBox(width: 12),
        const Spacer(),
        if (!isTV && cast != null)
          TVIconButton(
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
          TVIconButton(onPressed: () => onActionPlaylist!(context), icon: const Icon(Icons.playlist_play_rounded)),
        ListenableBuilder(
            listenable: controller.canPip,
            builder: (context, child) => controller.canPip.value ? child! : const SizedBox(),
            child: TVIconButton(onPressed: _requestPip, icon: const Icon(Icons.picture_in_picture_rounded))),
        if (kIsWeb) TVIconButton(onPressed: () => controller.requestFullscreen(), icon: const Icon(Icons.fullscreen_rounded)),
        if (onActionMore != null) TVIconButton(onPressed: onActionMore, icon: const Icon(Icons.more_vert))
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

class PlayerSettings extends StatelessWidget {
  final PlayerController controller;
  final PlayerLocalizations localizations;

  final List<Widget> Function(BuildContext)? actions;

  const PlayerSettings({
    super.key,
    required this.controller,
    this.actions,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: localizations.settingsTitle,
      child: ListenableBuilder(
          listenable: controller.trackGroup,
          builder: (context, _) => ListView(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
                children: [
                  if (controller.trackGroup.value.video.isNotEmpty)
                    _buildTrackSelector(context,
                        icon: const Icon(Icons.movie_outlined),
                        label: localizations.videoSettingsVideo,
                        tracks: controller.trackGroup.value.video,
                        selected: controller.trackGroup.value.selectedVideo,
                        onSelected: (id) => controller.setTrack('video', id)),
                  if (controller.trackGroup.value.audio.isNotEmpty)
                    _buildTrackSelector(context,
                        icon: const Icon(Icons.audiotrack_outlined),
                        label: localizations.videoSettingsAudio,
                        tracks: controller.trackGroup.value.audio,
                        selected: controller.trackGroup.value.selectedAudio,
                        onSelected: (id) => controller.setTrack('audio', id)),
                  if (controller.trackGroup.value.sub.isNotEmpty)
                    _buildTrackSelector(context,
                        icon: const Icon(Icons.subtitles_outlined),
                        label: localizations.videoSettingsSubtitle,
                        tracks: controller.trackGroup.value.sub,
                        selected: controller.trackGroup.value.selectedSub,
                        onSelected: (id) => controller.setTrack('sub', id)),
                  ListenableBuilder(
                      listenable: controller.playbackSpeed,
                      builder: (context, _) {
                        return ButtonSettingItem(
                          leading: const Icon(Icons.slow_motion_video_rounded),
                          title: Text(localizations.videoSettingsSpeeding),
                          trailing: Text('${controller.playbackSpeed.value}x'),
                          onTap: () {
                            Navigator.of(context).push(FadeInPageRoute(
                                builder: (context) => PlayerSubSettings(
                                    title: localizations.videoSettingsSpeeding,
                                    items: playerSpeedList
                                        .map((playerSpeed) => RadioSettingItem(
                                              autofocus: controller.playbackSpeed.value == playerSpeed.value,
                                              groupValue: controller.playbackSpeed.value,
                                              value: playerSpeed.value,
                                              title: Text(playerSpeed.text),
                                              onChanged: (speed) {
                                                controller.setPlaybackSpeed(speed!);
                                                Navigator.of(context).pop();
                                              },
                                            ))
                                        .toList())));
                          },
                        );
                      }),
                  const Divider(),
                  ListenableBuilder(
                      listenable: controller.aspectRatio,
                      builder: (context, _) {
                        return ButtonSettingItem(
                          leading: const Icon(Icons.aspect_ratio_rounded),
                          title: Text(localizations.videoSize),
                          trailing: Text(controller.aspectRatio.value.label(context)),
                          onTap: () {
                            Navigator.of(context).push(FadeInPageRoute(
                                builder: (context) => PlayerSubSettings(
                                    title: localizations.videoSize,
                                    items: AspectRatioType.values
                                        .map((aspectRatio) => RadioSettingItem(
                                              autofocus: aspectRatio == controller.aspectRatio.value,
                                              groupValue: controller.aspectRatio.value,
                                              value: aspectRatio,
                                              title: Text(aspectRatio.label(context)),
                                              onChanged: (_) {
                                                controller.aspectRatio.value = aspectRatio;
                                                controller.setAspectRatio(aspectRatio.value(context));
                                                Navigator.of(context).pop();
                                              },
                                            ))
                                        .toList())));
                          },
                        );
                      }),
                  const Divider(),
                  if (actions != null) ...actions!(context),
                  if (actions != null) const Divider(),
                  ListenableBuilder(
                    listenable: controller.mediaInfo,
                    builder: (context, _) => controller.mediaInfo.value == null
                        ? const SizedBox()
                        : DefaultTextStyle(
                            style: Theme.of(context).textTheme.bodySmall!,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                                  TableRow(children: [
                                    const Text('Bitrate'),
                                    Text(controller.mediaInfo.value!.audioBitrate?.toString() ?? localizations.tagUnknown)
                                  ]),
                                ],
                              ),
                            ),
                          ),
                  ),
                  const Focus(child: SizedBox()),
                ],
              )),
    );
  }

  Widget _buildTrackSelector(
    BuildContext context, {
    required Widget icon,
    required String label,
    required List<MediaTrack> tracks,
    dynamic selected,
    required Function(dynamic) onSelected,
  }) {
    final selectedTrack = tracks.firstWhereOrNull((v) => v.id == selected);
    return ButtonSettingItem(
      leading: icon,
      title: Text(label),
      trailing: Text(selectedTrack?.label ?? localizations.videoSettingsNone, overflow: TextOverflow.ellipsis),
      onTap: () {
        Navigator.of(context).push(FadeInPageRoute(
            builder: (context) => PlayerSubSettings(title: label, items: [
                  RadioSettingItem(
                    autofocus: selected == null,
                    groupValue: selected,
                    value: null,
                    title: Text(localizations.videoSettingsNone),
                    onChanged: (value) {
                      onSelected(value);
                      Navigator.of(context).pop();
                    },
                  ),
                  ...tracks.map((e) => RadioSettingItem(
                        autofocus: e.id == selected,
                        groupValue: selected,
                        value: e.id,
                        title: Text(e.label ?? localizations.tagUnknown),
                        onChanged: (value) {
                          onSelected(value);
                          Navigator.of(context).pop();
                        },
                      ))
                ])));
      },
    );
  }
}

class PlayerSubSettings extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const PlayerSubSettings({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SettingPage(
        title: title,
        child: ListView(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
          children: items,
        ),
      ),
    );
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
        httpHeaders: const {headerUserAgent: ua},
        errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image, size: 36)),
      ),
    );
  }
}

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
