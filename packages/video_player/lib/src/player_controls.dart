import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import '../player.dart';
import 'player_platform_interface.dart';

class PlayerSpeed {
  const PlayerSpeed({required this.value, required this.text});

  final String text;
  final double value;
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

class PlayerZoomWrapper extends StatefulWidget {
  const PlayerZoomWrapper({
    super.key,
    required this.controller,
    required this.child,
    this.minScale = 0.3,
    this.maxScale = 3,
    required this.onZoomChanged,
  });

  final PlayerController<dynamic> controller;
  final Widget child;
  final double minScale;
  final double maxScale;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<PlayerZoomWrapper> createState() => PlayerZoomWrapperState();
}

class PlayerZoomWrapperState extends State<PlayerZoomWrapper> {
  late final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
  final _controller = TransformationController();
  late Matrix4 _initialMatrix;
  late Offset _initialFocalPoint;
  late double _initialScale;

  @override
  void initState() {
    super.initState();
    _controller.value = Matrix4.identity();
    _initialMatrix = Matrix4.identity();
    _initialFocalPoint = Offset.zero;
    _initialScale = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.controller.setTransform([1, 0, 0, 0, 1, 0, 0, 0, 1]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        ScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
          () => ScaleGestureRecognizer(),
          (instance) => instance
            ..onStart = _handleScaleStart
            ..onUpdate = _handleScaleUpdate,
        ),
      },
      behavior: HitTestBehavior.opaque,
      child: Transform(transform: _controller.value, alignment: Alignment.center, child: widget.child),
    );
  }

  void reset() {
    if (_controller.value != Matrix4.identity()) {
      widget.controller.setTransform([1, 0, 0, 0, 1, 0, 0, 0, 1]);
      _controller.value = Matrix4.identity();
      widget.onZoomChanged(false);
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (details.pointerCount != 2) return;
    _initialMatrix = _controller.value.clone();
    _initialFocalPoint = details.localFocalPoint;
    _initialScale = _controller.value.getMaxScaleOnAxis();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount != 2) return;
    final newScale = (_initialScale * details.scale).clamp(widget.minScale, widget.maxScale);

    final scaleFactor = newScale / _initialScale;

    final focalPointVector = vm.Vector3(_initialFocalPoint.dx, _initialFocalPoint.dy, 0);

    final transformedFocalPoint = _initialMatrix.perspectiveTransform(focalPointVector);
    final focalOffset = Offset(transformedFocalPoint.x, transformedFocalPoint.y);

    final matrix = Matrix4.identity()
      ..translate(focalOffset.dx, focalOffset.dy)
      ..scale(scaleFactor)
      ..translate(-focalOffset.dx, -focalOffset.dy)
      ..multiply(_initialMatrix);

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
    widget.onZoomChanged(true);
    _controller.value = matrix;
  }
}

class PlayerPlayButton<T> extends StatelessWidget {
  const PlayerPlayButton(this.controller, {super.key});

  final PlayerController<T> controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.status,
      builder: (context, _) {
        return switch (controller.status.value) {
          PlayerStatus.playing => IconButton(onPressed: controller.pause, icon: const Icon(Icons.pause_rounded)),
          PlayerStatus.buffering => SizedBox.square(
            dimension: 48,
            child: Center(child: Transform.scale(scale: 0.5, child: const CircularProgressIndicator())),
          ),
          PlayerStatus.paused ||
          PlayerStatus.idle ||
          PlayerStatus.ended => IconButton(onPressed: controller.play, icon: const Icon(Icons.play_arrow_rounded)),
          PlayerStatus.error => IconButton(
            onPressed: null,
            icon: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          ),
        };
      },
    );
  }
}

class PlayerPreviousButton<T> extends StatelessWidget {
  const PlayerPreviousButton(this.controller, {super.key});

  final PlayerController<T> controller;

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

class PlayerNextButton<T> extends StatelessWidget {
  const PlayerNextButton(this.controller, {super.key});

