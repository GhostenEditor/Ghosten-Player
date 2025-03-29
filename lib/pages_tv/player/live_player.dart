import 'dart:async';

import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/player.dart';

import '../../components/async_image.dart';
import '../../theme.dart';
import '../components/focusable_image.dart';
import '../components/loading.dart';
import '../components/setting.dart';

class LivePlayerPage extends StatefulWidget {
  const LivePlayerPage({super.key, required this.playlist, required this.index});

  final List<PlaylistItem<Channel>> playlist;
  final int index;

  @override
  State<LivePlayerPage> createState() => _LivePlayerPageState();
}

class _LivePlayerPageState extends State<LivePlayerPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final _controller = PlayerController<Channel>(Api.log);
  final _isShowControls = ValueNotifier(false);
  final _controlsStream = StreamController<ControlsStreamStatus>();
  final _drawerUpdateStream = ValueNotifier(0);
  ScrollController _scrollController = ScrollController();
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
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
    _controller.index.addListener(() => _controlsStream.add(ControlsStreamStatus.show));
    _controlsStream.add(ControlsStreamStatus.show);
    super.initState();
  }

  @override
  void dispose() {
    _isShowControls.dispose();
    _controller.dispose();
    _subscription?.cancel();
    _scrollController.dispose();
    _drawerUpdateStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: tvDarkTheme,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawerScrimColor: Colors.transparent,
        drawer: SizedBox(
          width: 360,
          child: Drawer(
            child: ListenableBuilder(
                listenable: Listenable.merge([_controller.index, _drawerUpdateStream]),
                builder: (context, _) {
                  return GridView.builder(
                      controller: _scrollController,
                      itemCount: widget.playlist.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 198,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
                      itemBuilder: (context, index) {
                        final item = widget.playlist[index];
                        return _ChannelGridItem(
                            key: ValueKey(item.url),
                            item: item,
                            autofocus: index == _controller.index.value,
                            selected: index == _controller.index.value,
                            onTap: () {
                              _controller.next(index);
                            });
                      });
                }),
          ),
        ),
        endDrawer: SizedBox(
            width: 300,
            child: SettingPage(
              title: AppLocalizations.of(context)!.playerBroadcastLine,
              child: StatefulBuilder(builder: (context, setState) {
                return ListenableBuilder(
                    listenable: _controller.index,
                    builder: (context, _) => ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _controller.currentItem?.source.links.length ?? 0,
                          itemBuilder: (context, index) {
                            final url = _controller.currentItem!.source.links[index];
                            return RadioSettingItem(
                              autofocus: _controller.currentItem?.url == url,
                              groupValue: _controller.currentItem?.url,
                              value: url,
                              title: Text('${AppLocalizations.of(context)!.playerBroadcastLine} ${index + 1}'),
                              onChanged: (_) {
                                final currentItem = _controller.currentItem!;
                                final item = PlaylistItem(
                                    url: url, sourceType: PlaylistItemSourceType.fromBroadcastUri(url), source: currentItem.source, poster: currentItem.poster);
                                _controller.playlist.value[_controller.index.value!] = item;
                                _controller.updateSource(item, _controller.index.value!);
                                setState(() {});
                              },
                            );
                          },
                        ));
              }),
            )),
        body: Stack(
          fit: StackFit.expand,
          children: [
            PlayerPlatformView(initialized: () async {
              await _controller.setSources(widget.playlist, widget.index);
              await _controller.play();
            }),
            PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) {
                  return;
                }
                if (_isShowControls.value) {
                  _hideControls();
                } else {
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: FocusScope(
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is KeyUpEvent) {
                    switch (event.logicalKey) {
                      case LogicalKeyboardKey.arrowUp:
                        if (_controller.index.value != null) _controller.next(_controller.index.value! + 1);
                        return KeyEventResult.handled;
                      case LogicalKeyboardKey.arrowDown:
                        if (_controller.index.value != null) _controller.next(_controller.index.value! - 1);
                        return KeyEventResult.handled;
                      case LogicalKeyboardKey.arrowRight:
                        if (_controller.currentItem != null && _controller.currentItem!.source.links.length > 1) {
                          _scaffoldKey.currentState!.openEndDrawer();
                        }
                        return KeyEventResult.handled;
                      case LogicalKeyboardKey.select:
                        if (_isShowControls.value) {
                          _controlsStream.add(ControlsStreamStatus.hide);
                        } else {
                          _controlsStream.add(ControlsStreamStatus.show);
                        }
                        return KeyEventResult.handled;
                      case LogicalKeyboardKey.arrowLeft:
                      case LogicalKeyboardKey.contextMenu:
                      case LogicalKeyboardKey.browserFavorites:
                        if (_controller.index.value != null) _drawerUpdateStream.value = 170 * (_controller.index.value! ~/ 2);
                        _scrollController.dispose();
                        _scrollController = ScrollController(initialScrollOffset: _drawerUpdateStream.value.toDouble());
                        _scaffoldKey.currentState!.openDrawer();
                        return KeyEventResult.handled;
                      case LogicalKeyboardKey.goBack:
                        if (_isShowControls.value) {
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
                      child: _isShowControls.value ? child! : const SizedBox.expand(),
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 12),
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.4, 0.8],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListenableBuilder(
                                  listenable: _controller.fatalError,
                                  builder: (context, _) => _controller.fatalError.value != null
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(_controller.fatalError.value!, style: TextStyle(color: Theme.of(context).colorScheme.error), maxLines: 6),
                                        )
                                      : const SizedBox()),
                              _PlayerInfo(controller: _controller),
                            ],
                          )),
                    ),
                  ),
                ),
              ),
            ),
            ListenableBuilder(
                listenable: _controller.status,
                builder: (context, _) => switch (_controller.status.value) {
                      PlayerStatus.buffering => const Loading(),
                      _ => const SizedBox.expand(),
                    })
          ],
        ),
      ),
    );
  }

  void _toggleControls() {
    if (_isShowControls.value) {
      _controlsStream.add(ControlsStreamStatus.hide);
    } else {
      _controlsStream.add(ControlsStreamStatus.show);
    }
  }

  void _hideControls() {
    _controlsStream.add(ControlsStreamStatus.hide);
  }
}

