import 'dart:async';

import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/player.dart';

import '../../../components/components.dart';
import '../../../details/playlist.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform_api.dart';
import '../../../previews/previews.dart';
import '../../../providers/player.dart';
import '../../../utils/utils.dart';
import 'player_appbar.dart';
import 'player_controls_gesture.dart';
import 'player_zoomer.dart';

class PlayerControls extends StatefulWidget {
  const PlayerControls({super.key, required this.controller});

  final PlayerController controller;

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _zoomKey = GlobalKey<PlayerZoomWrapperState>();
  late final PlayerController _controller = widget.controller;
  late final _progressController = PlayerProgressController(_controller);
  final ValueNotifier<bool> _isShowControls = ValueNotifier(false);
  final ValueNotifier<bool> _isLocked = ValueNotifier(false);
  final ValueNotifier<bool> _isShowLockButton = ValueNotifier(false);
  final ValueNotifier<bool> _isZoomed = ValueNotifier(false);
  final _controlsStream = StreamController<ControlsStreamStatus>();
  StreamSubscription<bool>? _subscription;
  StreamSubscription<bool>? _pipSubscription;

  @override
  void initState() {
    _subscription = _controlsStream.stream
        .switchMap((status) {
          switch (status) {
            case ControlsStreamStatus.show:
              return ConcatStream([Stream.value(true), TimerStream(false, const Duration(seconds: 50))]);
            case ControlsStreamStatus.showInfinite:
              return Stream.value(true);
            case ControlsStreamStatus.hide:
              return Stream.value(false);
          }
        })
        .listen((show) {
          if (!_isLocked.value || !show) {
            _isShowControls.value = show;
          }
          _isShowLockButton.value = show;
        });
    _controlsStream.add(ControlsStreamStatus.show);
    _controller.playbackState.addListener(() {
      switch (_controller.playbackState.value) {
        case .ready:
          if (_isShowControls.value) {
            _controlsStream.add(ControlsStreamStatus.show);
          }
        case .ended:
        case .idle:
          _controlsStream.add(ControlsStreamStatus.showInfinite);
        case .buffering:
      }
    });
    _controller.isPlaying.addListener(() {
      if (!_controller.isPlaying.value) {
        _controlsStream.add(ControlsStreamStatus.showInfinite);
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
                child: Text(AppLocalizations.of(context)!.willSkipEnding),
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
      if (_controller.error.value != null && context.mounted) {
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
    _pipSubscription = PlatformApi.pipEvent.listen((flag) {
      if (flag) {
        _controlsStream.add(ControlsStreamStatus.hide);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _isShowControls.dispose();
    _isShowLockButton.dispose();
    _isLocked.dispose();
    _isZoomed.dispose();
    _subscription?.cancel();
    _pipSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }
        if (_isLocked.value) {
          return _controlsStream.add(ControlsStreamStatus.show);
        }
        if (!context.mounted) {
          return;
        }
        if (_navigatorKey.currentState?.canPop() ?? false) {
          return _navigatorKey.currentState!.pop();
        }
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PlayerAppbar(
          show: _isShowControls,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          actions: [
            _SwitchLinkButton(_controller),
            IconButton(onPressed: () => PlatformApi.requestPip(), icon: const Icon(Icons.picture_in_picture_rounded)),
            const EndDrawerButton(),
          ],
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        endDrawer: Drawer(
          child: Navigator(
            key: _navigatorKey,
            onGenerateRoute: (settings) => FadeInPageRoute(
              builder: (context) => Theme(
                data: Theme.of(context)
                    .copyWith(scaffoldBackgroundColor: Theme.of(context).colorScheme.surfaceContainerLow),
                child: PlayerSettings(
                  controller: _controller,
                  onSeekSpeedChanged: (speed) {},
                  onShowLiteProgressbarChanged: (value) {},
                ),
              ),
              settings: settings,
            ),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _controlsStream.add(_isShowLockButton.value ? .hide : .show),
          child: Stack(
            alignment: const Alignment(0.9, 0),
            children: [
              PlayerZoomWrapper(
                key: _zoomKey,
                controller: _controller,
                child: const SizedBox.expand(),
                onZoomChanged: (zoom) => _isZoomed.value = zoom,
              ),
              ListenableBuilder(
                listenable: _isLocked,
                builder: (context, _) {
                  return _isLocked.value
                      ? const SizedBox.expand()
                      : PlayerControlsGesture(controller: _controller, child: const SizedBox.expand());
                },
              ),
              ListenableBuilder(
                listenable: _isShowControls,
                builder: (context, _) => PageTransitionSwitcher(
                  reverse: !_isShowControls.value,
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation) {
                    return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.vertical,
                      fillColor: Colors.transparent,
                      child: child,
                    );
                  },
                  child: _isShowControls.value && !_isLocked.value ? _buildControls(context) : const SizedBox(),
                ),
              ),
              ListenableBuilder(
                listenable: _isShowLockButton,
                builder: (context, child) => PageTransitionSwitcher(
                  reverse: !_isShowLockButton.value,
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation) {
                    return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      fillColor: Colors.transparent,
                      child: child,
                    );
                  },
                  child: _isShowLockButton.value ? child : const SizedBox(),
                ),
                child: ListenableBuilder(
                  listenable: _isLocked,
                  builder: (context, _) => _isLocked.value
                      ? IconButton.filledTonal(
                          onPressed: () {
                            _isLocked.value = false;
                            _controlsStream.add(ControlsStreamStatus.show);
                          },
                          icon: const Icon(Icons.lock_outline_rounded),
                        )
                      : IconButton(
                          onPressed: () {
                            _isLocked.value = true;
                            _controlsStream.add(ControlsStreamStatus.hide);
                          },
                          icon: const Icon(Icons.lock_open_rounded),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final Orientation orientation = MediaQuery.orientationOf(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: switch (Theme.of(context).brightness) {
              Brightness.dark => [Colors.transparent, Colors.black54],
              Brightness.light => [Colors.white.withAlpha(0), Colors.white54],
            },
          ),
        ),
        padding: orientation == .landscape
            ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
            : const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: .stretch,
            children: [
              Row(
                crossAxisAlignment: .end,
                children: [
                  Expanded(child: _PlayerInfoView(_controller)),
                  ListenableBuilder(
                    listenable: _isZoomed,
                    builder: (context, child) => _isZoomed.value ? child! : const SizedBox(),
                    child: FilledButton(
                      onPressed: () => _zoomKey.currentState?.reset(),
                      child: Text(AppLocalizations.of(context)!.buttonReset),
                    ),
                  ),
                ],
              ),
              if (orientation == .portrait)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: PlayerProgressLabel(controller: _progressController),
                ),
              PlayerProgressView(
                _progressController,
                thickness: 6,
                scalable: false,
                showLabel: false,
                seekStart: () => _controller.pause(),
                seekEnd: (position) {
                  _controller.seekTo(position);
                  _controller.play();
                },
              ),
              Row(
                spacing: MediaQuery.sizeOf(context).width / 360,
                children: [
                  _PreviousButton(_controller),
                  _ToggleButton(_controller),
                  _NextButton(_controller),
                  Expanded(
                    child: orientation == .landscape
                        ? PlayerProgressLabel(controller: _progressController)
                        : const SizedBox(),
                  ),
                  _PlaybackSpeedButton(_controller),
                  _SubtitleButton(_controller),
                  ListenableBuilder(
                    listenable: _controller.playlist,
                    builder: (context, _) => _PlaylistButton(_controller),
                  ),
                  if (PlatformApi.isAndroidPhone())
                    _ForceLandScapeButton(
                      onChanged: (v) {
                        SystemChrome.setPreferredOrientations([
                          if (!v) DeviceOrientation.portraitUp,
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.landscapeRight,
                        ]);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerInfoView extends StatelessWidget {
  const _PlayerInfoView(this._controller);

  final PlayerController _controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 12, right: 16),
      child: ListenableBuilder(
        builder: (context, _) => DeviceOrientationBuilder(
          builder: (context, orientation) {
            final Widget? poster = _buildPoster(context);
            return switch (MediaQuery.of(context).orientation) {
              Orientation.portrait => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  if (_controller.fatalError.value != null)
                    Text(_controller.fatalError.value!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  if (poster != null) Align(alignment: Alignment.topLeft, child: poster),
                  if (_controller.title.value != null)
                    Text(
                      _controller.title.value!,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  Text(
                    _controller.subTitle.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ListenableBuilder(
                    listenable: _controller.playbackState,
                    builder: (context, _) {
                      return switch (_controller.playbackState.value) {
                        PlaybackState.buffering => ListenableBuilder(
                          listenable: _controller.networkSpeed,
                          builder: (context, child) => Text(
                            _controller.networkSpeed.value.toNetworkSpeed(),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                        _ => Text(' ', style: Theme.of(context).textTheme.labelSmall),
                      };
                    },
                  ),
                ],
              ),
              Orientation.landscape => Row(
                spacing: 30,
                crossAxisAlignment: .end,
                children: [
                  ?poster,
                  Expanded(
                    child: Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_controller.fatalError.value != null)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 140),
                            child: SingleChildScrollView(
                              child: Text(
                                _controller.fatalError.value!,
                                style: TextStyle(color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          ),
                        if (_controller.title.value != null)
                          Text(
                            _controller.title.value!,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              _controller.subTitle.value,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            ListenableBuilder(
                              listenable: _controller.playbackState,
                              builder: (context, _) {
                                return switch (_controller.playbackState.value) {
                                  PlaybackState.buffering => ListenableBuilder(
                                    listenable: _controller.networkSpeed,
                                    builder: (context, child) => Text(
                                      _controller.networkSpeed.value.toNetworkSpeed(),
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ),
                                  _ => Text('', style: Theme.of(context).textTheme.labelSmall),
                                };
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            };
          },
        ),
        listenable: Listenable.merge([_controller.title, _controller.fatalError]),
      ),
    );
  }

  Widget? _buildPoster(BuildContext context) {
    return _controller.currentItem?.poster != null
        ? switch (_controller.currentItem!.source) {
            Movie _ => AsyncImage(
              _controller.currentItem!.poster!,
              height: 160,
              radius: BorderRadius.circular(4),
              showErrorWidget: false,
            ),
            TVEpisode _ => AsyncImage(
              _controller.currentItem!.poster!,
              width: 160,
              height: 90,
              radius: BorderRadius.circular(4),
              showErrorWidget: false,
            ),
            Channel _ => AsyncImage(
              _controller.currentItem!.poster!,
              height: 50,
              radius: BorderRadius.circular(4),
              padding: const EdgeInsets.all(100),
              showErrorWidget: false,
            ),
            _ => AsyncImage(_controller.currentItem!.poster!, height: 100, radius: BorderRadius.circular(4)),
          }
        : null;
  }
}

class _ForceLandScapeButton extends StatefulWidget {
  const _ForceLandScapeButton({required this.onChanged});

  final ValueChanged<bool> onChanged;

  @override
  State<_ForceLandScapeButton> createState() => _ForceLandScapeButtonState();
}

class _ForceLandScapeButtonState extends State<_ForceLandScapeButton> {
  bool _forceLandScape = false;

  @override
  void initState() {
    super.initState();
    _forceLandScape = context.read<PlayerConfig>().autoForceLandscape;
    if (_forceLandScape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconTheme.of(context).copyWith(size: 20),
      child: _forceLandScape
          ? IconButton.filled(
              onPressed: () => _forceLandScapeChanged(false),
              icon: const Icon(Icons.screen_rotation_rounded),
            )
          : DeviceOrientationBuilder(
              builder: (context, orientation) => switch (orientation) {
                Orientation.portrait => IconButton(
                  onPressed: () => _forceLandScapeChanged(true),
                  icon: const Icon(Icons.screen_rotation_rounded),
                ),
                Orientation.landscape => const SizedBox(),
              },
            ),
    );
  }

  void _forceLandScapeChanged(bool flag) {
    _forceLandScape = flag;
    context.read<PlayerConfig>().setAutoForceLandscape(flag);
    widget.onChanged(_forceLandScape);
    setState(() {});
  }
}

class _PlaylistButton extends StatelessWidget {
  const _PlaylistButton(this.controller);

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return (controller.playlist.value.length > 1 && width >= 400)
        ? IconButton(
            onPressed: () {
              if (controller.playlist.value.firstOrNull?.source is Channel) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  constraints: const BoxConstraints.expand(),
                  builder: (context) => ChannelsPage(
                    items: controller.playlist.value.map((item) => item.source).toList().cast(),
                    showEpg: true,
                    activeIndex: controller.index.value,
                    onTap: _play,
                  ),
                );
              } else {
                showModalBottomSheet(
                  context: context,
                  constraints: const BoxConstraints(maxHeight: 220),
                  backgroundColor: Colors.transparent,
                  useSafeArea: true,
                  builder: (context) => ListenableBuilder(
                    listenable: controller.index,
                    builder: (context, _) {
                      return PlayerPlaylist(
                        playlist: controller.playlist.value,
                        activeIndex: controller.index.value,
                        onTap: _play,
                      );
                    },
                  ),
                );
              }
            },
            icon: const Icon(Icons.playlist_play_rounded),
          )
        : const SizedBox();
  }

  Future<void> _play(int index) async {
    await controller.next(index);
    if (!controller.isPlaying.value) {
      await controller.play();
    }
  }
}

class _SwitchLinkButton extends StatefulWidget {
  const _SwitchLinkButton(this.controller);

  final PlayerController controller;

  @override
  State<_SwitchLinkButton> createState() => _SwitchLinkButtonState();
}

class _SwitchLinkButtonState extends State<_SwitchLinkButton> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller.index,
      builder: (context, _) =>
          (widget.controller.currentItem?.source is Channel &&
              (widget.controller.currentItem!.source as Channel).links.length > 1)
          ? PopupMenuButton(
              onSelected: (url) async {
                await widget.controller.updateSource(
                  widget.controller.currentItem!.copyWith(url: url),
                  widget.controller.index.value!,
                );
                if (widget.controller.isPlaying.value) {
                  await widget.controller.play();
                }
                setState(() {});
              },
              itemBuilder: (context) => (widget.controller.currentItem!.source as Channel).links.indexed
                  .map(
                    (entry) => CheckedPopupMenuItem(
                      checked: widget.controller.currentItem?.url == entry.$2,
                      value: entry.$2,
                      child: Text('${AppLocalizations.of(context)!.playerBroadcastLine} ${entry.$1 + 1}'),
                    ),
                  )
                  .toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${AppLocalizations.of(context)!.playerBroadcastLine} ${(widget.controller.currentItem!.source as Channel).links.indexOf(widget.controller.currentItem!.url!) + 1}',
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton(this.controller);

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller.playbackState, controller.isPlaying]),
      builder: (context, _) {
        return switch (controller.playbackState.value) {
          .ready =>
            controller.isPlaying.value
                ? IconButton(onPressed: controller.pause, icon: const Icon(Icons.pause_rounded))
                : IconButton(onPressed: controller.play, icon: const Icon(Icons.play_arrow_rounded)),
          .buffering => SizedBox.square(
            dimension: 48,
            child: Center(child: Transform.scale(scale: 0.5, child: const CircularProgressIndicator())),
          ),
          .idle =>
            controller.fatalError.value != null
                ? IconButton(
                    onPressed: null,
                    icon: Icon(Icons.error_rounded, color: Theme.of(context).colorScheme.error),
                  )
                : IconButton(onPressed: controller.play, icon: const Icon(Icons.play_arrow_rounded)),
          .ended => IconButton(onPressed: controller.play, icon: const Icon(Icons.play_arrow_rounded)),
        };
      },
    );
  }
}

class _PreviousButton extends StatelessWidget {
  const _PreviousButton(this.controller);

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.isFirst,
      builder: (context, child) => controller.isFirst.value ? const SizedBox() : child!,
      child: IconButton(
        onPressed: () async {
          await controller.next(controller.index.value! - 1);
          await controller.play();
        },
        icon: const Icon(Icons.skip_previous_rounded),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton(this.controller);

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.isLast,
      builder: (context, child) => controller.isLast.value ? const SizedBox() : child!,
      child: IconButton(
        onPressed: () async {
          await controller.next(controller.index.value! + 1);
          await controller.play();
        },
        icon: const Icon(Icons.skip_next_rounded),
      ),
    );
  }
}

class _SubtitleButton extends StatelessWidget {
  const _SubtitleButton(this.controller);

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.trackGroup,
      builder: (context, _) {
        return controller.trackGroup.value.sub.isNotEmpty
            ? PopupMenuButton(
                onSelected: (id) => controller.setTrack('sub', id),
                tooltip: '',
                itemBuilder: (context) => [
                  CheckedPopupMenuItem(
                    checked: controller.trackGroup.value.selectedSub == null,
                    value: 'null',
                    child: Text(AppLocalizations.of(context)!.none),
                  ),
                  ...controller.trackGroup.value.sub.map(
                    (e) => CheckedPopupMenuItem(
                      checked: controller.trackGroup.value.selectedSub?.id == e.id,
                      value: e.id,
                      child: Text(_getTrackText(e)),
                    ),
                  ),
                ],
                iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                icon: Icon(
                  controller.trackGroup.value.selectedSub == null
                      ? Icons.subtitles_off_outlined
                      : Icons.subtitles_outlined,
                ),
              )
            : const SizedBox();
      },
    );
  }

  String _getTrackText(MediaTrack track) {
    final List<dynamic> spans = [];
    if (track.name?.isNotEmpty ?? false) {
      spans.add(track.name);
    }
    if (track.label?.isNotEmpty ?? false) {
      spans.add(track.label);
    }
    if (track.sampleMimeType?.isNotEmpty ?? false) {
      final List<String> mimes = track.sampleMimeType!.split('/');
      if (mimes.length >= 2) {
        spans.add(mimes[1]);
      }
    }
    if (track.sampleRate != null && track.sampleRate! > 0) {
      spans.add('${track.sampleRate}Hz');
    }
    if (track.averageBitrate != null && track.averageBitrate! > 0) {
      spans.add('${track.averageBitrate}Bit/s');
    }
    return spans.join(', ');
  }
}

class _PlaybackSpeedButton extends StatelessWidget {
  const _PlaybackSpeedButton(this.controller);

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.playbackSpeed,
      builder: (context, _) => Badge(
        label: Text('${controller.playbackSpeed.value}X'),
        isLabelVisible: controller.playbackSpeed.value != 1,
        child: PopupMenuButton(
          onSelected: (speed) => controller.setPlaybackSpeed(speed),
          itemBuilder: (context) => playerSpeedList
              .map(
                (playerSpeed) => CheckedPopupMenuItem(
                  checked: controller.playbackSpeed.value == playerSpeed.value,
                  value: playerSpeed.value,
                  child: Text(playerSpeed.text),
                ),
              )
              .toList(),
          iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
          icon: const Icon(Icons.slow_motion_video_rounded),
          tooltip: '',
        ),
      ),
    );
  }
}

@AppPreview(group: 'PlayerControls (Mobile)', name: 'Portrait', size: Size(800, 400))
Widget playerControlsPortraitPreview() {
  return PlayerControls(controller: PlayerController());
}

@AppPreview(group: 'PlayerControls (Mobile)', name: 'Landscape', size: Size(400, 800))
Widget playerControlsLandscapePreview() {
  return PlayerControls(controller: PlayerController());
}
