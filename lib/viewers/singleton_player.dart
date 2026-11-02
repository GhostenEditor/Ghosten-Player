import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/player.dart';

import '../adaptive/adaptive.dart';
import '../components/components.dart ';
import '../models/models.dart';
import '../providers/player.dart';
import '../utils/utils.dart';

class SingletonPlayer extends StatefulWidget {
  const SingletonPlayer({super.key, required this.data});

  final PlaylistData data;

  @override
  State<SingletonPlayer> createState() => _SingletonPlayerState();
}

class _SingletonPlayerState extends State<SingletonPlayer> {
  late final _controller = PlayerController(
    onGetPlayBackInfo: _onGetPlayBackInfo,
    onPlaybackStatusUpdate: _onPlaybackStatusUpdate,
  );

  Future<PlayerFileInfo> _onGetPlayBackInfo(PlaylistItem item) async {
    final dynamic source = _controller.currentItem!.source;
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

  Future<void> _onPlaybackStatusUpdate(
    dynamic others,
    PlaybackStatusEvent eventType,
    Duration position,
    Duration duration,
  ) {
    final dynamic source = _controller.currentItem!.source;
    final LibraryType? libraryType = switch (source) {
      final TVEpisode _ => LibraryType.tv,
      final Movie _ => LibraryType.movie,
      _ => null,
    };
    if (libraryType == null) {
      return Future.value();
    }
    return Api.updatePlayedStatus(
      libraryType,
      (source as MediaBase).id,
      position: position,
      duration: duration,
      eventType: switch (eventType) {
        PlaybackStatusEvent.start => PlayedStatusUpdateEventType.start,
        PlaybackStatusEvent.progress => PlayedStatusUpdateEventType.progress,
        PlaybackStatusEvent.stop => PlayedStatusUpdateEventType.stop,
      },
      others: others,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int activeIndex = widget.data.activeIndex;
    final List<PlaylistItem> playlist = widget.data.playlist;
    final PlayerConfig playerConfig = context.read<PlayerConfig>();
    final String languageCode = Localizations.localeOf(context).languageCode;
    return ThemeBuilder(
      widget.data.themeColor,
      builder: (context) => PlayerPlatformView(
        playerType: playerConfig.playerType,
        mpvVersion: playerConfig.mpvVersion,
        autoPip: playerConfig.autoPip,
        initialized: () async {
          _controller.setPlaylist(playlist);
          await _controller.next(activeIndex);
          await _controller.play();
        },
        initializeFailed: (e) => _controller.fatalError.value = e.message,
        extensionRendererMode: playerConfig.extensionRendererMode,
        enableDecoderFallback: playerConfig.enableDecoderFallback,
        subtitleStyle: playerConfig.subtitleSettings,
        preferredSubtitleLanguage: playerConfig.preferredSubtitleLanguage ?? languageCode,
        preferredAudioLanguage: playerConfig.preferredAudioLanguage ?? languageCode,
        controls: PlayerControls(controller: _controller),
      ),
    );
  }
}
