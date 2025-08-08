import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../player.dart';
import 'player_platform_interface.dart';

class PlayerCast<T> extends StatefulWidget {
  const PlayerCast({
    super.key,
    required this.device,
    required this.playlist,
    this.theme,
    this.isTV = false,
    this.index = 0,
    this.onGetPlayBackInfo,
  });

  final bool isTV;
  final CastDevice device;
  final int index;
  final int? theme;
  final List<PlaylistItemDisplay<T>> playlist;
  final Future<PlaylistItem> Function(PlaylistItemDisplay<T>)? onGetPlayBackInfo;

  @override
  State<PlayerCast<T>> createState() => _PlayerCastState<T>();
}

class _PlayerCastState<T> extends State<PlayerCast<T>> {
  final isPlaying = ValueNotifier(true);
  final showPlaylist = ValueNotifier(false);
  late final device = widget.device;
  late final index = ValueNotifier<int>(widget.index);
  late final _controller = PlayerProgressController(device);
  final _scrollController = ScrollController();

  bool get isFirst => index.value == 0;

  bool get isLast => index.value == widget.playlist.length - 1;

  PlaylistItemDisplay<T> get currentItem => widget.playlist.elementAt(index.value);

  @override
  void initState() {
    // TODO(bug): when SDK < 29
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);
    device.start();
    next(index.value, true);
    super.initState();
  }

  @override
  void dispose() {
    isPlaying.dispose();
    showPlaylist.dispose();
    device.stop();
    _controller.dispose();
    _scrollController.dispose();
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
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
                colors: [Theme.of(context).colorScheme.surfaceContainerHighest, Theme.of(context).colorScheme.surface],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (currentItem.poster != null) BlurredBackground(background: currentItem.poster!),
                if (currentItem.poster != null) Container(color: Theme.of(context).colorScheme.surface.withAlpha(0x33)),
                Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: const BackButtonIcon(),
                      onPressed: () {
                        Navigator.of(context).pop((index.value, _controller.position));
                      },
                    ),
                    scrolledUnderElevation: 0,
                    systemOverlayStyle: const SystemUiOverlayStyle(
                      systemNavigationBarIconBrightness: Brightness.light,
                      statusBarIconBrightness: Brightness.light,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
                  body: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ListenableBuilder(
                                  listenable: showPlaylist,
                                  builder: (context, child) {
                                    return PageTransitionSwitcher(
                                      transitionBuilder: (child, animation, secondaryAnimation) =>
                                          FadeThroughTransition(
                                            animation: animation,
                                            secondaryAnimation: secondaryAnimation,
                                            fillColor: Colors.transparent,
                                            child: child,
                                          ),
                                      child: !showPlaylist.value
                                          ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  child: ListenableBuilder(
                                                    listenable: index,
                                                    builder: (context, child) => Center(
                                                      child: _PlayerArtwork(
                                                        key: ValueKey(currentItem),
                                                        item: currentItem,
                                                        isPlaying: isPlaying,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(12),
                                                  child: ListenableBuilder(
                                                    listenable: index,
                                                    builder: (context, _) => Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        if (currentItem.title != null)
                                                          Text(
                                                            currentItem.title!,
                                                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        if (currentItem.description != null)
                                                          Text(
                                                            currentItem.description!,
                                                            style: Theme.of(context).textTheme.bodyLarge,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Scrollbar(
                                                controller: _scrollController,
                                                child: ListView.builder(
                                                  controller: _scrollController,
                                                  itemBuilder: (context, index) {
                                                    if (index == 0) {
                                                      return ListenableBuilder(
                                                        listenable: this.index,
                                                        builder: (context, _) {
                                                          return Padding(
                                                            padding: const EdgeInsets.all(16),
                                                            child: Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 80,
                                                                  height: 80,
                                                                  child: Center(
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: const BorderRadius.all(
                                                                          Radius.circular(6),
                                                                        ),
                                                                        color: Theme.of(context).colorScheme.surface,
                                                                      ),
                                                                      clipBehavior: Clip.antiAlias,
                                                                      child: currentItem.poster != null
                                                                          ? CachedNetworkImage(
                                                                              imageUrl: currentItem.poster!,
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : const SizedBox.expand(
                                                                              child: Icon(
                                                                                Icons.movie_creation_outlined,
                                                                              ),
                                                                            ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 24),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      if (currentItem.title != null)
                                                                        Text(
                                                                          currentItem.title!,
                                                                          style: Theme.of(context).textTheme.titleLarge!
                                                                              .copyWith(fontWeight: FontWeight.bold),
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      if (currentItem.description != null)
                                                                        Text(
                                                                          currentItem.description!,
                                                                          style: Theme.of(context).textTheme.bodyLarge,
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      final item = widget.playlist[index - 1];
                                                      return ListenableBuilder(
                                                        listenable: this.index,
                                                        builder: (context, _) {
                                                          return ListTile(
                                                            dense: true,
                                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                                            leading: AspectRatio(
                                                              aspectRatio: 1,
                                                              child: Center(
                                                                child: Container(
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: const BorderRadius.all(
                                                                      Radius.circular(2),
                                                                    ),
                                                                    color: Theme.of(context).colorScheme.surface,
                                                                  ),
                                                                  child: item.poster != null
                                                                      ? CachedNetworkImage(imageUrl: item.poster!)
                                                                      : const SizedBox.expand(
                                                                          child: Icon(Icons.movie_creation_outlined),
                                                                        ),
                                                                ),
                                                              ),
                                                            ),
                                                            title: Text(item.title ?? ''),
                                                            subtitle: Text(item.description ?? ''),
                                                            trailing: index - 1 == this.index.value
                                                                ? const Icon(Icons.play_circle_rounded)
                                                                : null,
                                                            onTap: () => next(index - 1),
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                  itemCount: widget.playlist.length + 1,
                                                ),
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ),
                              PlayerProgressView(_controller, key: ValueKey(device), seekEnd: device.seek),
                              Padding(
                                padding: const EdgeInsets.only(top: 18, bottom: 36),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ListenableBuilder(
                                      listenable: index,
                                      builder: (context, child) => isFirst
                                          ? const IconButton(onPressed: null, icon: Icon(null, size: 32))
                                          : child!,
                                      child: IconButton(
                                        onPressed: () => next(index.value - 1),
                                        icon: const Icon(Icons.skip_previous_rounded, size: 32),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async =>
                                          device.seek(_controller.position - const Duration(seconds: 30)),
                                      icon: const Icon(Icons.fast_rewind_rounded, size: 32),
                                    ),
                                    const SizedBox(width: 12),
                                    ListenableBuilder(
                                      listenable: isPlaying,
                                      builder: (context, _) => IconButton(
                                        onPressed: () {
                                          if (isPlaying.value) {
                                            device.pause();
                                          } else {
                                            device.play();
                                          }
                                          isPlaying.value = !isPlaying.value;
                                        },
                                        icon: Icon(isPlaying.value ? Icons.pause : Icons.play_arrow_rounded, size: 36),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      onPressed: () async =>
                                          device.seek(_controller.position + const Duration(seconds: 30)),
                                      icon: const Icon(Icons.fast_forward_rounded, size: 32),
                                    ),
                                    ListenableBuilder(
                                      listenable: index,
                                      builder: (context, child) => isLast
                                          ? const IconButton(onPressed: null, icon: Icon(null, size: 32))
                                          : child!,
                                      child: IconButton(
                                        onPressed: () => next(index.value + 1),
                                        icon: const Icon(Icons.skip_next_rounded, size: 32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              FutureBuilder(
                                future: device.getVolume(),
                                builder: (context, snapshot) => PlayerVolume(
                                  key: ValueKey(snapshot.data),
                                  initialVolume: snapshot.data ?? 0,
                                  onUpdate: (volume) => device.setVolume(volume),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const IconButton(onPressed: null, icon: Icon(null)),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            style: Theme.of(context).textTheme.bodyMedium,
                                            children: [
                                              const WidgetSpan(
                                                child: Icon(Icons.cast),
                                                alignment: PlaceholderAlignment.middle,
                                              ),
                                              const WidgetSpan(child: SizedBox(width: 12)),
                                              TextSpan(text: device.friendlyName),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    ListenableBuilder(
                                      listenable: showPlaylist,
                                      builder: (context, _) {
                                        return IconButton(
                                          onPressed: () => showPlaylist.value = !showPlaylist.value,
                                          icon: const Icon(Icons.menu_rounded),
                                          isSelected: showPlaylist.value,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> next(int index, [bool initial = false]) async {
    final fixedIndex = index.clamp(0, widget.playlist.length);
    if (!initial && fixedIndex == this.index.value) {
      return;
    }
    late PlaylistItem playlistItem;

    if (widget.onGetPlayBackInfo != null) {
      playlistItem = await widget.onGetPlayBackInfo!(widget.playlist[fixedIndex]);
    } else {
      playlistItem = widget.playlist[fixedIndex].toItem();
    }
    if (playlistItem.url.host == '127.0.0.1') {
      await device.setUrl(
        playlistItem.url.replace(host: await PlayerPlatform.instance.getLocalIpAddress()),
        title: playlistItem.title ?? '',
      );
    } else {
      await device.setUrl(playlistItem.url);
    }
    this.index.value = fixedIndex;
    if (playlistItem.start != Duration.zero) {
      await device.seek(playlistItem.start);
    }
  }
}

class _PlayerArtwork<T extends PlaylistItemDisplay<dynamic>> extends StatelessWidget {
  const _PlayerArtwork({super.key, required this.item, required this.isPlaying});

  final T item;
  final ValueNotifier<bool> isPlaying;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Center(
        child: ListenableBuilder(
          listenable: isPlaying,
          builder: (context, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: isPlaying.value ? Curves.easeOutBack : Curves.easeOutCubic,
              transformAlignment: Alignment.center,
              transform: isPlaying.value ? Matrix4.diagonal3Values(1, 1, 1) : Matrix4.diagonal3Values(0.75, 0.75, 1.0),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  if (isPlaying.value)
                    const BoxShadow(color: Color(0x66000000), offset: Offset(0, 10), blurRadius: 36)
                  else
                    const BoxShadow(color: Color(0x11000000), offset: Offset(0, 2), blurRadius: 18),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: item.poster != null
                  ? CachedNetworkImage(imageUrl: item.poster!, fit: BoxFit.cover)
                  : const SizedBox.expand(child: Icon(Icons.movie_creation_outlined, size: 96)),
            );
          },
        ),
      ),
    );
  }
}

class PlayerVolume extends StatefulWidget {
  const PlayerVolume({super.key, required this.onUpdate, this.initialVolume = 0});

  final Function(double) onUpdate;
  final double initialVolume;

  @override
  State<PlayerVolume> createState() => _PlayerVolumeState();
}

class _PlayerVolumeState extends State<PlayerVolume> {
  bool updating = false;
  late double volume = widget.initialVolume;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: AnimatedScale(
        scale: updating ? 1.05 : 1,
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.volume_mute_rounded),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  onTapDown: (_) {
                    if (!updating) setState(() => updating = true);
                  },
                  onHorizontalDragStart: (_) {
                    if (!updating) setState(() => updating = true);
                  },
                  onHorizontalDragUpdate: (details) {
                    if (updating) {
                      final RenderBox box = context.findRenderObject()! as RenderBox;
                      final frac = details.delta.dx / box.size.width;
                      volume = (volume + frac).clamp(0, 1);
                      widget.onUpdate(volume);
                      setState(() {});
                    }
                  },
                  onHorizontalDragEnd: (_) {
                    if (updating) setState(() => updating = false);
                  },
                  onTapUp: (_) {
                    if (updating) setState(() => updating = false);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: updating ? 16 : 12,
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(1000)),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Container(color: Theme.of(context).colorScheme.surface),
                        if (updating)
                          AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 100),
                            widthFactor: volume,
                            child: Container(color: Theme.of(context).colorScheme.primary),
                          )
                        else
                          FractionallySizedBox(
                            widthFactor: volume,
                            child: Container(color: Theme.of(context).colorScheme.primary),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.volume_up_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerCastSearcher extends StatelessWidget {
  const PlayerCastSearcher(this.cast, {super.key, this.noResultText, required this.errorWidget});

  final Cast cast;
  final String? noResultText;
  final Widget Function(BuildContext, Object?) errorWidget;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
        stream: cast.discover(),
        builder: (context, snapshot) {
          if (snapshot.data?.isNotEmpty ?? false) {
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemBuilder: (context, index) {
                  final device = snapshot.requireData[index];
                  return RadioListTile(
                    title: Text(device.friendlyName),
                    value: device,
                    groupValue: null,
                    onChanged: (value) => Navigator.of(context).pop(device),
                  );
                },
                itemCount: snapshot.requireData.length,
              ),
            );
          } else if (snapshot.hasError) {
            return errorWidget(context, snapshot.error);
          } else if (snapshot.connectionState != ConnectionState.done) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
                ),
              ],
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: ListTile(title: Text(noResultText ?? '未搜索到投屏设备', textAlign: TextAlign.center)),
            );
          }
        },
      ),
    );
  }
}

class BlurredBackground extends StatefulWidget {
  const BlurredBackground({super.key, required this.background, this.defaultColor});

  final String background;
  final Color? defaultColor;

  @override
  State<BlurredBackground> createState() => _BlurredBackgroundState();
}

class _BlurredBackgroundState extends State<BlurredBackground> with SingleTickerProviderStateMixin {
  late final size = MediaQuery.of(context).size;
  final blurSize = 50.0;
  final scaleSize = 4;
  Offset offset = Offset.zero;
  Offset vector = const Offset(1, 1);
  Size imageSize = Size.zero;
  Size imageSizeFixed = Size.zero;

  late final AnimationController _controller = AnimationController(duration: const Duration(seconds: 10), vsync: this)
    ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: FutureBuilder(
        future: background(),
        builder: (context, snapshot) {
          return AnimatedOpacity(
            opacity: snapshot.hasData ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform(
                transform: transform(),
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                child: child,
              ),
              child: snapshot.hasData
                  ? snapshot.requireData
                  : Container(color: widget.defaultColor ?? Theme.of(context).colorScheme.surface),
            ),
          );
        },
      ),
    );
  }

  Future<Widget> background() async {
    final data = await widgetToUiImage(
      ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: blurSize, sigmaY: blurSize),
        child: CachedNetworkImage(imageUrl: widget.background),
      ),
    );
    imageSize = Size(data.width.toDouble(), data.height.toDouble());
    imageSizeFixed = Size(
      imageSize.aspectRatio > size.aspectRatio ? size.width : size.height * imageSize.aspectRatio,
      imageSize.aspectRatio < size.aspectRatio ? size.height : size.width / imageSize.aspectRatio,
    );
    return Image.memory(
      (await data.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List(),
      fit: BoxFit.contain,
    );
  }

  Matrix4 transform() {
    final offsetLimitation =
        Size(
          max(imageSizeFixed.width * scaleSize - size.width, 0),
          max(imageSizeFixed.height * scaleSize - size.height, 0),
        ) /
        2;
    offset += vector;
    if (offset.dx < -offsetLimitation.width || offset.dx > offsetLimitation.width) {
      vector = Offset(-vector.dx, vector.dy);
    }
    if (offset.dy < -offsetLimitation.height || offset.dy > offsetLimitation.height) {
      vector = Offset(vector.dx, -vector.dy);
    }
    offset = Offset(
      offset.dx.clamp(-offsetLimitation.width, offsetLimitation.width),
      offset.dy.clamp(-offsetLimitation.height, offsetLimitation.height),
    );
    final matrix = Matrix4.translationValues(
      -size.width / 2,
      -size.height / 2,
      0,
    ).scaled(scaleSize.toDouble(), scaleSize.toDouble(), 1.0);
    matrix.translate((offset.dx + size.width / 2) / scaleSize, (offset.dy + size.height / 2) / scaleSize);
    return matrix;
  }

  static Future<ui.Image> widgetToUiImage(
    Widget widget, {
    Duration delay = Duration.zero,
    double? pixelRatio,
    BuildContext? context,
    Size? targetSize,
  }) async {
    int retryCounter = 3;
    bool isDirty = false;

    Widget child = widget;

    if (context != null) {
      child = InheritedTheme.captureAll(
        context,
        MediaQuery(
          data: MediaQuery.of(context),
          child: Material(color: Colors.transparent, child: child),
        ),
      );
    }

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final fallBackView = platformDispatcher.views.first;
    final view = context == null ? fallBackView : View.maybeOf(context) ?? fallBackView;
    final logicalSize = targetSize ?? view.physicalSize / view.devicePixelRatio;
    final imageSize = targetSize ?? view.physicalSize;

    assert(logicalSize.aspectRatio.toStringAsPrecision(5) == imageSize.aspectRatio.toStringAsPrecision(5));

    final RenderView renderView = RenderView(
      view: view,
      child: RenderPositionedBox(child: repaintBoundary),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints(maxWidth: logicalSize.width, maxHeight: logicalSize.height),
        devicePixelRatio: pixelRatio ?? 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager(), onBuildScheduled: () => isDirty = true);

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    ui.Image? image;

    do {
      isDirty = false;
      image = await repaintBoundary.toImage(pixelRatio: pixelRatio ?? (imageSize.width / logicalSize.width));

      await Future.delayed(delay);

      if (isDirty) {
        buildOwner.buildScope(rootElement);
        buildOwner.finalizeTree();
        pipelineOwner.flushLayout();
        pipelineOwner.flushCompositingBits();
        pipelineOwner.flushPaint();
      }
      retryCounter--;
    } while (isDirty && retryCounter >= 0);
    try {
      buildOwner.finalizeTree();
    } catch (_) {}

    return image;
  }
}
