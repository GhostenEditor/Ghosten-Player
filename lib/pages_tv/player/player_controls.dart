import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/player.dart';

import '../../components/async_image.dart';
import '../../components/future_builder_handler.dart';
import '../../components/playing_icon.dart';
import '../../l10n/app_localizations.dart';
import '../components/focusable.dart';
import '../components/focusable_image.dart';
import '../components/loading.dart';
import '../components/setting.dart';
import '../utils/utils.dart';

enum _PlayerPanelType { progressbar, playlist, none }

class PlayerControls extends StatefulWidget {
  const PlayerControls({
    super.key,
    required this.controller,
    this.onMediaChange,
    this.actions,
    this.theme,
    this.options,
    this.showThumbnails,
    this.playlistItemBuilder,
  });

  final int? theme;
  final void Function(int, Duration, Duration)? onMediaChange;
  final PlayerController<dynamic> controller;
  final List<Widget> Function(BuildContext)? actions;

  final bool? showThumbnails;
  final Map<String, dynamic>? options;

  final Widget Function(BuildContext, int index, void Function(int) onTap)? playlistItemBuilder;

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  late final _controller = widget.controller;
  late final _progressController = PlayerProgressController(_controller, theme: widget.theme);
  final _progressFocusNode = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controlsStream = StreamController<ControlsStreamStatus>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _panelType = ValueNotifier(_PlayerPanelType.none);
  Duration _seekStep = const Duration(seconds: 30);
  StreamSubscription<bool>? _subscription;
  bool _reverse = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then(
      (prefs) => _seekStep = Duration(seconds: PlayerConfig.getFastForwardSpeed(prefs)),
    );
    if (widget.onMediaChange != null) {
      _controller.beforeMediaChanged.addListener(() {
        final data = _controller.beforeMediaChanged.value!;
        widget.onMediaChange!(data.$1.index, data.$1.position, data.$2);
      });
    }
    _subscription = _controlsStream.stream
        .switchMap((status) {
          switch (status) {
            case ControlsStreamStatus.show:
              return ConcatStream([Stream.value(true), TimerStream(false, const Duration(seconds: 5))]);
            case ControlsStreamStatus.showInfinite:
              return Stream.value(true);
            case ControlsStreamStatus.hide:
              return Stream.value(false);
          }
        })
        .listen((show) {
          if (show) {
            switch (_panelType.value) {
              case _PlayerPanelType.none:
                _reverse = false;
                _panelType.value = _PlayerPanelType.progressbar;
              case _PlayerPanelType.progressbar:
              case _PlayerPanelType.playlist:
            }
          } else {
            if (_panelType.value != _PlayerPanelType.none) {
              _reverse = true;
              _panelType.value = _PlayerPanelType.none;
            }
          }
        });
    _controlsStream.add(ControlsStreamStatus.show);
    widget.controller.status.addListener(() {
      switch (widget.controller.status.value) {
        case PlayerStatus.error:
        case PlayerStatus.idle:
          _controlsStream.add(ControlsStreamStatus.showInfinite);
        case PlayerStatus.playing:
        case PlayerStatus.paused:
        case PlayerStatus.ended:
        case PlayerStatus.buffering:
          if (_panelType.value != _PlayerPanelType.none) {
            _controlsStream.add(ControlsStreamStatus.show);
          }
      }
    });

