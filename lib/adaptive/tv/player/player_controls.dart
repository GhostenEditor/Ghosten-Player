import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/player.dart';

import '../../../components/components.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/player.dart';
import '../../../utils/utils.dart';

enum _PlayerPanelType { progressbar, playlist, none }

class PlayerControls extends StatefulWidget {
  const PlayerControls({super.key, required this.controller});

  final PlayerController controller;

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  late final PlayerController _controller = widget.controller;
  late final _progressController = PlayerProgressController(_controller);
  final _progressFocusNode = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controlsStream = StreamController<ControlsStreamStatus>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final ValueNotifier<_PlayerPanelType> _panelType = ValueNotifier(_PlayerPanelType.none);
  final ValueNotifier<bool> _showLiteProgressbar = ValueNotifier(false);
  Duration _seekStep = const Duration(seconds: 30);
  StreamSubscription<bool>? _subscription;
  bool _reverse = false;

  @override
  void initState() {
    final PlayerConfig playerConfig = context.read<PlayerConfig>();
    _seekStep = Duration(seconds: playerConfig.fastForwardSpeed);
    _showLiteProgressbar.value = playerConfig.showLiteProgressbar;
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
    widget.controller.playbackState.addListener(() {
      switch (_controller.playbackState.value) {
        case .ready:
          _controlsStream.add(ControlsStreamStatus.show);
        case .ended:
        case .idle:
          _controlsStream.add(ControlsStreamStatus.showInfinite);
        case .buffering:
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
    _progressFocusNode.dispose();
    _controlsStream.close();
    _progressController.dispose();
    _panelType.dispose();
    _showLiteProgressbar.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Navigator.pop(context);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            ListenableBuilder(
              listenable: _panelType,
              builder: (context, child) => PageTransitionSwitcher(
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
              listenable: Listenable.merge([_controller.playbackState, _controller.isPlaying]),
              builder: (context, child) => PageTransitionSwitcher(
                duration: const Duration(milliseconds: 200),
                layoutBuilder: (List<Widget> entries) {
                  return Stack(alignment: Alignment.bottomCenter, children: entries);
                },
                transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation) {
                  return FadeThroughTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    fillColor: Colors.transparent,
                    child: child,
                  );
                },
                child: switch (_controller.playbackState.value) {
                  .buffering => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12,
                      children: [
                        Loading(color: Theme.of(context).colorScheme.primary),
                        ListenableBuilder(
                          listenable: widget.controller.networkSpeed,
                          builder: (context, _) => Text(
                            widget.controller.networkSpeed.value.toNetworkSpeed(),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  .ready =>
                    !_controller.isPlaying.value
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                              child: const Icon(Icons.pause, size: 50),
                            ),
                          )
                        : const SizedBox(),
                  _ => const SizedBox(),
                },
              ),
            ),
            _buildPanel(context),
            ListenableBuilder(
              listenable: Listenable.merge([_panelType, _showLiteProgressbar]),
              builder: (context, child) {
                return (_panelType.value == _PlayerPanelType.none && _showLiteProgressbar.value)
                    ? child!
                    : const SizedBox();
              },
              child: Align(
                alignment: Alignment.bottomCenter,
                child: PlayerLiteProgressbar(controller: _progressController),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraw(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) {
        _navigatorKey.currentState!.maybePop();
      },
      child: Drawer(
        child: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (settings) => FadeInPageRoute(
            builder: (context) => PlayerSettings(
              controller: _controller,
              onSeekSpeedChanged: (speed) => _seekStep = Duration(seconds: speed),
              onShowLiteProgressbarChanged: (value) => _showLiteProgressbar.value = value,
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
        builder: (context, _) => PageTransitionSwitcher(
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
                          if (widget.controller.isPlaying.value) {
                            widget.controller.pause();
                            return KeyEventResult.handled;
                          } else if (!widget.controller.isPlaying.value) {
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
        builder: (context, _) => FocusScope(
          child: PlayerPlaylist(
            playlist: widget.controller.playlist.value,
            activeIndex: widget.controller.index.value,
            onTap: (index) async {
              await widget.controller.next(index);
              if (!widget.controller.isPlaying.value) {
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
          _scaffoldKey.currentState?.openEndDrawer();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          if (_panelType.value == _PlayerPanelType.none) {
            switch (widget.controller.playbackState.value) {
              case .ready:
              case .buffering:
                if (widget.controller.isPlaying.value) {
                  widget.controller.pause();
                } else {
                  widget.controller.play();
                }
              default:
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

class PlayerLiteProgressbar extends StatefulWidget {
  const PlayerLiteProgressbar({super.key, required this.controller});

  final PlayerProgressController controller;

  @override
  State<PlayerLiteProgressbar> createState() => _PlayerLiteProgressbarState();
}

class _PlayerLiteProgressbarState extends State<PlayerLiteProgressbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: widget.controller.position / widget.controller.duration,
      backgroundColor: Colors.transparent,
    );
  }

  void _update() {
    setState(() {});
  }
}

class PlayerInfoView extends StatelessWidget {
  const PlayerInfoView(this._controller, {super.key, this.showPoster = true});

  final PlayerController _controller;
  final bool showPoster;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_controller.index, _controller.fatalError]),
      builder: (context, _) => Padding(
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
                    Text(_controller.fatalError.value!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
