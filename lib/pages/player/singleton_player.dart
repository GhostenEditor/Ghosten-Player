import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:video_player/player.dart';

import 'player_controls_full.dart';

class SingletonPlayer<T> extends StatefulWidget {
  const SingletonPlayer({super.key, required this.playlist, this.index = 0, this.theme});

  final List<PlaylistItem<T>> playlist;
  final int index;
  final int? theme;

  @override
  State<SingletonPlayer<T>> createState() => _SingletonPlayerState<T>();
}

class _SingletonPlayerState<T> extends State<SingletonPlayer<T>> {
  late final _controller = PlayerController<T>(Api.log);
  late final _progressController = PlayerProgressController(_controller);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PlayerPlatformView(initialized: () {
          _controller.setSources(widget.playlist, widget.index);
          _controller.play();
        }),
        PlayerControlsFull(_controller, _progressController, theme: widget.theme),
      ],
    );
  }
}
