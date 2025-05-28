import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:video_player/player.dart';

import '../../../components/placeholder.dart';
import '../../../components/playing_icon.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../components/image_card.dart';

class PlaylistSection extends StatefulWidget {
  const PlaylistSection({
    super.key,
    this.activeIndex,
    required this.playlist,
    this.onTap,
    required this.imageWidth,
    required this.imageHeight,
    this.placeholderCount,
  });

  final double imageWidth;
  final double imageHeight;
  final int? placeholderCount;

  final int? activeIndex;
  final List<PlaylistItemDisplay<dynamic>> playlist;

  final ValueChanged<int>? onTap;

  @override
  State<PlaylistSection> createState() => _PlaylistSectionState();
}

class _PlaylistSectionState extends State<PlaylistSection> {
  late final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlaylistSection oldWidget) {
    final index = widget.activeIndex;
    if (index != oldWidget.activeIndex && index != null && index >= 0 && index < widget.playlist.length) {
      final offset = min(_controller.position.maxScrollExtent, index * (widget.imageWidth + 12));
      _controller.animateTo(offset, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.playlist.isNotEmpty
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(AppLocalizations.of(context)!.titlePlaylist, style: Theme.of(context).textTheme.titleMedium),
            ),
            SizedBox(
              height: widget.imageHeight + 50,
              child: ListView.separated(
                controller: _controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemCount: widget.playlist.length,
                itemBuilder: (context, index) {
                  final item = widget.playlist[index];
                  return ImageCard(
                    item.poster,
                    width: widget.imageWidth,
                    height: widget.imageHeight,
                    title: Text(
                      item.title!,
                      style:
                          widget.activeIndex == index ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
                    ),
                    subtitle:
                        item.description != null
                            ? Text(
                              item.description!,
                              style:
                                  widget.activeIndex == index
                                      ? TextStyle(color: Theme.of(context).colorScheme.primary)
                                      : null,
                            )
                            : null,
                    floating:
                        widget.activeIndex == index
                            ? Material(
                              shape: RoundedRectangleBorder(
                                side:
                                    widget.activeIndex == index
                                        ? BorderSide(
                                          width: 6,
                                          color: Theme.of(context).colorScheme.primary,
                                          strokeAlign: BorderSide.strokeAlignCenter,
                                        )
                                        : BorderSide.none,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              color: Theme.of(context).scaffoldBackgroundColor.withAlpha(0x66),
                              child: SizedBox(
                                width: widget.imageWidth,
                                height: widget.imageHeight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    PlayingIcon(color: Theme.of(context).colorScheme.primary),
                                    if (item.duration != null)
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Badge(
                                          label: Text(item.duration!.toDisplay()),
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                            : item.duration != null
                            ? SizedBox(
                              width: widget.imageWidth,
                              height: widget.imageHeight,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Badge(
                                    label: Text(item.duration!.toDisplay()),
                                    backgroundColor:
                                        widget.activeIndex == index
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            )
                            : null,
                    onTap: widget.onTap == null ? null : () => widget.onTap!(index),
                  );
                },
              ),
            ),
          ],
        )
        : _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return GPlaceholder(
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GPlaceholderRect(width: 100, height: 24, padding: EdgeInsets.all(16)),
            SizedBox(
              height: widget.imageHeight + 50,
              child: ListView.separated(
                controller: _controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemCount: widget.placeholderCount ?? 10,
                itemBuilder:
                    (context, index) => ImageCardPlaceholder(width: widget.imageWidth, height: widget.imageHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on PlaylistItemDisplay<dynamic> {
  Duration? get duration {
    if (source is Movie) {
      return (source as Movie).duration;
    } else if (source is TVEpisode) {
      return (source as TVEpisode).duration;
    } else {
      return null;
    }
  }
}
