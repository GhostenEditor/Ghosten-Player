import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:animations/animations.dart';
import 'package:api/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:video_player/player.dart';

import '../components/components.dart ';
import '../models/models.dart';
import '../utils/uri.dart';
import 'cast_adaptor.dart';

class PlayerCast extends StatefulWidget {
  const PlayerCast({super.key, required this.device, required this.data});

  final CastDevice device;
  final PlaylistData data;

  @override
  State<PlayerCast> createState() => _PlayerCastState();
}

class _PlayerCastState extends State<PlayerCast> {
  final ValueNotifier<bool> isPlaying = ValueNotifier(true);
  final ValueNotifier<bool> showPlaylist = ValueNotifier(false);
  late final CastDevice device = widget.device;
  late final index = ValueNotifier<int>(widget.data.activeIndex);
  late final _controller = PlayerProgressController(device);
  final _scrollController = ScrollController();

  bool get isFirst => index.value == 0;

  bool get isLast => index.value == widget.data.playlist.length - 1;

  PlaylistItem get currentItem => widget.data.playlist.elementAt(index.value);

  Future<PlayerFileInfo> _onGetPlayBackInfo(PlaylistItem item) async {
    final dynamic source = currentItem.source;
    if (source is TVEpisode) {
      final PlaybackInfo data = await Api.playbackInfo(source.fileId);
      return PlayerFileInfo(
        url: Uri.parse(data.url).normalize(),
        subtitles: data.subtitles.map((d) => d.toSubtitle()).nonNulls.toList(),
        others: data.others,
      );
    } else if (source is Movie) {
      final PlaybackInfo data = await Api.playbackInfo(source.fileId);
      return PlayerFileInfo(
        url: Uri.parse(data.url).normalize(),
        subtitles: data.subtitles.map((d) => d.toSubtitle()).nonNulls.toList(),
        others: data.others,
      );
    } else if (source is DriverFile) {
      final PlaybackInfo data = await Api.playbackInfo(source.fileId);
      return PlayerFileInfo(
        url: Uri.parse(data.url).normalize(),
        subtitles: data.subtitles.map((d) => d.toSubtitle()).nonNulls.toList(),
        others: data.others,
      );
    }
    if (item.url != null) {
      return PlayerFileInfo(url: item.url!);
    }
    throw Exception();
  }

