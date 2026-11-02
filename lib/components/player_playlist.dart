import 'dart:math';

import 'package:flutter/material.dart' hide Scrollbar;
import 'package:video_player/player.dart';

import '../adaptive/adaptive.dart';
import 'playing_icon.dart';

class PlayerPlaylist<T> extends StatefulWidget {
  const PlayerPlaylist({super.key, required this.onTap, this.activeIndex, required this.playlist});

  final ValueChanged<int> onTap;
  final int? activeIndex;
  final List<PlaylistItem> playlist;

  @override
  State<PlayerPlaylist<T>> createState() => _PlayerPlaylistState<T>();
}

class _PlayerPlaylistState<T> extends State<PlayerPlaylist<T>> {
  late final _controller = ScrollController(
    initialScrollOffset: min(
      (widget.activeIndex ?? 0) * 216,
      max(widget.playlist.length * 216 - MediaQuery.sizeOf(context).width + 64, 0),
    ),
  );

  @override
  void didUpdateWidget(covariant PlayerPlaylist<T> oldWidget) {
    final int? index = widget.activeIndex;
    if (index != oldWidget.activeIndex && index != null && index >= 0 && index < widget.playlist.length) {
      final double offset = min(_controller.position.maxScrollExtent, index * (200.0 + 12));
      _controller.animateTo(offset, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 48),
        itemCount: widget.playlist.length,
        itemExtent: 216,
        itemBuilder: (context, index) {
          final PlaylistItem item = widget.playlist[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ImageCard(
              src: item.poster,
              width: 200,
              height: 112,
              title: item.title != null ? Text(item.title!) : null,
              subtitle: item.description != null ? Text(item.description!) : null,
              floating: index == widget.activeIndex
                  ? Positioned(right: 8, top: 8, child: PlayingIcon(color: Theme.of(context).colorScheme.primary))
                  : null,
              autofocus: index == widget.activeIndex,
              onTap: () => widget.onTap(index),
            ),
          );
        },
      ),
    );
  }
}