    _controller.willSkip.addListener(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Align(
            alignment: Alignment.bottomRight,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                child: Text(PlayerLocalizations.of(context).willSkipEnding),
              ),
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 15),
        ),
      );
    });
    _controller.error.addListener(() {
      if (_controller.error.value != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_controller.error.value!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            showCloseIcon: true,
            closeIconColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _progressFocusNode.dispose();
    _controlsStream.close();
    _progressController.dispose();
    _panelType.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorSchemeSeed: widget.theme != null ? Color(widget.theme!) : null,
        brightness: Brightness.dark,
        drawerTheme: const DrawerThemeData(endShape: RoundedRectangleBorder()),
      ),
      child: Builder(
        builder: (context) {
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
                  _controlsStream.add(ControlsStreamStatus.show);
                  _controller.play();
                } else if (_panelType.value != _PlayerPanelType.none) {
                  _controlsStream.add(ControlsStreamStatus.hide);
                } else {
                  if (widget.onMediaChange != null && _controller.duration.value > Duration.zero) {
                    widget.onMediaChange!(
                      _controller.index.value!,
                      _controller.position.value,
                      _controller.duration.value,
                    );
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ListenableBuilder(
                    listenable: _panelType,
                    builder:
                        (context, child) => PageTransitionSwitcher(
                          reverse: _reverse,
                          duration: const Duration(milliseconds: 500),
                          layoutBuilder: (List<Widget> entries) {
                            return Stack(alignment: Alignment.bottomCenter, children: entries);
                          },
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
                          child: _panelType.value == _PlayerPanelType.none ? const SizedBox() : child,
                        ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black45],
                          stops: [0.4, 1],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  ListenableBuilder(
                    listenable: _controller.status,
                    builder:
                        (context, child) => PageTransitionSwitcher(
                          duration: const Duration(milliseconds: 200),
                          layoutBuilder: (List<Widget> entries) {
                            return Stack(alignment: Alignment.bottomCenter, children: entries);
                          },
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
                          child: switch (_controller.status.value) {
                            PlayerStatus.buffering => Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 12,
                                children: [
                                  Loading(color: Theme.of(context).colorScheme.primary),
                                  ListenableBuilder(
                                    listenable: widget.controller.networkSpeed,
                                    builder:
                                        (context, _) => Text(
                                          widget.controller.networkSpeed.value.toNetworkSpeed(),
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            PlayerStatus.paused => Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                                child: const Icon(Icons.pause, size: 50),
                              ),
                            ),
                            _ => const SizedBox(),
                          },
                        ),
                  ),
                  _buildPanel(context),
                ],
              ),
            ),
          );
        },
      ),
    );
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
          onGenerateRoute:
              (settings) => FadeInPageRoute(
                builder:
                    (context) => FutureBuilderHandler(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snapshot) {
                        return PlayerSettings(
                          prefs: snapshot.requireData,
                          controller: _controller,
                          actions: widget.actions,
                          onSeekSpeedChanged: (speed) => _seekStep = Duration(seconds: speed),
                        );
                      },
                    ),
                settings: settings,
              ),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    return FocusScope(
      autofocus: true,
      skipTraversal: true,
      onKeyEvent: (node, event) => _onProgressKeyEvent(context, node, event),
      child: ListenableBuilder(
        listenable: _panelType,
        builder:
            (context, _) => PageTransitionSwitcher(
              reverse: _reverse,
              duration: const Duration(milliseconds: 500),
              layoutBuilder: (List<Widget> entries) {
                return Stack(alignment: Alignment.bottomCenter, children: entries);
              },
              transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
                  fillColor: Colors.transparent,
                  child: child,
                );
              },
              child: switch (_panelType.value) {
                _PlayerPanelType.progressbar => _buildProgressBar(context),
                _PlayerPanelType.playlist => _buildPlaylist(context),
                _PlayerPanelType.none => const SizedBox.expand(),
              },
            ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PlayerInfoView(widget.controller),
            const SizedBox(height: 30),
            Focus(
              autofocus: true,
              focusNode: _progressFocusNode,
              onKeyEvent: (FocusNode node, KeyEvent event) {
                if (_progressFocusNode.hasFocus) {
                  if (event is KeyDownEvent || event is KeyRepeatEvent) {
                    _controlsStream.add(ControlsStreamStatus.show);
                    switch (event.logicalKey) {
                      case LogicalKeyboardKey.arrowLeft:
                        if (!_progressController.seeking) {
                          widget.controller.pause();
                          _progressController.startSeek(context);
                        }
                        _controlsStream.add(ControlsStreamStatus.showInfinite);
                        _progressController.updateSeek(context, _progressController.cachedPosition - _seekStep);
                        return KeyEventResult.handled;
                      case LogicalKeyboardKey.arrowRight:
                        _controlsStream.add(ControlsStreamStatus.show);
                        if (!_progressController.seeking) {
                          widget.controller.pause();
                          _progressController.startSeek(context);
                        }
                        _controlsStream.add(ControlsStreamStatus.showInfinite);
                        _progressController.updateSeek(context, _progressController.cachedPosition + _seekStep);
                        return KeyEventResult.handled;
                      case LogicalKeyboardKey.enter:
                      case LogicalKeyboardKey.select:
                        if (_progressController.seeking) {
                          _progressController.endSeek(context);
                          widget.controller.seekTo(_progressController.cachedPosition);
                          widget.controller.play();
                        } else {
                          if (widget.controller.status.value == PlayerStatus.playing) {
                            widget.controller.pause();
                            return KeyEventResult.handled;
                          } else if (widget.controller.status.value == PlayerStatus.paused) {
                            widget.controller.play();
                            return KeyEventResult.handled;
                          }
                        }
                    }
                  }
                }
                return KeyEventResult.ignored;
              },
              child: PlayerProgressView(
                _progressController,
                seekStart: () => widget.controller.pause(),
                seekEnd: (position) {
                  widget.controller.seekTo(position);
                  widget.controller.play();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylist(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListenableBuilder(
        listenable: Listenable.merge([widget.controller.index, widget.controller.playlist]),
        builder:
            (context, _) => FocusScope(
              child: PlayerPlaylistView(
                playlist: widget.controller.playlist.value,
                activeIndex: widget.controller.index.value,
                onTap: (index) async {
                  await widget.controller.next(index);
                  if (widget.controller.status.value == PlayerStatus.ended ||
                      widget.controller.status.value == PlayerStatus.error ||
                      widget.controller.status.value == PlayerStatus.idle) {
                    await widget.controller.play();
                  }
                  _panelType.value = _PlayerPanelType.progressbar;
                },
              ),
            ),
      ),
    );
  }

  KeyEventResult _onProgressKeyEvent(BuildContext context, FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.contextMenu:
          _endSeeking();
          Scaffold.of(context).openEndDrawer();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          if (_panelType.value == _PlayerPanelType.none) {
            switch (widget.controller.status.value) {
              case PlayerStatus.playing:
              case PlayerStatus.buffering:
                widget.controller.pause();
              case PlayerStatus.paused:
                widget.controller.play();
              case PlayerStatus.ended:
              case PlayerStatus.error:
              case PlayerStatus.idle:
            }
            return KeyEventResult.handled;
          }
        case LogicalKeyboardKey.arrowUp:
          switch (_panelType.value) {
            case _PlayerPanelType.progressbar:
              _endSeeking();
              _controlsStream.add(ControlsStreamStatus.hide);
            case _PlayerPanelType.playlist:
              _reverse = true;
              _panelType.value = _PlayerPanelType.progressbar;
              _controlsStream.add(ControlsStreamStatus.show);
            case _PlayerPanelType.none:
              _reverse = false;
              _panelType.value = _PlayerPanelType.progressbar;
              _controlsStream.add(ControlsStreamStatus.show);
          }
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowDown:
          switch (_panelType.value) {
            case _PlayerPanelType.progressbar:
              _endSeeking();
              _reverse = false;
              if (_controller.playlist.value.length > 1) {
                _panelType.value = _PlayerPanelType.playlist;
                _controlsStream.add(ControlsStreamStatus.showInfinite);
              } else {
                _reverse = true;
                _endSeeking();
                _controlsStream.add(ControlsStreamStatus.hide);
                _scaffoldKey.currentState!.openEndDrawer();
              }
            case _PlayerPanelType.playlist:
              _controlsStream.add(ControlsStreamStatus.hide);
              _scaffoldKey.currentState!.openEndDrawer();
            case _PlayerPanelType.none:
              _reverse = false;
              _panelType.value = _PlayerPanelType.progressbar;
              _controlsStream.add(ControlsStreamStatus.show);
          }
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.arrowRight:
          if (_panelType.value == _PlayerPanelType.none) {
            _reverse = false;
            _panelType.value = _PlayerPanelType.progressbar;
            _controlsStream.add(ControlsStreamStatus.show);
            return KeyEventResult.handled;
          }
      }
    }
    return KeyEventResult.ignored;
  }

  void _endSeeking() {
    if (_progressController.seeking) {
      _progressController.endSeek(context);
      widget.controller.seekTo(_progressController.cachedPosition);
      widget.controller.play();
    }
  }
}