  @override
  void initState() {
    super.initState();
    device.start();
    next(index.value, true);
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
        colorSchemeSeed: widget.data.themeColor != null ? Color(widget.data.themeColor!) : null,
        brightness: .dark,
      ),
      child: Builder(
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: [
            ValueListenableBuilder(
              valueListenable: index,
              builder: (context, value, _) => _BlurredBackground(background: currentItem.poster),
            ),
            Scaffold(
              appBar: AppBar(
                forceMaterialTransparency: true,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  systemNavigationBarIconBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.light,
                ),
              ),
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ValueListenableBuilder(
                            valueListenable: showPlaylist,
                            builder: (context, value, child) {
                              return PageTransitionSwitcher(
                                transitionBuilder: (child, animation, secondaryAnimation) => FadeThroughTransition(
                                  animation: animation,
                                  secondaryAnimation: secondaryAnimation,
                                  fillColor: Colors.transparent,
                                  child: child,
                                ),
                                child: !value
                                    ? Padding(
                                        key: ValueKey(index.value),
                                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                                        child: ValueListenableBuilder(
                                          valueListenable: index,
                                          builder: (context, value, _) {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              spacing: 12,
                                              children: [
                                                Expanded(
                                                  child: _PlayerArtwork(item: currentItem, isPlaying: isPlaying),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if (currentItem.title != null)
                                                      Text(
                                                        currentItem.title!,
                                                        style: Theme.of(context).textTheme.titleLarge!
                                                            .copyWith(fontWeight: FontWeight.w500),
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
                                              ],
                                            );
                                          },
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Scrollbar(
                                          controller: _scrollController,
                                          child: CustomScrollView(
                                            controller: _scrollController,
                                            slivers: [
                                              SliverToBoxAdapter(
                                                child: ValueListenableBuilder(
                                                  valueListenable: index,
                                                  builder: (context, value, _) {
                                                    return ListTile(
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 40),
                                                      leading: SizedBox.square(
                                                        dimension: 80,
                                                        child: Center(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: const BorderRadius.all(Radius.circular(6)),
                                                              color: Theme.of(context).colorScheme.surface,
                                                            ),
                                                            clipBehavior: Clip.antiAlias,
                                                            child: currentItem.poster != null
                                                                ? AsyncImage(currentItem.poster!)
                                                                : const SizedBox.expand(
                                                                    child: Icon(Icons.movie_creation_outlined),
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                      title: Text(currentItem.title ?? ''),
                                                      subtitle: Text(currentItem.description ?? ''),
                                                    );
                                                  },
                                                ),
                                              ),
                                              ListTileTheme(
                                                data: const ListTileThemeData(
                                                  dense: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 40),
                                                  visualDensity: VisualDensity(vertical: VisualDensity.minimumDensity),
                                                ),
                                                child: ValueListenableBuilder(
                                                  valueListenable: index,
                                                  builder: (context, value, _) {
                                                    return SliverList.builder(
                                                      itemBuilder: (context, index) {
                                                        final PlaylistItem item = widget.data.playlist[index];
                                                        return ListTile(
                                                          selected: index == value,
                                                          leading: SizedBox(
                                                            width: 48,
                                                            child: Center(
                                                              child: Container(
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(
                                                                  borderRadius: const BorderRadius.all(
                                                                    Radius.circular(4),
                                                                  ),
                                                                  color: Theme.of(context).colorScheme.surface,
                                                                ),
                                                                child: item.poster != null
                                                                    ? AsyncImage(item.poster!, errorIconSize: 24)
                                                                    : const SizedBox.expand(
                                                                        child: Icon(Icons.movie_creation_outlined),
                                                                      ),
                                                              ),
                                                            ),
                                                          ),
                                                          title: Text(item.title ?? ''),
                                                          subtitle: Text(item.description ?? ''),
                                                          trailing: index == value
                                                              ? const Icon(Icons.play_arrow_rounded)
                                                              : null,
                                                          onTap: () => next(index),
                                                        );
                                                      },
                                                      itemCount: widget.data.playlist.length,
                                                    );
                                                  },
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: PlayerProgressView(
                            _controller,
                            key: ValueKey(device),
                            seekEnd: device.seek,
                            thickness: 8,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 18, bottom: 36, left: 24, right: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ValueListenableBuilder(
                                valueListenable: index,
                                builder: (context, value, child) =>
                                    isFirst ? const IconButton(onPressed: null, icon: Icon(null, size: 32)) : child!,
                                child: IconButton(
                                  onPressed: () => next(index.value - 1),
                                  icon: const Icon(Icons.skip_previous_rounded, size: 32),
                                ),
                              ),
                              IconButton(
                                onPressed: () async => device.seek(_controller.position - const Duration(seconds: 30)),
                                icon: const Icon(Icons.fast_rewind_rounded, size: 32),
                              ),
                              const SizedBox(width: 12),
                              ValueListenableBuilder(
                                valueListenable: isPlaying,
                                builder: (context, value, _) => IconButton(
                                  onPressed: () {
                                    if (value) {
                                      device.pause();
                                    } else {
                                      device.play();
                                    }
                                    isPlaying.value = !value;
                                  },
                                  icon: Icon(
                                    isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    size: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () async => device.seek(_controller.position + const Duration(seconds: 30)),
                                icon: const Icon(Icons.fast_forward_rounded, size: 32),
                              ),
                              ValueListenableBuilder(
                                valueListenable: index,
                                builder: (context, value, child) =>
                                    isLast ? const IconButton(onPressed: null, icon: Icon(null, size: 32)) : child!,
                                child: IconButton(
                                  onPressed: () => next(index.value + 1),
                                  icon: const Icon(Icons.skip_next_rounded, size: 32),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: FutureBuilder(
                            future: device.getVolume(),
                            builder: (context, snapshot) => PlayerVolume(
                              key: ValueKey(snapshot.data),
                              initialVolume: snapshot.data ?? 0,
                              onUpdate: (volume) => device.setVolume(volume),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
                              ValueListenableBuilder(
                                valueListenable: showPlaylist,
                                builder: (context, value, _) => value
                                    ? IconButton.filled(
                                        onPressed: () => showPlaylist.value = false,
                                        icon: const Icon(Icons.menu_rounded),
                                      )
                                    : IconButton(
                                        onPressed: () => showPlaylist.value = true,
                                        icon: const Icon(Icons.menu_rounded),
                                      ),
                              ),
                            ],
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
    );
  }

  Future<void> next(int index, [bool initial = false]) async {
    final int fixedIndex = index.clamp(0, widget.data.playlist.length);
    if (!initial && fixedIndex == this.index.value) {
      return;
    }
    final PlayerFileInfo playlistItem = await _onGetPlayBackInfo(widget.data.playlist[fixedIndex]);
    if (playlistItem.url.host == '127.0.0.1') {
      await device.setUrl(playlistItem.url.replace(host: await Api.localIpAddress()), title: currentItem.title ?? '');
    } else {
      await device.setUrl(playlistItem.url);
    }
    this.index.value = fixedIndex;
    if (currentItem.start != Duration.zero) {
      await device.seek(currentItem.start);
    }
  }
}

class _PlayerArtwork<T extends PlaylistItem> extends StatelessWidget {
  const _PlayerArtwork({super.key, required this.item, required this.isPlaying});

  final T item;
  final ValueNotifier<bool> isPlaying;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.surfaceBright),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Center(
            child: ValueListenableBuilder(
              valueListenable: isPlaying,
              builder: (context, value, _) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: value ? Curves.easeOutBack : Curves.easeOutCubic,
                  transformAlignment: Alignment.center,
                  transform: value ? Matrix4.diagonal3Values(1, 1, 1) : Matrix4.diagonal3Values(0.75, 0.75, 1.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      if (value)
                        const BoxShadow(color: Color(0x66000000), offset: Offset(0, 10), blurRadius: 36)
                      else
                        const BoxShadow(color: Color(0x11000000), offset: Offset(0, 2), blurRadius: 18),
                    ],
                  ),
                  clipBehavior: .antiAlias,
                  child: item.poster != null
                      ? AsyncImage(
                          item.poster!,
                          errorWidget: (context, url, error) =>
                              const SizedBox.expand(child: Icon(Icons.broken_image_rounded, size: 96)),
                        )
                      : const SizedBox.expand(child: Icon(Icons.movie_creation_outlined, size: 96)),
                );
              },
            ),
          ),
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
  late double cachedVolume = widget.initialVolume;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: AnimatedScale(
        scale: updating ? 1.05 : 1,
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onSurfaceVariant),
            child: Row(
              children: [
                const Icon(Icons.volume_mute_rounded),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    excludeFromSemantics: true,
                    onTapDown: (_) {
                      if (!updating) {
                        updating = true;
                        cachedVolume = volume;
                        setState(() {});
                      }
                    },
                    onHorizontalDragStart: (_) {
                      if (!updating) {
                        updating = true;
                        cachedVolume = volume;
                        setState(() {});
                      }
                    },
                    onHorizontalDragUpdate: (details) {
                      if (updating) {
                        final box = context.findRenderObject()! as RenderBox;
                        final double frac = details.delta.dx / box.size.width;
                        cachedVolume = (cachedVolume + frac).clamp(0, 1);
                        setState(() {});
                      }
                    },
                    onHorizontalDragEnd: (_) {
                      if (updating) {
                        updating = false;
                        volume = cachedVolume;
                        widget.onUpdate(volume);
                        setState(() {});
                      }
                    },
                    onTapUp: (_) {
                      if (updating) {
                        updating = false;
                        volume = cachedVolume;
                        widget.onUpdate(volume);
                        setState(() {});
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: updating ? 12 : 8,
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(1000)),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Container(color: Theme.of(context).colorScheme.surface),
                          AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 100),
                            widthFactor: updating ? cachedVolume : volume,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              color: updating
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
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
      ),
    );
  }
}

class PlayerCastSearcher extends StatelessWidget {
  const PlayerCastSearcher({super.key, this.noResultText});

  final String? noResultText;

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      dense: true,
      child: StreamBuilder(
        stream: Api.dlnaDiscover().map(CastDevice.fromJson).scan<List<CastDevice>>((acc, cur, _) => acc..add(cur), []),
        builder: (context, snapshot) {
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120),
            child: RadioGroup<CastDevice>(
              onChanged: (value) => Navigator.of(context).pop(value),
              child: Scrollbar(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (snapshot.connectionState != ConnectionState.done) const LinearProgressIndicator(),
                    if (snapshot.connectionState == ConnectionState.done && (snapshot.data?.isEmpty ?? true))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(title: Text(noResultText ?? '未搜索到投屏设备', textAlign: TextAlign.center)),
                      ),
                    if (snapshot.hasData)
                      ...snapshot.requireData.map(
                        (device) => RadioListTile(title: Text(device.friendlyName), value: device),
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
}

class _BlurredBackground extends StatefulWidget {
  const _BlurredBackground({required this.background});

  final String? background;

  @override
  State<_BlurredBackground> createState() => _BlurredBackgroundState();
}

class _BlurredBackgroundState extends State<_BlurredBackground> with SingleTickerProviderStateMixin {
  late final ui.Size size = MediaQuery.sizeOf(context);
  final blurSize = 50.0;
  final scaleSize = 4.0;
  Offset offset = Offset.zero;
  Offset vector = const Offset(1, 1);
  Size imageSize = Size.zero;
  Size imageSizeFixed = Size.zero;
  late Future<Widget?> future = background();
  late final _controller = AnimationController(duration: const Duration(seconds: 10), vsync: this)..repeat();

  @override
  void didUpdateWidget(covariant _BlurredBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.background != widget.background) {
      future = background();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomLeft,
          colors: [Theme.of(context).colorScheme.surfaceContainerHighest, Theme.of(context).colorScheme.surface],
        ),
      ),
      clipBehavior: .hardEdge,
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          return AnimatedOpacity(
            opacity: snapshot.hasData ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform(transform: transform(), alignment: Alignment.center, child: child),
              child: snapshot.data,
            ),
          );
        },
      ),
    );
  }

  Future<Widget?> background() async {
    if (widget.background == null) {
      return null;
    }
    final provider = CachedNetworkImageProvider(widget.background!);
    await precacheImage(provider, context);
    final ui.Image data = await widgetToUiImage(
      ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: blurSize, sigmaY: blurSize),
        child: CachedNetworkImage(
          imageUrl: widget.background!,
          color: Colors.black38,
          colorBlendMode: .darken,
          filterQuality: .high,
        ),
      ),
    );
    imageSize = Size(data.width.toDouble(), data.height.toDouble());
    imageSizeFixed = Size(
      imageSize.aspectRatio > size.aspectRatio ? size.width : size.height * imageSize.aspectRatio,
      imageSize.aspectRatio < size.aspectRatio ? size.height : size.width / imageSize.aspectRatio,
    );
    final ByteData? bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    return Image.memory(bytes!.buffer.asUint8List(), filterQuality: .high, fit: BoxFit.contain);
  }

  Matrix4 transform() {
    final ui.Size offsetLimitation =
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
    final matrix = Matrix4.translationValues(-size.width / 2, -size.height / 2, 0);
    matrix.scaleByVector3(Vector3(scaleSize, scaleSize, 1.0));
    matrix.translateByVector2(
      Vector2((offset.dx + size.width / 2) / scaleSize, (offset.dy + size.height / 2) / scaleSize),
    );
    return matrix;
  }

  static Future<ui.Image> widgetToUiImage(
    Widget widget, {
    Duration delay = Duration.zero,
    double? pixelRatio,
    BuildContext? context,
    Size? targetSize,
  }) async {
    var retryCounter = 3;
    var isDirty = false;

    var child = widget;

    if (context != null) {
      child = InheritedTheme.captureAll(
        context,
        MediaQuery(
          data: MediaQuery.of(context),
          child: Material(color: Colors.transparent, child: child),
        ),
      );
    }

    final repaintBoundary = RenderRepaintBoundary();
    final ui.PlatformDispatcher platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final ui.FlutterView fallBackView = platformDispatcher.views.first;
    final ui.FlutterView view = context == null ? fallBackView : View.maybeOf(context) ?? fallBackView;
    final ui.Size logicalSize = targetSize ?? view.physicalSize / view.devicePixelRatio;
    final ui.Size imageSize = targetSize ?? view.physicalSize;

    assert(logicalSize.aspectRatio.toStringAsPrecision(5) == imageSize.aspectRatio.toStringAsPrecision(5));

    final renderView = RenderView(
      view: view,
      child: RenderPositionedBox(child: repaintBoundary),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints(maxWidth: logicalSize.width, maxHeight: logicalSize.height),
        devicePixelRatio: pixelRatio ?? 1.0,
      ),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager(), onBuildScheduled: () => isDirty = true);

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
