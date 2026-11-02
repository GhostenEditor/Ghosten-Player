import 'dart:async';

import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile, RadioListTile;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/player.dart';

import '../../../components/components.dart';
import '../../../details/playlist.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/models.dart';
import '../../../providers/player.dart';
import '../../../providers/shortcut_tv.dart';
import '../components/radio_list_tile.dart';
import '../components/setting_page.dart';
import '../theme.dart';

class LivePlayerPage extends StatefulWidget {
  const LivePlayerPage({super.key, required this.data});

  final PlaylistData data;

  @override
  State<LivePlayerPage> createState() => _LivePlayerPageState();
}

class _LivePlayerPageState extends State<LivePlayerPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final _controller = PlayerController();
  final ValueNotifier<bool> _isShowControls = ValueNotifier(false);
  final _controlsStream = StreamController<ControlsStreamStatus>();
  final ValueNotifier<int> _drawerUpdateStream = ValueNotifier(0);
  ScrollController _scrollController = ScrollController();
  StreamSubscription<bool>? _subscription;

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
    final ShortcutTV shortcuts = context.read<ShortcutTV>();
    final PlayerConfig playerConfig = context.read<PlayerConfig>();
    final String languageCode = Localizations.localeOf(context).languageCode;
    return Theme(
      data: darkTheme,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawerScrimColor: Colors.transparent,
        drawer: Container(
          height: MediaQuery.sizeOf(context).height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.black87, Colors.transparent], stops: [0.2, 0.8]),
          ),
          child: ValueListenableBuilder(
            valueListenable: _controller.playlist,
            builder: (context, value, child) {
              return ChannelsPage(
                items: value.map((item) => item.source).toList().cast(),
                activeIndex: _controller.index.value,
                showEpg: true,
                onTap: (index) async {
                  await _controller.next(index);
                  if (!_controller.isPlaying.value) {
                    await _controller.play();
                  }
                },
              );
            },
          ),
        ),
        endDrawer: Drawer(
          child: SettingPage(
            title: Text(AppLocalizations.of(context)!.playerBroadcastLine),
            child: StatefulBuilder(
              builder: (context, setState) {
                final channel = _controller.currentItem?.source as Channel?;
                return ValueListenableBuilder(
                  valueListenable: _controller.index,
                  builder: (context, _, _) => RadioGroup(
                    groupValue: _controller.currentItem?.url,
                    onChanged: (url) async {
                      final PlaylistItem currentItem = _controller.currentItem!;
                      await _controller.updateSource(currentItem.copyWith(url: url), _controller.index.value!);
                      if (!_controller.isPlaying.value) {
                        await _controller.play();
                      }
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: channel?.links.length ?? 0,
                      itemBuilder: (context, index) {
                        final Uri url = channel!.links[index];
                        return RadioListTile(
                          autofocus: _controller.currentItem?.url == url,
                          value: url,
                          title: Text('${AppLocalizations.of(context)!.playerBroadcastLine} ${index + 1}'),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        body: PlayerPlatformView(
          playerType: playerConfig.playerType,
          mpvVersion: playerConfig.mpvVersion,
          initialized: () async {
            _controller.setPlaylist(widget.data.playlist.cast());
            await _controller.next(widget.data.activeIndex);
            await _controller.play();
          },
          initializeFailed: (e) => _controller.fatalError.value = e.message,
          extensionRendererMode: playerConfig.extensionRendererMode,
          enableDecoderFallback: playerConfig.enableDecoderFallback,
          subtitleStyle: playerConfig.subtitleSettings,
          preferredSubtitleLanguage: playerConfig.preferredSubtitleLanguage ?? languageCode,
          preferredAudioLanguage: playerConfig.preferredAudioLanguage ?? languageCode,
          controls: Stack(
            children: [
              PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) {
                  if (didPop) {
                    return;
                  }
                  if (_scaffoldKey.currentState!.isDrawerOpen) {
                    return _scaffoldKey.currentState!.closeDrawer();
                  }
                  if (_scaffoldKey.currentState!.isEndDrawerOpen) {
                    return _scaffoldKey.currentState!.closeEndDrawer();
                  }
                  if (_isShowControls.value) {
                    _controlsStream.add(ControlsStreamStatus.hide);
                  } else {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: FocusScope(
                  autofocus: true,
                  onKeyEvent: (node, event) {
                    if (event is KeyUpEvent) {
                      if (event.logicalKey == shortcuts.nextChannel) {
                        if (_controller.index.value != null) {
                          _controller.next(_controller.index.value! + 1);
                        }
                        if (!_controller.isPlaying.value) {
                          _controller.play();
                        }
                        return KeyEventResult.handled;
                      } else if (event.logicalKey == shortcuts.previousChannel) {
                        if (_controller.index.value != null) {
                          _controller.next(_controller.index.value! - 1);
                        }
                        if (!_controller.isPlaying.value) {
                          _controller.play();
                        }
                        return KeyEventResult.handled;
                      } else if (event.logicalKey == LogicalKeyboardKey.select) {
                        _controlsStream.add(
                          _isShowControls.value ? ControlsStreamStatus.hide : ControlsStreamStatus.show,
                        );
                        return KeyEventResult.handled;
                      } else if (event.logicalKey == shortcuts.switchLinePanel) {
                        if (_controller.currentItem != null &&
                            (_controller.currentItem!.source as Channel).links.length > 1) {
                          _scaffoldKey.currentState!.openEndDrawer();
                        }
                        return KeyEventResult.handled;
                      } else if (event.logicalKey == shortcuts.channelsPanel) {
                        if (_controller.index.value != null) {
                          _drawerUpdateStream.value = 170 * (_controller.index.value! ~/ 2);
                        }
                        _scrollController.dispose();
                        _scrollController = ScrollController(initialScrollOffset: _drawerUpdateStream.value.toDouble());
                        _scaffoldKey.currentState!.openDrawer();
                        return KeyEventResult.handled;
                      } else if (event.logicalKey == LogicalKeyboardKey.goBack) {
                        if (_isShowControls.value) {
                          _controlsStream.add(ControlsStreamStatus.hide);
                          return KeyEventResult.handled;
                        }
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: ValueListenableBuilder(
                    valueListenable: _isShowControls,
                    builder: (context, value, child) => PageTransitionSwitcher(
                      reverse: !value,
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation, secondaryAnimation) => SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.vertical,
                        fillColor: Colors.transparent,
                        child: child,
                      ),
                      child: _isShowControls.value ? child! : const SizedBox.expand(),
                    ),
                    child: Container(
                      height: MediaQuery.sizeOf(context).height,
                      padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black87],
                          stops: [0.4, 0.8],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: _controller.fatalError,
                              builder: (context, value, _) => value != null
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        value,
                                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                                        maxLines: 6,
                                      ),
                                    )
                                  : const SizedBox(),
                            ),
                            _PlayerInfo(controller: _controller),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _controller.playbackState,
                builder: (context, value, _) => switch (value) {
                  .buffering => const Loading(),
                  _ => const SizedBox(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerInfo extends StatelessWidget {
  const _PlayerInfo({required this.controller});

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: controller.index,
        builder: (context, _, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.currentItem?.poster != null)
              AsyncImage(
                controller.currentItem!.poster!,
                width: 160,
                needLoading: false,
                errorIconSize: 56,
                alignment: .bottomCenter,
              ),
            const SizedBox(width: 36),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.index.value != null)
                  Text(
                    '${controller.index.value! + 1}'.padLeft(3, '0'),
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                Text(
                  controller.title.value ?? '',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  controller.currentItem?.description ?? '',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 36),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.labelMedium!,
              child: ValueListenableBuilder(
                valueListenable: controller.trackGroup,
                builder: (context, value, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Badge(
                          label: Text('Video'),
                          backgroundColor: Colors.purpleAccent,
                          textColor: Colors.black,
                        ),
                        const SizedBox(width: 12),
                        Text(value.selectedVideo?.sampleMimeType ?? ''),
                        const SizedBox(width: 12),
                        Text('${value.selectedVideo?.width} x ${value.selectedVideo?.height}'),
                        const SizedBox(width: 12),
                        Text('${value.selectedVideo?.frameRate ?? ''} fps / ${value.selectedVideo?.bitrate} bps'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Badge(label: Text('Audio'), backgroundColor: Colors.greenAccent, textColor: Colors.black),
                        const SizedBox(width: 12),
                        Text(value.selectedAudio?.sampleMimeType ?? ''),
                        const SizedBox(width: 12),
                        Text('${value.selectedAudio?.sampleRate ?? ''} bps'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
