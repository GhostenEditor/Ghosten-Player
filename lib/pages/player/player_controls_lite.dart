import 'dart:async';

import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/player.dart';

import '../../components/error_message.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_config.dart';
import '../../utils/utils.dart';
import '../player/player_controls_full.dart';
import '../utils/utils.dart';
import 'cast_adaptor.dart';
import 'player_appbar.dart';
import 'player_controls_gesture.dart';

class PlayerControlsLite<T> extends StatefulWidget {
  const PlayerControlsLite(this.controller, {super.key, this.theme, this.artwork, this.initialized});

  final PlayerController<T> controller;
  final VoidCallback? initialized;
  final int? theme;
  final Widget? artwork;

  @override
  State<PlayerControlsLite<T>> createState() => _PlayerControlsLiteState<T>();
}

class _PlayerControlsLiteState<T> extends State<PlayerControlsLite<T>> {
  late final _controller = widget.controller;
  late final _progressController = PlayerProgressController(widget.controller);
  final _isShowControls = ValueNotifier(true);
  final _controlsStream = StreamController<ControlsStreamStatus>();
  StreamSubscription<bool>? _subscription;
  final _aspectRatio = 16 / 9;

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
          _isShowControls.value = show;
        });
    _controlsStream.add(ControlsStreamStatus.show);
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
    _isShowControls.dispose();
    _subscription?.cancel();
    if (!kIsWeb) ScreenBrightness.instance.resetApplicationScreenBrightness();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        if (context.mounted && Navigator.of(context).canPop()) Navigator.pop(context);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxWidth / _aspectRatio + MediaQuery.paddingOf(context).top;
          return SizedBox(
            height: height,
            child: Theme(
              data: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: widget.theme != null ? Color(widget.theme!) : Colors.blue,
                  brightness: Brightness.dark,
                ),
                appBarTheme: const AppBarTheme(iconTheme: IconThemeData(size: 20)),
              ),
              child: Scaffold(
                appBar: PlayerAppbar(
                  show: _isShowControls,
                  title: _buildAppbarTitle(context),
                  actions: [
                    IconButton(
                      onPressed: () async {
                        if (_controller.index.value == null) return;
                        final device = await showModalBottomSheet<CastDevice>(
                          context: context,
                          builder:
                              (context) => PlayerCastSearcher(
                                const CastAdaptor(),
                                errorWidget:
                                    (context, error) =>
                                        ErrorMessage(error: error, padding: const EdgeInsets.symmetric(horizontal: 16)),
                              ),
                        );
                        if (device != null && context.mounted) {
                          _controller.pause();
                          await navigateToSlideUp(
                            context,
                            PlayerCast(
                              device: device,
                              playlist: _controller.playlist.value,
                              index: _controller.index.value!,
                              theme: widget.theme,
                              onGetPlayBackInfo: widget.controller.onGetPlayBackInfo,
                            ),
                          );
                          if (context.mounted) await _controller.play();
                        }
                      },
                      icon: const Icon(Icons.airplay_rounded),
                    ),
                    const IconButton(onPressed: null, icon: Icon(Icons.more_vert_rounded)),
                  ],
                ),
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                extendBodyBehindAppBar: true,
                extendBody: true,
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.artwork != null)
                      ListenableBuilder(
                        listenable: _controller.status,
                        builder:
                            (context, child) => PageTransitionSwitcher(
                              duration: const Duration(milliseconds: 500),
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
                              child: _controller.status.value == PlayerStatus.idle ? child! : const SizedBox(),
                            ),
                        child: widget.artwork,
                      ),
                    ListenableBuilder(
                      listenable: _isShowControls,
                      builder: (context, child) {
                        return AnimatedOpacity(
                          opacity: _isShowControls.value ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black54, Colors.transparent, Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ),
                    ListenableBuilder(
                      listenable: _controller.status,
                      builder:
                          (context, child) =>
                              _controller.status.value == PlayerStatus.buffering ? child! : const SizedBox(),
                      child: Center(
                        child: ListenableBuilder(
                          listenable: _controller.networkSpeed,
                          builder:
                              (context, _) => Text(
                                _controller.networkSpeed.value.toNetworkSpeed(),
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AspectRatio(
                        aspectRatio: _aspectRatio,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (_isShowControls.value) {
                              _controlsStream.add(ControlsStreamStatus.hide);
                            } else {
                              _controlsStream.add(ControlsStreamStatus.show);
                            }
                          },
                          child: PlayerControlsGesture(
                            controller: _controller,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                PlayerPlatformView(
                                  initialized: widget.initialized,
                                  autoPip: context.read<UserConfig>().autoPip,
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
                                        child: _isShowControls.value ? _buildControls(context) : const SizedBox(),
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
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppbarTitle(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller.index,
      builder: (context, _) {
        final source = _controller.currentItem?.source;
        if (source is TVEpisode) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(source.displayTitle(), style: Theme.of(context).textTheme.titleSmall),
              Text(
                '${source.seriesTitle} S${source.season} E${source.episode}${source.airDate == null ? '' : ' - ${source.airDate?.format()}'}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          );
        } else if (source is Movie) {
          return Text(source.displayTitle(), style: Theme.of(context).textTheme.titleSmall);
        } else if (source is Channel) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(source.title ?? '', style: Theme.of(context).textTheme.titleSmall),
              Text(source.category ?? '', style: Theme.of(context).textTheme.labelSmall),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildControls(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ListenableBuilder(
            listenable: _controller.fatalError,
            builder:
                (context, _) =>
                    _controller.fatalError.value != null
                        ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _controller.fatalError.value!,
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                            maxLines: 6,
                          ),
                        )
                        : const SizedBox(),
          ),
          Row(
            children: [
              ListenableBuilder(
                listenable: _controller.status,
                builder: (context, _) {
                  return switch (_controller.status.value) {
                    PlayerStatus.playing => IconButton(
                      onPressed: _controller.pause,
                      icon: const Icon(Icons.pause_rounded),
                    ),
                    PlayerStatus.buffering => SizedBox.square(
                      dimension: 48,
                      child: Center(child: Transform.scale(scale: 0.5, child: const CircularProgressIndicator())),
                    ),
                    PlayerStatus.paused || PlayerStatus.idle || PlayerStatus.ended || PlayerStatus.error => IconButton(
                      onPressed: _controller.play,
                      icon: const Icon(Icons.play_arrow_rounded),
                    ),
                  };
                },
              ),
              Expanded(
                child: PlayerProgressView(
                  _progressController,
                  thickness: 6,
                  showLabel: false,
                  scalable: false,
                  seekStart: () => _controller.pause(),
                  seekEnd: (position) {
                    _controller.seekTo(position);
                    _controller.play();
                  },
                ),
              ),
              PlayerProgressLabel(controller: _progressController),
              SwitchLinkButton(_controller),
              IconButton(
                onPressed: () {
                  navigateTo(context, PlayerControlsFull(_controller, _progressController, theme: widget.theme));
                },
                icon: const Icon(Icons.fullscreen_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