class _PlayerInfo extends StatelessWidget {
  const _PlayerInfo({required this.controller});

  final PlayerController<dynamic> controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: controller.index,
        builder: (context, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.currentItem?.poster != null)
                  AsyncImage(
                    controller.currentItem!.poster!,
                    height: 160,
                    width: 160,
                    needLoading: false,
                    errorIconSize: 56,
                    fit: BoxFit.contain,
                  ),
                const SizedBox(width: 36),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.index.value != null)
                      Text('${controller.index.value! + 1}'.padLeft(3, '0'),
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold)),
                    Text(controller.title.value ?? '', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                    Text(controller.currentItem?.description ?? '', style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 36),
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.labelMedium!,
                  child: ListenableBuilder(
                      listenable: controller.mediaInfo,
                      builder: (context, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Badge(label: Text('Video'), backgroundColor: Colors.purpleAccent, textColor: Colors.black),
                                  const SizedBox(width: 12),
                                  Text(controller.mediaInfo.value?.videoMime ?? ''),
                                  const SizedBox(width: 12),
                                  Text(controller.mediaInfo.value?.videoSize ?? ''),
                                  const SizedBox(width: 12),
                                  Text('${controller.mediaInfo.value?.videoFPS ?? ''} fps / ${controller.mediaInfo.value?.videoBitrate} bps'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Badge(label: Text('Audio'), backgroundColor: Colors.greenAccent, textColor: Colors.black),
                                  const SizedBox(width: 12),
                                  Text(controller.mediaInfo.value?.audioMime ?? ''),
                                  const SizedBox(width: 12),
                                  Text('${controller.mediaInfo.value?.audioBitrate ?? ''} bps'),
                                ],
                              ),
                            ],
                          )),
                ),
              ],
            ));
  }
}

class _ChannelGridItem extends StatelessWidget {
  const _ChannelGridItem({super.key, required this.item, this.onTap, this.autofocus, this.selected});

  final PlaylistItem<dynamic> item;
  final GestureTapCallback? onTap;
  final bool? autofocus;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FocusableImage(
          autofocus: autofocus,
          poster: item.poster,
          fit: BoxFit.contain,
          padding: const EdgeInsets.all(36),
          selected: selected,
          httpHeaders: const {},
          onTap: onTap,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (item.title != null) Text(item.title!, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
              if (item.description != null) Text(item.description!, style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis),
            ],
          ),
        )
      ],
    );
  }
}
