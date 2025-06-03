import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/player.dart';

import '../../models/models.dart';
import '../../providers/user_config.dart';
import '../../utils/utils.dart';
import 'player_controls_full.dart';

class SingletonPlayer<T> extends StatefulWidget {
  const SingletonPlayer({super.key, required this.playlist, this.index = 0, this.theme});

  final List<PlaylistItemDisplay<T>> playlist;
  final int index;
  final int? theme;

  @override
  State<SingletonPlayer<T>> createState() => _SingletonPlayerState<T>();
}

class _SingletonPlayerState<T> extends State<SingletonPlayer<T>> {
  late final _controller = PlayerController<T>(
    Api.log,
    onGetPlayBackInfo: _onGetPlayBackInfo,
    onPlaybackStatusUpdate: _onPlaybackStatusUpdate,
  );
  late final _progressController = PlayerProgressController(_controller);

  Future<PlaylistItem> _onGetPlayBackInfo(PlaylistItemDisplay<T> item) async {
    final fileId = _controller.currentItem!.fileId;
    if (item.fileId == null) {
      return PlaylistItem(
        url: item.url!,
        title: item.title,
        description: item.description,
        poster: item.poster,
        start: item.start,
        end: item.end,
      );
    } else {
      final data = await Api.playbackInfo(fileId);
      return PlaylistItem(
        url: Uri.parse(data.url).normalize(),
        title: item.title,
        description: item.description,
        poster: item.poster,
        start: item.start,
        end: item.end,
        subtitles: data.subtitles.map((d) => d.toSubtitle()).nonNulls.toList(),
      );
    }
  }

  Future<void> _onPlaybackStatusUpdate(
    PlaylistItem item,
    PlaybackStatusEvent eventType,
    Duration position,
    Duration duration,
  ) {
    final source = _controller.currentItem!.source;
    if (source is TVEpisode) {
      return Api.updatePlayedStatus(
        LibraryType.tv,
        source.id,
        position: position,
        duration: duration,
        eventType: eventType.name,
        others: item.others,
      );
    } else if (source is Movie) {
      return Api.updatePlayedStatus(
        LibraryType.movie,
        source.id,
        position: position,
        duration: duration,
        eventType: eventType.name,
        others: item.others,
      );
    } else {
      return Future.value();
    }
  }

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
        PlayerPlatformView(
          autoPip: context.read<UserConfig>().autoPip,
          initialized: () async {
            await _controller.enterFullscreen();
            _controller.setPlaylist(widget.playlist);
            await _controller.next(0);
            await _controller.play();
          },
        ),
        PlayerControlsFull(_controller, _progressController, theme: widget.theme),
      ],
    );
  }
}