class PlayerSettings extends StatelessWidget {
  const PlayerSettings({
    super.key,
    required this.controller,
    this.actions,
    required this.onSeekSpeedChanged,
    required this.prefs,
  });

  final SharedPreferences prefs;
  final PlayerController<dynamic> controller;
  final ValueChanged<int> onSeekSpeedChanged;
  final List<Widget> Function(BuildContext)? actions;

  @override
  Widget build(BuildContext context) {
    final localizations = PlayerLocalizations.of(context);
    return SettingPage(
      title: localizations.settingsTitle,
      child: ListenableBuilder(
        listenable: controller.trackGroup,
        builder:
            (context, _) => ListView(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
              children: [
                if (controller.trackGroup.value.video.isNotEmpty)
                  _buildTrackSelector(
                    context,
                    icon: const Icon(Icons.movie_outlined),
                    label: localizations.videoSettingsVideo,
                    tracks: controller.trackGroup.value.video,
                    selected: controller.trackGroup.value.selectedVideo,
                    onSelected: (id) => controller.setTrack('video', id),
                  ),
                if (controller.trackGroup.value.audio.isNotEmpty)
                  _buildTrackSelector(
                    context,
                    icon: const Icon(Icons.audiotrack_outlined),
                    label: localizations.videoSettingsAudio,
                    tracks: controller.trackGroup.value.audio,
                    selected: controller.trackGroup.value.selectedAudio,
                    onSelected: (id) => controller.setTrack('audio', id),
                  ),
                if (controller.trackGroup.value.sub.isNotEmpty)
                  _buildTrackSelector(
                    context,
                    icon: const Icon(Icons.subtitles_outlined),
                    label: localizations.videoSettingsSubtitle,
                    tracks: controller.trackGroup.value.sub,
                    selected: controller.trackGroup.value.selectedSub,
                    onSelected: (id) => controller.setTrack('sub', id),
                  ),
                ListenableBuilder(
                  listenable: controller.playbackSpeed,
                  builder: (context, _) {
                    return ButtonSettingItem(
                      leading: const Icon(Icons.slow_motion_video_rounded),
                      title: Text(localizations.videoSettingsSpeeding),
                      trailing: Text('${controller.playbackSpeed.value}x'),
                      onTap: () {
                        Navigator.of(context).push(
                          FadeInPageRoute(
                            builder:
                                (context) => PlayerSubSettings(
                                  title: localizations.videoSettingsSpeeding,
                                  items:
                                      playerSpeedList
                                          .map(
                                            (playerSpeed) => RadioSettingItem(
                                              autofocus: controller.playbackSpeed.value == playerSpeed.value,
                                              groupValue: controller.playbackSpeed.value,
                                              value: playerSpeed.value,
                                              title: Text(playerSpeed.text),
                                              onChanged: (speed) {
                                                controller.setPlaybackSpeed(speed!);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          )
                                          .toList(),
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                ListenableBuilder(
                  listenable: controller.aspectRatio,
                  builder: (context, _) {
                    return ButtonSettingItem(
                      leading: const Icon(Icons.aspect_ratio_rounded),
                      title: Text(localizations.videoSize),
                      trailing: Text(controller.aspectRatio.value.label(context)),
                      onTap: () {
                        Navigator.of(context).push(
                          FadeInPageRoute(
                            builder:
                                (context) => PlayerSubSettings(
                                  title: localizations.videoSize,
                                  items:
                                      AspectRatioType.values
                                          .map(
                                            (aspectRatio) => RadioSettingItem(
                                              autofocus: aspectRatio == controller.aspectRatio.value,
                                              groupValue: controller.aspectRatio.value,
                                              value: aspectRatio,
                                              title: Text(aspectRatio.label(context)),
                                              onChanged: (_) {
                                                controller.aspectRatio.value = aspectRatio;
                                                controller.setAspectRatio(aspectRatio.value(context));
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          )
                                          .toList(),
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
                ButtonSettingItem(
                  title: Text(localizations.subtitleSetting),
                  leading: const Icon(Icons.subtitles_outlined),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final initialStyle = SubtitleSettings.fromJson(PlayerConfig.getSubtitleSettings(prefs));
                    if (!context.mounted) return;

                    final style = await Navigator.of(context).push(
                      FadeInPageRoute(builder: (context) => PlayerSubtitleSettings(subtitleSettings: initialStyle)),
                    );
                    if (style != null) {
                      PlayerConfig.setSubtitleSettings(prefs, style);
                      controller.setSubtitleStyle(style);
                    }
                  },
                ),
                const Divider(),
                StatefulBuilder(
                  builder: (context, setState) {
                    final data = PlayerConfig.getExtensionRendererMode(prefs);
                    return ButtonSettingItem(
                      title: Text(localizations.extensionRendererModeLabel),
                      trailing: Text(
                        localizations.extensionRendererMode(data.toString()),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          FadeInPageRoute(
                            builder:
                                (context) => PlayerSubSettings(
                                  title: localizations.extensionRendererModeLabel,
                                  items:
                                      [0, 1, 2]
                                          .map(
                                            (i) => RadioSettingItem(
                                              value: i,
                                              groupValue: data,
                                              autofocus: data == i,
                                              title: Text(localizations.extensionRendererMode(i.toString())),
                                              onChanged: (value) async {
                                                if (value == null) return;
                                                PlayerConfig.setExtensionRendererMode(prefs, value);
                                                await PlayerController.setPlayerOption('extensionRendererMode', value);
                                                if (context.mounted) {
                                                  setState(() {});
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                            ),
                                          )
                                          .toList(),
                                ),
                          ),
                        );
                        setState(() {});
                      },
                    );
                  },
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    return SwitchSettingItem(
                      title: Text(localizations.playerEnableDecoderFallback),
                      value: PlayerConfig.getEnableDecoderFallback(prefs),
                      onChanged: (value) async {
                        PlayerConfig.setEnableDecoderFallback(prefs, value);
                        await PlayerController.setPlayerOption('enableDecoderFallback', value);
                        setState(() {});
                      },
                    );
                  },
                ),
                const Divider(),
                StatefulBuilder(
                  builder: (context, setState) {
                    return ButtonSettingItem(
                      title: Builder(
                        builder: (context) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.playerFastForwardSpeed),
                              Text(
                                '${prefs.getInt('playerConfig.fastForwardSpeed') ?? 30} ${AppLocalizations.of(context)!.second}',
                              ),
                            ],
                          );
                        },
                      ),
                      subtitle: MediaQuery(
                        data: const MediaQueryData(navigationMode: NavigationMode.directional),
                        child: Slider(
                          value: prefs.getInt('playerConfig.fastForwardSpeed')?.toDouble() ?? 30,
                          min: 5,
                          max: 100,
                          divisions: 19,
                          label: (prefs.getInt('playerConfig.fastForwardSpeed') ?? 30).toString(),
                          onChanged: (double value) {
                            setState(() {
                              prefs.setInt('playerConfig.fastForwardSpeed', value.round());
                            });
                            onSeekSpeedChanged(value.round());
                          },
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                if (actions != null) ...actions!(context),
                if (actions != null) const Divider(),
                ListenableBuilder(
                  listenable: controller.mediaInfo,
                  builder:
                      (context, _) =>
                          controller.mediaInfo.value == null
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
                                      TableRow(
                                        children: [
                                          Text('Video', style: Theme.of(context).textTheme.titleSmall),
                                          Container(),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          const Text('Codecs'),
                                          Text(controller.mediaInfo.value!.videoCodecs ?? localizations.tagUnknown),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          const Text('Mime'),
                                          Text(controller.mediaInfo.value!.videoMime ?? localizations.tagUnknown),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          const Text('FPS'),
                                          Text(
                                            controller.mediaInfo.value!.videoFPS?.toString() ??
                                                localizations.tagUnknown,
                                          ),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          const Text('Size'),
                                          Text(controller.mediaInfo.value!.videoSize ?? localizations.tagUnknown),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text('Audio', style: Theme.of(context).textTheme.titleSmall),
                                          ),
                                          Container(),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          const Text('Codecs'),
                                          Text(controller.mediaInfo.value!.audioCodecs ?? localizations.tagUnknown),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          const Text('Mime'),
                                          Text(controller.mediaInfo.value!.audioMime ?? localizations.tagUnknown),
                                        ],
                                      ),
                                      TableRow(
                                        children: [
                                          const Text('Bitrate'),
                                          Text(
                                            controller.mediaInfo.value!.audioBitrate?.toString() ??
                                                localizations.tagUnknown,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                ),
                const Focus(child: SizedBox()),
              ],
            ),
      ),
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
    final localizations = PlayerLocalizations.of(context);
    return ButtonSettingItem(
      leading: icon,
      title: Text(label),
      trailing: Text(selectedTrack?.label ?? localizations.videoSettingsNone, overflow: TextOverflow.ellipsis),
      onTap: () {
        Navigator.of(context).push(
          FadeInPageRoute(
            builder:
                (context) => PlayerSubSettings(
                  title: label,
                  items: [
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
                    ...tracks.map(
                      (e) => RadioSettingItem(
                        autofocus: e.id == selected,
                        groupValue: selected,
                        value: e.id,
                        title: Text(e.label ?? localizations.tagUnknown),
                        onChanged: (value) {
                          onSelected(value);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
          ),
        );
      },
    );
  }
}

class PlayerSubSettings extends StatelessWidget {
  const PlayerSubSettings({super.key, required this.title, required this.items});

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SettingPage(
        title: title,
        child: ListView(padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32), children: items),
      ),
    );
  }
}

class PlayerPlaylistView<T> extends StatefulWidget {
  const PlayerPlaylistView({super.key, required this.onTap, this.activeIndex, required this.playlist});

  final ValueChanged<int> onTap;
  final int? activeIndex;
  final List<PlaylistItemDisplay<dynamic>> playlist;

  @override
  State<PlayerPlaylistView<T>> createState() => _PlayerPlaylistViewState<T>();
}

class _PlayerPlaylistViewState<T> extends State<PlayerPlaylistView<T>> {
  late final _controller = ScrollController(initialScrollOffset: (widget.activeIndex ?? 0) * 216);

  @override
  void didUpdateWidget(covariant PlayerPlaylistView<T> oldWidget) {
    final index = widget.activeIndex;
    if (index != oldWidget.activeIndex && index != null && index >= 0 && index < widget.playlist.length) {
      final offset = min(_controller.position.maxScrollExtent, index * (200.0 + 12));
      _controller.animateTo(offset, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
    super.didUpdateWidget(oldWidget);
  }

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
          final item = widget.playlist[index];
          return SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Stack(
                  children: [
                    FocusableImage(
                      width: 200,
                      height: 112,
                      poster: item.poster,
                      autofocus: index == widget.activeIndex,
                      onTap: () => widget.onTap(index),
                    ),
                    if (index == widget.activeIndex)
                      Container(
                        width: 200,
                        height: 112,
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(6)),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: PlayingIcon(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.title != null)
                      Text(item.title!, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                    if (item.description != null)
                      Text(
                        item.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 16),
      ),
    );
  }
}

class PlayerInfoView extends StatelessWidget {
  const PlayerInfoView(this._controller, {super.key, this.showPoster = true});

  final PlayerController<dynamic> _controller;
  final bool showPoster;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_controller.index, _controller.fatalError]),
      builder:
          (context, _) => Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              children: [
                if (showPoster && _controller.currentItem?.poster != null)
                  AsyncImage(_controller.currentItem!.poster!, height: 100, radius: BorderRadius.circular(4)),
                if (showPoster && _controller.currentItem?.poster != null) const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_controller.title.value != null)
                        Text(
                          _controller.title.value!,
                          style: Theme.of(context).textTheme.displaySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      const SizedBox(height: 10),
                      Text(
                        _controller.subTitle.value,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_controller.fatalError.value != null)
                        Text(
                          _controller.fatalError.value!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class PlayerSubtitleSettings extends StatefulWidget {
  const PlayerSubtitleSettings({super.key, required this.subtitleSettings});

  final SubtitleSettings subtitleSettings;

  @override
  State<PlayerSubtitleSettings> createState() => _PlayerSubtitleSettingsState();
}

class _PlayerSubtitleSettingsState extends State<PlayerSubtitleSettings> {
  final subtitleStyles = const [
    SubtitleSettings(
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      windowColor: Colors.transparent,
      edgeColor: Colors.transparent,
    ),
    SubtitleSettings(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      windowColor: Colors.transparent,
      edgeColor: Colors.transparent,
    ),
    SubtitleSettings(
      foregroundColor: Colors.black,
      backgroundColor: Colors.transparent,
      windowColor: Colors.transparent,
      edgeColor: Colors.white,
    ),
    SubtitleSettings(
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      windowColor: Colors.transparent,
      edgeColor: Colors.black,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = PlayerLocalizations.of(context);
    return PlayerSubSettings(
      title: localizations.subtitleSetting,
      items:
          subtitleStyles
              .map(
                (style) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Focusable(
                    height: 140,
                    onTap: () {
                      Navigator.of(context).pop(style.toJson());
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Ink(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: AssetImage('assets/common/images/subtitle_bg.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, 0.9),
                          child: Stack(
                            children: [
                              Text(
                                localizations.subtitleSettingExample,
                                style: TextStyle(
                                  fontSize: 18,
                                  backgroundColor: style.backgroundColor,
                                  foreground:
                                      Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 2
                                        ..color = style.edgeColor,
                                ),
                              ),
                              Text(
                                localizations.subtitleSettingExample,
                                style: TextStyle(fontSize: 18, color: style.foregroundColor),
                              ),
                            ],
                          ),
                        ),
                        if (widget.subtitleSettings == style)
                          Align(
                            alignment: const Alignment(0.9, -0.9),
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.check_rounded),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
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