  final PlayerController<T> controller;

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

class PlayerSubtitleButton<T> extends StatelessWidget {
  const PlayerSubtitleButton(this.controller, {super.key});

  final PlayerController<T> controller;

  @override
  Widget build(BuildContext context) {
    final localizations = PlayerLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller.trackGroup,
      builder: (context, _) {
        return controller.trackGroup.value.sub.isNotEmpty
            ? PopupMenuButton(
                onSelected: (id) => controller.setTrack('sub', id),
                itemBuilder: (context) => [
                  CheckedPopupMenuItem(
                    checked: controller.trackGroup.value.selectedSub == null,
                    value: 'null',
                    child: Text(localizations.videoSettingsNone),
                  ),
                  ...controller.trackGroup.value.sub.map(
                    (e) => CheckedPopupMenuItem(
                      checked: controller.trackGroup.value.selectedSub == e.id,
                      value: e.id,
                      child: Text(e.label ?? localizations.tagUnknown),
                    ),
                  ),
                ],
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
}

class PlayerPlaybackSpeedButton<T> extends StatelessWidget {
  const PlayerPlaybackSpeedButton(this.controller, {super.key});

  final PlayerController<T> controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.playbackSpeed,
      builder: (context, _) => PopupMenuButton(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [const Icon(Icons.slow_motion_video_rounded), Text(' ${controller.playbackSpeed.value}x')],
        ),
      ),
    );
  }
}

class PlayerLocalizations extends InheritedWidget {
  const PlayerLocalizations({
    super.key,
    required this.settingsTitle,
    required this.videoSettingsVideo,
    required this.videoSettingsAudio,
    required this.videoSettingsSubtitle,
    required this.videoSettingsSpeeding,
    required this.videoSettingsNone,
    required this.videoSize,
    required this.playerEnableDecoderFallback,
    required this.playerShowLiteProgressbar,
    required this.tagUnknown,
    required this.willSkipEnding,
    required this.extensionRendererMode,
    required this.extensionRendererModeLabel,
    required this.playerShowThumbnails,
    required this.subtitleSetting,
    required this.subtitleSettingExample,
    required this.subtitleSettingForegroundColor,
    required this.subtitleSettingBackgroundColor,
    required this.subtitleSettingEdgeColor,
    required this.subtitleSettingWindowColor,
    required this.buttonReset,
    required super.child,
  });

  final String settingsTitle;
  final String videoSettingsVideo;
  final String videoSettingsAudio;
  final String videoSettingsSubtitle;
  final String videoSettingsSpeeding;
  final String videoSettingsNone;
  final String videoSize;
  final String playerEnableDecoderFallback;
  final String playerShowLiteProgressbar;
  final String tagUnknown;
  final String willSkipEnding;
  final String Function(String) extensionRendererMode;
  final String extensionRendererModeLabel;
  final String playerShowThumbnails;
  final String subtitleSetting;
  final String subtitleSettingExample;
  final String subtitleSettingForegroundColor;
  final String subtitleSettingBackgroundColor;
  final String subtitleSettingEdgeColor;
  final String subtitleSettingWindowColor;
  final String buttonReset;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static PlayerLocalizations of(BuildContext context) {
    return context.getInheritedWidgetOfExactType()!;
  }
}

class PlayerSettings extends StatelessWidget {
  const PlayerSettings({super.key, required this.controller, this.actions, required this.prefs});

  final PlayerController<dynamic> controller;
  final SharedPreferences prefs;
  final List<Widget> Function(BuildContext)? actions;

