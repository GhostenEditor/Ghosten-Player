import 'dart:async';

import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:collection/collection.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/player.dart';

import '../../components/async_image.dart';
import '../../components/future_builder_handler.dart';
import '../../components/player_i18n_adaptor.dart';
import '../../components/playing_icon.dart';
import '../../l10n/app_localizations.dart';
import '../../platform_api.dart';
import '../../providers/user_config.dart';
import '../../theme.dart';
import '../../utils/utils.dart';
import '../components/image_card.dart';
import '../utils/utils.dart';
import 'mixins/player_actions.dart';
import 'player_appbar.dart';
import 'player_controls_gesture.dart';

class PlayerControlsFull<T> extends StatefulWidget {
  const PlayerControlsFull(this.controller, this.progressController, {super.key, this.theme});

  final PlayerController<T> controller;
  final PlayerProgressController progressController;
  final int? theme;

  @override
  State<PlayerControlsFull<T>> createState() => _PlayerControlsFullState<T>();
}

class _PlayerControlsFullState<T> extends State<PlayerControlsFull<T>> with PlayerActionsMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _zoomKey = GlobalKey<PlayerZoomWrapperState>();
  late final _controller = widget.controller;
  late final _progressController = widget.progressController;
  final _isShowControls = ValueNotifier(false);
  final _isLocked = ValueNotifier(false);
  final _isShowLockButton = ValueNotifier(false);
  final _forceLandScape = ValueNotifier(false);
  final _isZoomed = ValueNotifier(false);
  final _controlsStream = StreamController<ControlsStreamStatus>();
  StreamSubscription<bool>? _subscription;
  StreamSubscription<bool>? _pipSubscription;

  @override
  void initState() {
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
          if (!_isLocked.value || !show) {
            _isShowControls.value = show;
          }
          _isShowLockButton.value = show;
        });
    _controlsStream.add(ControlsStreamStatus.show);
    setPreferredOrientations(true);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final autoForceLandscape = context.read<UserConfig>().autoForceLandscape;
    if (autoForceLandscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
    widget.controller.enterFullscreen();
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
      if (flag) _controlsStream.add(ControlsStreamStatus.hide);
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.exitFullscreen();
    _isShowControls.dispose();
    _isShowLockButton.dispose();
    _isLocked.dispose();
    _forceLandScape.dispose();
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
        if (!didPop) {
          if (_isLocked.value) {
            return _controlsStream.add(ControlsStreamStatus.show);
          }

          // TODO(GhostenEditor): bug when SDK < 29
          await setPreferredOrientations(false);
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

          if (!context.mounted) return;
          if (_navigatorKey.currentState?.canPop() ?? false) {
            return _navigatorKey.currentState!.pop();
          }
          Navigator.pop(context);
        }
      },
      child: Theme(
        data: darkTheme.copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: widget.theme != null ? Color(widget.theme!) : Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        child: Builder(
          builder: (context) {
            return PlayerI18nAdaptor(
              child: Scaffold(
                key: _scaffoldKey,
                appBar: PlayerAppbar(
                  show: _isShowControls,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  actions: [
                    if (_controller.currentItem?.source is Channel && MediaQuery.of(context).size.aspectRatio > 1)
                      IconButton(
                        onPressed:
                            () => showDialog(
                              context: context,
                              builder:
                                  (context) => _ChannelListGrouped(
                                    controller: _controller as PlayerController<Channel>,
                                    onTap: (index) async {
                                      await _controller.next(index);
                                      switch (_controller.status.value) {
                                        case PlayerStatus.paused:
                                        case PlayerStatus.ended:
                                        case PlayerStatus.error:
                                        case PlayerStatus.idle:
                                          await _controller.play();
                                        case PlayerStatus.playing:
                                        case PlayerStatus.buffering:
                                      }
                                    },
                                  ),
                            ),
                        icon: const Icon(Icons.list),
                      ),
                    SwitchLinkButton(_controller),
                    IconButton(
                      onPressed: () => _controller.requestPip(),
                      icon: const Icon(Icons.picture_in_picture_rounded),
                    ),
                    IconButton(
                      onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
                      icon: const Icon(Icons.more_vert_rounded),
                    ),
                  ],
                ),
                extendBodyBehindAppBar: true,
                backgroundColor: kIsWeb ? Colors.black : Colors.transparent,
                endDrawer: Drawer(
                  child: Container(
                    width: 360,
                    color: const Color(0xff202124),
                    child: Navigator(
                      key: _navigatorKey,
                      onGenerateRoute:
                          (settings) => MaterialPageRoute(
                            builder:
                                (context) => FutureBuilderHandler(
                                  future: SharedPreferences.getInstance(),
                                  builder: (context, snapshot) {
                                    return PlayerSettings(
                                      prefs: snapshot.requireData,
                                      controller: _controller,
                                      actions: (context) => actions(context, _controller),
                                    );
                                  },
                                ),
                            settings: settings,
                          ),
                    ),
                  ),
                ),
                body: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_isShowLockButton.value) {
                      _controlsStream.add(ControlsStreamStatus.hide);
                    } else {
                      _controlsStream.add(ControlsStreamStatus.show);
                    }
                  },
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
                        builder:
                            (context, _) => PageTransitionSwitcher(
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
                              child:
                                  _isShowControls.value && !_isLocked.value
                                      ? _buildControls(context)
                                      : const SizedBox(),
                            ),
                      ),
                      ListenableBuilder(
                        listenable: _isShowLockButton,
                        builder:
                            (context, child) => PageTransitionSwitcher(
                              reverse: !_isShowLockButton.value,
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (
                                Widget child,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation,
                              ) {
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
                          builder:
                              (context, _) =>
                                  _isLocked.value
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
          },
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final aspectRatio = MediaQuery.of(context).size.aspectRatio;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black54],
          ),
        ),
        padding: aspectRatio > 1 ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16) : const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListenableBuilder(
                listenable: _isZoomed,
                builder: (context, child) => _isZoomed.value ? child! : const SizedBox(),
                child: FilledButton(
                  onPressed: () => _zoomKey.currentState?.reset(),
                  child: Text(AppLocalizations.of(context)!.buttonReset),
                ),
              ),
              _PlayerInfoView(_controller),
              if (aspectRatio <= 1)
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
                spacing: MediaQuery.of(context).size.width / 360,
                children: [
                  PlayerPreviousButton(_controller),
                  PlayerPlayButton(_controller),
                  PlayerNextButton(_controller),
                  Expanded(
                    child: aspectRatio > 1 ? PlayerProgressLabel(controller: _progressController) : const SizedBox(),
                  ),
                  PlayerPlaybackSpeedButton(_controller),
                  PlayerSubtitleButton(_controller),
                  _PlaylistButton(_controller),
                  ListenableBuilder(
                    listenable: _forceLandScape,
                    builder:
                        (context, _) => _ForceLandScapeButton(
                          forceLandScape: _forceLandScape.value,
                          onChanged: (v) => _forceLandScape.value = v,
                        ),
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

class _PlayerInfoView<T> extends StatelessWidget {
  const _PlayerInfoView(this._controller);

  final PlayerController<T> _controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 12, right: 16),
      child: ListenableBuilder(
        builder:
            (context, _) => OrientationBuilder(
              builder: (context, orientation) {
                final poster = _buildPoster(context);
                return switch (MediaQuery.of(context).orientation) {
                  Orientation.portrait => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
                      if (poster != null) Align(alignment: Alignment.topLeft, child: poster),
                      if (_controller.title.value != null)
                        Text(
                          _controller.title.value!,
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        _controller.subTitle.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ListenableBuilder(
                        listenable: _controller.status,
                        builder: (context, _) {
                          return switch (_controller.status.value) {
                            PlayerStatus.buffering => ListenableBuilder(
                              listenable: _controller.networkSpeed,
                              builder:
                                  (context, child) => Text(
                                    _controller.networkSpeed.value.toNetworkSpeed(),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                            ),
                            _ => Text(' ', style: Theme.of(context).textTheme.labelSmall),
                          };
                        },
                      ),
                      if (_controller.fatalError.value != null)
                        Text(
                          _controller.fatalError.value!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                    ],
                  ),
                  Orientation.landscape => Row(
                    spacing: 30,
                    children: [
                      if (poster != null) poster,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_controller.title.value != null)
                              Text(
                                _controller.title.value!,
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            const SizedBox(height: 10),
                            Text(
                              _controller.subTitle.value,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            ListenableBuilder(
                              listenable: _controller.status,
                              builder: (context, _) {
                                return switch (_controller.status.value) {
                                  PlayerStatus.buffering => ListenableBuilder(
                                    listenable: _controller.networkSpeed,
                                    builder:
                                        (context, child) => Text(
                                          _controller.networkSpeed.value.toNetworkSpeed(),
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                  ),
                                  _ => Text(' ', style: Theme.of(context).textTheme.labelSmall),
                                };
                              },
                            ),
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

class _ForceLandScapeButton extends StatelessWidget {
  const _ForceLandScapeButton({required this.forceLandScape, required this.onChanged});

  final bool forceLandScape;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).size.aspectRatio > 1;
    return forceLandScape
        ? IconButton.filled(
          onPressed: () {
            onChanged(false);
            setPreferredOrientations(true);
          },
          icon: const Icon(Icons.screen_rotation_rounded),
        )
        : !isLandscape
        ? IconButton(
          onPressed: () {
            onChanged(true);
            SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
          },
          icon: const Icon(Icons.screen_rotation_rounded),
        )
        : const SizedBox();
  }
}

class _PlaylistButton<T> extends StatelessWidget {
  const _PlaylistButton(this.controller);

  final PlayerController<T> controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (controller.playlist.value.length > 1 && width >= 400)
        ? IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              constraints: const BoxConstraints(),
              backgroundColor: Colors.transparent,
              barrierColor: Colors.transparent,
              useSafeArea: true,
              builder:
                  (context) => ListenableBuilder(
                    listenable: controller.index,
                    builder: (context, _) {
                      return _Playlist(
                        playlist: controller.playlist.value,
                        activeIndex: controller.index.value,
                        imageWidth: 160,
                        imageHeight: 90,
                        onTap: (index) async {
                          await controller.next(index);
                          switch (controller.status.value) {
                            case PlayerStatus.paused:
                            case PlayerStatus.ended:
                            case PlayerStatus.error:
                            case PlayerStatus.idle:
                              await controller.play();
                            case PlayerStatus.playing:
                            case PlayerStatus.buffering:
                          }
                        },
                      );
                    },
                  ),
            );
          },
          icon: const Icon(Icons.playlist_play_rounded),
        )
        : const SizedBox();
  }
}

class _Playlist extends StatefulWidget {
  const _Playlist({
    this.activeIndex,
    required this.playlist,
    this.onTap,
    required this.imageWidth,
    required this.imageHeight,
  });

  final double imageWidth;

  final double imageHeight;

  final int? activeIndex;
  final List<PlaylistItemDisplay<dynamic>> playlist;

  final ValueChanged<int>? onTap;

  @override
  State<_Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<_Playlist> {
  late final _controller = ScrollController(initialScrollOffset: (widget.activeIndex ?? 0) * (widget.imageWidth + 12));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _Playlist oldWidget) {
    final index = widget.activeIndex;
    if (index != oldWidget.activeIndex && index != null && index >= 0 && index < widget.playlist.length) {
      _controller.animateTo(
        index * (widget.imageWidth + 12),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.imageHeight + 114,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ),
      ),
      child: ListView.separated(
        controller: _controller,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemCount: widget.playlist.length,
        itemBuilder: (context, index) {
          final item = widget.playlist[index];
          return ImageCard(
            item.poster,
            width: widget.imageWidth,
            height: widget.imageHeight,
            title: item.title != null ? Text(item.title!) : null,
            subtitle: item.description != null ? Text(item.description!) : null,
            fit: item.source is Channel ? BoxFit.contain : BoxFit.cover,
            padding:
                item.source is Channel ? const EdgeInsets.symmetric(vertical: 12, horizontal: 18) : EdgeInsets.zero,
            floating:
                widget.activeIndex == index
                    ? Container(
                      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(0x66),
                      width: widget.imageWidth,
                      height: widget.imageHeight,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: PlayingIcon(color: Theme.of(context).colorScheme.primary),
                      ),
                    )
                    : null,
            onTap: widget.onTap == null ? null : () => widget.onTap!(index),
          );
        },
      ),
    );
  }
}

class SwitchLinkButton<T> extends StatefulWidget {
  const SwitchLinkButton(this.controller, {super.key});

  final PlayerController<T> controller;

  @override
  State<SwitchLinkButton<T>> createState() => _SwitchLinkButtonState<T>();
}

class _SwitchLinkButtonState<T> extends State<SwitchLinkButton<T>> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller.index,
      builder:
          (context, _) =>
              (widget.controller.currentItem?.source is Channel &&
                      (widget.controller.currentItem!.source as Channel).links.length > 1)
                  ? PopupMenuButton(
                    onSelected: (url) async {
                      await widget.controller.updateSource(
                        widget.controller.currentItem!.copyWith(url: url),
                        widget.controller.index.value!,
                      );
                      switch (widget.controller.status.value) {
                        case PlayerStatus.paused:
                        case PlayerStatus.ended:
                        case PlayerStatus.error:
                        case PlayerStatus.idle:
                          await widget.controller.play();
                        case PlayerStatus.playing:
                        case PlayerStatus.buffering:
                      }
                      setState(() {});
                    },
                    itemBuilder:
                        (context) =>
                            (widget.controller.currentItem!.source as Channel).links.indexed
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

class _ChannelListGrouped extends StatefulWidget {
  const _ChannelListGrouped({required this.controller, required this.onTap});

  final PlayerController<Channel> controller;
  final Function(int) onTap;

  @override
  State<_ChannelListGrouped> createState() => _ChannelListGroupedState();
}

class _ChannelListGroupedState extends State<_ChannelListGrouped> {
  late final _groupedPlaylist = widget.controller.playlist.value.groupListsBy((channel) => channel.source.category);
  late final _groupName = ValueNotifier<String?>(null);
  late final _playlist = ValueNotifier<List<PlaylistItemDisplay<Channel>>>([]);
  late final _epg = ValueNotifier<List<ChannelEpgItem>?>([]);

  @override
  void initState() {
    super.initState();
    final index = widget.controller.index.value;
    if (index != null) {
      _groupName.value = widget.controller.playlist.value[index].source.category;
      _playlist.value = _groupedPlaylist[_groupName.value]!;
      _updateEpg(widget.controller.currentItem!.source.id);
    }
  }

  @override
  void dispose() {
    _groupName.dispose();
    _playlist.dispose();
    _epg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: ListenableBuilder(
            listenable: _groupName,
            builder: (context, _) {
              return ListView.builder(
                itemCount: _groupedPlaylist.keys.length,
                itemBuilder: (context, index) {
                  final name = _groupedPlaylist.keys.elementAt(index) ?? AppLocalizations.of(context)!.tagUnknown;
                  return Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      dense: true,
                      selected: _groupName.value == name,
                      selectedTileColor: Colors.white38,
                      title: Text(name),
                      onTap: () {
                        _groupName.value = name;
                        _playlist.value = _groupedPlaylist[name]!;
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        const VerticalDivider(),
        Flexible(
          flex: 2,
          child: ListenableBuilder(
            listenable: Listenable.merge([_playlist, widget.controller.index]),
            builder: (context, _) {
              return ListView.builder(
                itemCount: _playlist.value.length,
                itemBuilder: (context, index) {
                  final item = _playlist.value.elementAt(index);
                  return Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      dense: true,
                      leading: item.poster != null ? AsyncImage(item.poster!, width: 40, showErrorWidget: false) : null,
                      trailing:
                          item == widget.controller.currentItem
                              ? PlayingIcon(color: Theme.of(context).colorScheme.inversePrimary)
                              : null,
                      selected: item == widget.controller.currentItem,
                      selectedTileColor: Colors.white38,
                      title: Text(item.title ?? ''),
                      onTap: () {
                        widget.onTap(widget.controller.playlist.value.indexOf(item));
                        _updateEpg(item.source.id);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        const VerticalDivider(),
        Flexible(
          flex: 3,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: ListenableBuilder(
              listenable: _epg,
              builder: (context, child) {
                return _epg.value == null
                    ? child!
                    : ListView.builder(
                      itemCount: _epg.value!.length,
                      itemBuilder: (context, index) {
                        final item = _epg.value![index];
                        final isPlaying = _isPlaying(item);
                        return Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            dense: true,
                            selected: isPlaying,
                            selectedTileColor: Colors.white38,
                            title: Text(item.title),
                            subtitle: Text(_epgTimeFormat(item)),
                          ),
                        );
                      },
                    );
              },
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateEpg(int id) async {
    _epg.value = null;
    _epg.value = await Api.epgQueryByChannelId(id);
  }

  bool _isPlaying(ChannelEpgItem item) {
    final now = DateTime.now();
    return item.start != null && item.stop != null && now >= item.start! && now <= item.stop!;
  }

  String _epgTimeFormat(ChannelEpgItem item) {
    if (item.start != null && item.stop != null) {
      return '${formatDate(item.start!, [HH, ':', nn])}-${formatDate(item.stop!, [HH, ':', nn])}';
    } else {
      return '';
    }
  }
}
