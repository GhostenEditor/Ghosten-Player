import 'dart:async';

import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:player_view/player.dart';
import 'package:provider/provider.dart';

import '../../components/async_image.dart';
import '../../components/focus_card.dart';
import '../../platform_api.dart';
import '../../providers/user_config.dart';

class LivePlayerPage extends StatefulWidget {
  final List<PlaylistItem> playlist;
  final int index;

  const LivePlayerPage({super.key, required this.playlist, required this.index});

  @override
  State<LivePlayerPage> createState() => _LivePlayerPageState();
}

class _LivePlayerPageState extends State<LivePlayerPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final _controller = PlayerController(widget.playlist, widget.index, Api.log);
  final _isShowControls = ValueNotifier(false);
  late final StreamSubscription<bool> _pipSubscription;

  @override
  void initState() {
    _pipSubscription = PlatformApi.pipEvent.listen((flag) {
      _controller.pipMode.value = flag;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
  }

  @override
  void dispose() {
    // todo: bug when SDK < 29
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _isShowControls.dispose();
    _controller.dispose();
    _pipSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerConfig = context.read<UserConfig>().playerConfig;
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
      ),
      child: Builder(builder: (context) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: kIsWeb ? Colors.transparent : Colors.black,
          body: Stack(
            children: [
              PlayerPlatformView(
                extensionRendererMode: playerConfig.mode,
                enableDecoderFallback: playerConfig.enableDecoderFallback,
              ),
              PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) async {
                  if (didPop) {
                    return;
                  }
                  if (PlatformApi.isAndroidTV() && _isShowControls.value) {
                    _hideControls();
                  } else {
                    await _controller.hide();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: FocusScope(
                  autofocus: true,
                  onKeyEvent: (node, event) {
                    if (!_isShowControls.value && event is KeyUpEvent) {
                      switch (event.logicalKey) {
                        case LogicalKeyboardKey.arrowUp:
                          _controller.next(_controller.index.value + 1);
                          return KeyEventResult.handled;
                        case LogicalKeyboardKey.arrowDown:
                          _controller.next(_controller.index.value - 1);
                          return KeyEventResult.handled;
                        case LogicalKeyboardKey.arrowLeft:
                          _controller.seekTo(_controller.position.value - const Duration(seconds: 30));
                          return KeyEventResult.handled;
                        case LogicalKeyboardKey.arrowRight:
                          _controller.seekTo(_controller.position.value + const Duration(seconds: 30));
                          return KeyEventResult.handled;
                        case LogicalKeyboardKey.select:
                          _toggleControls();
                          return KeyEventResult.handled;
                        case LogicalKeyboardKey.contextMenu:
                          _showPlaylist(context);
                          return KeyEventResult.handled;
                        case LogicalKeyboardKey.goBack:
                          if (PlatformApi.isAndroidTV() && _isShowControls.value) {
                            _hideControls();
                            return KeyEventResult.handled;
                          }
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleControls,
                    child: ListenableBuilder(
                      listenable: _isShowControls,
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
                        child: _isShowControls.value
                            ? child!
                            : ListenableBuilder(
                                listenable: _controller.status,
                                builder: (context, _) => switch (_controller.status.value) {
                                      PlayerStatus.buffering => const Center(child: CircularProgressIndicator()),
                                      _ => const SizedBox.expand(),
                                    }),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black26, Colors.black26, Colors.transparent],
                          stops: [0, 0.3, 0.7, 1],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )),
                        child: SafeArea(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: PlatformApi.isAndroidTV() ? 72 : 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PlayerInfoView(_controller),
                                  PlayerButtons(controller: _controller, isTV: PlatformApi.isAndroidTV(), onActionPlaylist: _showPlaylist),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  _toggleControls() {
    _isShowControls.value = !_isShowControls.value;
  }

  _hideControls() {
    _isShowControls.value = false;
  }

  _showPlaylist(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
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
                playlistItemBuilder: (context, index, onTap) {
                  final item = _controller.playlist[index];
                  return SizedBox(
                    width: 200,
                    child: FocusCard(
                      scale: 1.05,
                      autofocus: index == _controller.index.value,
                      onTap: () => onTap(index),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                item.poster != null
                                    ? AsyncImage(
                                        item.poster!,
                                        ink: true,
                                        fit: BoxFit.contain,
                                        padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
                                      )
                                    : Container(
                                        color: Theme.of(context).colorScheme.onSurface.withAlpha(0x11), child: const Icon(Icons.image_not_supported, size: 50)),
                                if (index == _controller.index.value)
                                  Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.play_circle_rounded, color: Theme.of(context).colorScheme.primary),
                                      )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.title != null) Text(item.title!, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                                if (item.description != null)
                                  Text(item.description!, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}