  @override
  Widget build(BuildContext context) {
    final localizations = PlayerLocalizations.of(context);
    return ListTileTheme(
      dense: true,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16).copyWith(top: 32),
              child: Text(localizations.settingsTitle, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          ListenableBuilder(
            listenable: controller.trackGroup,
            builder: (context, _) => SliverList.list(
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
              ],
            ),
          ),
          ListenableBuilder(
            listenable: controller.playbackSpeed,
            builder: (context, _) => SliverToBoxAdapter(
              child: PopupMenuButton(
                onSelected: (speed) => controller.setPlaybackSpeed(speed),
                child: ListTile(
                  leading: const Icon(Icons.slow_motion_video_rounded),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(localizations.videoSettingsSpeeding), Text(' ${controller.playbackSpeed.value}x')],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
                itemBuilder: (context) => playerSpeedList
                    .map(
                      (playerSpeed) => CheckedPopupMenuItem(
                        checked: controller.playbackSpeed.value == playerSpeed.value,
                        value: playerSpeed.value,
                        child: Text(playerSpeed.text),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          ListenableBuilder(
            listenable: controller.aspectRatio,
            builder: (context, _) {
              return SliverToBoxAdapter(
                child: PopupMenuButton(
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
                      .map(
                        (aspectRatio) => CheckedPopupMenuItem(
                          checked: controller.aspectRatio.value == aspectRatio,
                          value: aspectRatio,
                          child: Text(aspectRatio.label(context)),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(localizations.subtitleSetting),
              leading: const Icon(Icons.subtitles_outlined),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final initialStyle = SubtitleSettings.fromJson(PlayerConfig.getSubtitleSettings(prefs));
                if (!context.mounted) return;

                final style = await Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => PlayerSubtitleSettings(subtitleSettings: initialStyle)));
                if (style != null) {
                  PlayerConfig.setSubtitleSettings(prefs, style);
                  controller.setSubtitleStyle(style);
                }
              },
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          StatefulBuilder(
            builder: (context, setState) {
              final data = PlayerConfig.getExtensionRendererMode(prefs);
              return SliverToBoxAdapter(
                child: PopupMenuButton(
                  offset: const Offset(1, 0),
                  onSelected: (value) async {
                    PlayerConfig.setExtensionRendererMode(prefs, value);
                    await PlayerController.setPlayerOption('extensionRendererMode', value);
                    setState(() {});
                  },
                  itemBuilder: (context) => [0, 1, 2]
                      .map(
                        (i) => CheckedPopupMenuItem(
                          value: i,
                          checked: i == data,
                          child: Text(localizations.extensionRendererMode(i.toString())),
                        ),
                      )
                      .toList(),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(localizations.extensionRendererModeLabel),
                        Expanded(
                          child: Text(
                            localizations.extensionRendererMode(data.toString()),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return SliverToBoxAdapter(
                child: ListTile(
                  title: Text(localizations.playerEnableDecoderFallback),
                  trailing: Switch(
                    value: PlayerConfig.getEnableDecoderFallback(prefs),
                    onChanged: (value) async {
                      PlayerConfig.setEnableDecoderFallback(prefs, value);
                      await PlayerController.setPlayerOption('enableDecoderFallback', value);
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SwitchListTile(
              value: false,
              title: Badge(label: const Text('Beta'), child: Text(localizations.playerShowThumbnails)),
              onChanged: (_) {},
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          if (actions != null) SliverList.list(children: actions!(context)),
          if (actions != null) const SliverToBoxAdapter(child: Divider()),
          ListenableBuilder(
            listenable: controller.mediaInfo,
            builder: (context, _) => SliverToBoxAdapter(
              child: controller.mediaInfo.value == null
                  ? Container()
                  : DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodySmall!,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Table(
                          columnWidths: const <int, TableColumnWidth>{0: FixedColumnWidth(60), 1: FlexColumnWidth()},
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
                                Text(controller.mediaInfo.value!.videoFPS?.toString() ?? localizations.tagUnknown),
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
                                Text(controller.mediaInfo.value!.audioBitrate?.toString() ?? localizations.tagUnknown),
                              ],
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

  Widget _buildTrackSelector(
    BuildContext context, {
    required Widget icon,
    required String label,
    required List<MediaTrack> tracks,
    dynamic selected,
    required Function(String?) onSelected,
  }) {
    final selectedTrack = tracks.firstWhereOrNull((v) => v.id == selected);
    final localizations = PlayerLocalizations.of(context);
    return PopupMenuButton(
      onSelected: onSelected,
      itemBuilder: (context) => [
        CheckedPopupMenuItem(checked: selected == null, value: 'null', child: Text(localizations.videoSettingsNone)),
        ...tracks.map(
          (e) => CheckedPopupMenuItem(
            checked: selected == e.id,
            value: e.id,
            child: Text(e.label ?? localizations.tagUnknown),
          ),
        ),
      ],
      child: ListTile(
        leading: icon,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedTrack?.label ?? localizations.videoSettingsNone,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class PlayerPlatformView extends StatefulWidget {
  const PlayerPlatformView({
    super.key,
    this.initialized,
    this.autoPip = false,
    required this.playerType,
    this.initializeFailed,
    this.mpvVersion,
  });

  final VoidCallback? initialized;
  final Function(PlatformException)? initializeFailed;
  final bool autoPip;
  final PlayerType playerType;
  final String? mpvVersion;

  @override
  State<PlayerPlatformView> createState() => _PlayerPlatformViewState();
}

class _PlayerPlatformViewState extends State<PlayerPlatformView> {
  @override
  void initState() {
    WidgetsBinding.instance.endOfFrame.then((_) async {
      if (!mounted) return;
      final box = context.findRenderObject()! as RenderBox;
      final offset = box.globalToLocal(Offset.zero);
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final language = Localizations.localeOf(context).languageCode;
      final prefs = await SharedPreferences.getInstance();
      if (!context.mounted) return;
      try {
        await PlayerPlatform.instance.init({
          'type': widget.playerType.name,
          'mpvVersion': widget.mpvVersion,
          'language': language,
          'width': (box.size.width * devicePixelRatio).round(),
          'height': (box.size.height * devicePixelRatio).round(),
          'top': (offset.dy * -1 * devicePixelRatio).round(),
          'left': (offset.dx * -1 * devicePixelRatio).round(),
          'autoPip': widget.autoPip,
          'extensionRendererMode': PlayerConfig.getExtensionRendererMode(prefs),
          'enableDecoderFallback': PlayerConfig.getEnableDecoderFallback(prefs),
          'subtitleStyle': PlayerConfig.getSubtitleSettings(prefs),
        });
        widget.initialized?.call();
      } on PlatformException catch (e) {
        widget.initializeFailed?.call(e);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    PlayerPlatform.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}

class _ThumbnailsList extends StatefulWidget {
  const _ThumbnailsList({
    required this.scrollController,
    required this.itemCount,
    required this.getVideoThumbnail,
    this.theme,
  });

  final ScrollController scrollController;
  final int itemCount;
  final Future<String?> Function(int) getVideoThumbnail;
  final int? theme;

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: widget.theme != null ? Color(widget.theme!) : Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      child: Builder(
        builder: (context) {
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
                                errorBuilder: (context, error, _) => ColoredBox(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 40,
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                  ),
                                ),
                              );
                            } else {
                              return Image.file(
                                File(snapshot.data!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, _) => ColoredBox(
                                  color: Theme.of(context).colorScheme.surface,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 40,
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                  ),
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
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 40,
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                  ),
                                ),
                              );
                            } else {
                              return ColoredBox(
                                color: Theme.of(context).colorScheme.surface,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                ),
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PlayerProgressController extends ChangeNotifier {
  PlayerProgressController(this.controller, {this.showThumbnails = false, this.theme}) {
    controller.status.addListener(setStatus);
    controller.position.addListener(setPosition);
    controller.duration.addListener(setDuration);
    controller.bufferedPosition.addListener(setBuffered);
  }

  Duration duration = Duration.zero;
  Duration buffered = Duration.zero;
  Duration position = Duration.zero;
  Duration cachedPosition = Duration.zero;
  PlayerStatus status = PlayerStatus.buffering;
  bool seeking = false;
  final int? theme;
  final bool showThumbnails;
  final PlayerBaseController controller;
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    if (entry.mounted) entry.dispose();
    scrollController.dispose();
    controller.status.removeListener(setStatus);
    controller.position.removeListener(setPosition);
    controller.duration.removeListener(setDuration);
    controller.bufferedPosition.removeListener(setBuffered);
    super.dispose();
  }

  late final entry = OverlayEntry(
    builder: (context) => Theme(
      data: Theme.of(context),
      child: _ThumbnailsList(
        scrollController: scrollController,
        getVideoThumbnail: controller.getVideoThumbnail,
        itemCount: (duration.inMilliseconds / 30000).ceil(),
        theme: theme,
      ),
    ),
  );

  void setStatus() {
    if (status != controller.status.value) {
      status = controller.status.value;
      notifyListeners();
    }
  }

  void setPosition() {
    if (position != controller.position.value) {
      position = controller.position.value;
      notifyListeners();
    }
  }

  void setDuration() {
    if (duration != controller.duration.value) {
      duration = controller.duration.value;
      notifyListeners();
    }
  }

  void setBuffered() {
    if (buffered != controller.bufferedPosition.value) {
      buffered = controller.bufferedPosition.value;
      notifyListeners();
    }
  }

  void startSeek(BuildContext context) {
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

  void updateSeek(BuildContext context, Duration position) {
    cachedPosition = position.clamp(Duration.zero, duration);
    notifyListeners();
    if (showThumbnails && scrollController.hasClients) {
      final offset = calcOffset();
      if (offset != scrollController.offset) {
        scrollController.animateTo(offset, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    }
  }

  void endSeek(BuildContext context) {
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
  const PlayerProgressView(
    this.controller, {
    super.key,
    this.seekStart,
    this.seekEnd,
    this.thickness = 12,
    this.showLabel = true,
    this.scalable = true,
  });

  final double thickness;
  final bool showLabel;
  final bool scalable;
  final VoidCallback? seekStart;
  final Function(Duration)? seekEnd;
  final PlayerProgressController controller;

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
    final child = Padding(
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
              padding: EdgeInsets.symmetric(vertical: widget.showLabel ? 6 : 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _controller.seeking ? widget.thickness / 3 * 4 : widget.thickness,
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(1000)),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Container(color: Theme.of(context).colorScheme.surface),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 200),
                      widthFactor: max(_controller.buffered / _controller.duration ?? 0, 0),
                      child: Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                    ),
                    if (_controller.status == PlayerStatus.error)
                      Container(color: Theme.of(context).colorScheme.errorContainer)
                    else if (_controller.seeking)
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 100),
                        widthFactor: max(_controller.cachedPosition / _controller.duration ?? 0, 0),
                        child: Container(color: Theme.of(context).colorScheme.primary),
                      )
                    else
                      FractionallySizedBox(
                        widthFactor: max(_controller.position / _controller.duration ?? 0, 0),
                        child: Container(color: Theme.of(context).colorScheme.primary),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.showLabel)
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
    );
    return SizedBox(
      height: widget.showLabel ? 52 : 42,
      child: Center(
        child: widget.scalable
            ? AnimatedScale(
                scale: _controller.seeking ? 1.05 : 1,
                duration: const Duration(milliseconds: 200),
                child: child,
              )
            : child,
      ),
    );
  }

  void update() {
    setState(() {});
  }
}

class PlayerProgressLabel extends StatefulWidget {
  const PlayerProgressLabel({super.key, required this.controller});

  final PlayerProgressController controller;

  @override
  State<PlayerProgressLabel> createState() => _PlayerProgressLabelState();
}

class _PlayerProgressLabelState extends State<PlayerProgressLabel> {
  @override
  void initState() {
    widget.controller.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.labelMedium!,
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 36),
            child: Text(
              widget.controller.seeking
                  ? widget.controller.cachedPosition.toDisplay()
                  : widget.controller.position.toDisplay(),
            ),
          ),
          const Text('-', style: TextStyle(color: Colors.transparent)),
          const Text('/'),
          Text('-', style: widget.controller.seeking ? null : const TextStyle(color: Colors.transparent)),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 36),
            child: Text(
              (widget.controller.seeking
                      ? widget.controller.duration - widget.controller.cachedPosition
                      : widget.controller.duration)
                  .toDisplay(),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void update() {
    setState(() {});
  }
}

class PlayerSubtitleSettings extends StatefulWidget {
  const PlayerSubtitleSettings({super.key, required this.subtitleSettings});

  final SubtitleSettings subtitleSettings;

  @override
  State<PlayerSubtitleSettings> createState() => _PlayerSubtitleSettingsState();
}

class _PlayerSubtitleSettingsState extends State<PlayerSubtitleSettings> {
  late Color _foregroundColor = widget.subtitleSettings.foregroundColor;
  late Color _backgroundColor = widget.subtitleSettings.backgroundColor;
  late Color _windowColor = widget.subtitleSettings.windowColor;
  late Color _edgeColor = widget.subtitleSettings.edgeColor;

  @override
  Widget build(BuildContext context) {
    final localizations = PlayerLocalizations.of(context);

    return ListTileTheme(
      dense: true,
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(localizations.settingsTitle, style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/common/images/subtitle_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              margin: const EdgeInsets.all(16),
              child: Align(
                alignment: const Alignment(0, 0.9),
                child: Stack(
                  children: [
                    Text(
                      localizations.subtitleSettingExample,
                      style: TextStyle(
                        fontSize: 24,
                        backgroundColor: _backgroundColor,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = _edgeColor,
                      ),
                    ),
                    Text(localizations.subtitleSettingExample, style: TextStyle(fontSize: 24, color: _foregroundColor)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(localizations.subtitleSettingForegroundColor),
              trailing: _buildTrailing(_foregroundColor),
              onTap: () async {
                final color = await _showColorPicker(context, _foregroundColor);
                if (color != null && context.mounted) setState(() => _foregroundColor = color);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(localizations.subtitleSettingBackgroundColor),
              trailing: _buildTrailing(_backgroundColor),
              onTap: () async {
                final color = await _showColorPicker(context, _backgroundColor);
                if (color != null && context.mounted) setState(() => _backgroundColor = color);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(localizations.subtitleSettingEdgeColor),
              trailing: _buildTrailing(_edgeColor),
              onTap: () async {
                final color = await _showColorPicker(context, _edgeColor);
                if (color != null && context.mounted) setState(() => _edgeColor = color);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(localizations.subtitleSettingWindowColor),
              trailing: _buildTrailing(_windowColor),
              onTap: () async {
                final color = await _showColorPicker(context, _windowColor);
                if (color != null && context.mounted) setState(() => _windowColor = color);
              },
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.check_rounded),
                  onPressed: () {
                    final style = SubtitleSettings(
                      foregroundColor: _foregroundColor,
                      backgroundColor: _backgroundColor,
                      windowColor: _windowColor,
                      edgeColor: _edgeColor,
                    );
                    Navigator.of(context).pop(style.toJson());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(Color color) {
    return ColorIndicator(HSVColor.fromColor(color), width: 16, height: 16);
  }

  Future<Color?> _showColorPicker(BuildContext context, Color color) async {
    return showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          titlePadding: const EdgeInsets.all(16),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: color,
              paletteType: PaletteType.hsl,
              onColorChanged: (c) => color = c,
              // ignore: deprecated_member_use
              labelTextStyle: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          contentPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
          actions: <Widget>[
            IconButton.filledTonal(
              icon: const Icon(Icons.check_rounded),
              onPressed: () {
                Navigator.of(context).pop(color);
              },
            ),
          ],
        );
      },
    );
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
