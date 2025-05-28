import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:video_player/player.dart';

import '../../components/error_message.dart';
import '../../components/player_i18n_adaptor.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../components/focusable_image.dart';
import '../components/loading.dart';
import '../components/setting.dart';
import '../components/time_picker.dart';
import '../utils/notification.dart';
import '../utils/utils.dart';
import 'player_controls.dart';

class CommonPlayerPage<T> extends StatefulWidget {
  const CommonPlayerPage({super.key, required this.playlist, this.theme});

  final FutureOr<(List<PlaylistItemDisplay<T>>, int)> playlist;
  final int? theme;

  @override
  State<CommonPlayerPage<T>> createState() => _CommonPlayerPageState();
}

class _CommonPlayerPageState<T> extends State<CommonPlayerPage<T>> {
  bool loading = true;
  late final _controller = PlayerController<T>(
    Api.log,
    onGetPlayBackInfo: _onGetPlayBackInfo,
    onPlaybackStatusUpdate: _onPlaybackStatusUpdate,
  );

  Future<PlaylistItem> _onGetPlayBackInfo(PlaylistItemDisplay<T> item) async {
    final data = await Api.playbackInfo(item.fileId);
    return PlaylistItem(
      title: item.title,
      description: item.description,
      poster: item.poster,
      start: item.start,
      end: item.end,
      url: Uri.parse(data.url).normalize(),
      subtitles: data.subtitles.map((d) => d.toSubtitle()).nonNulls.toList(),
      others: data.others,
    );
  }

  Future<void> _onPlaybackStatusUpdate(
    PlaylistItem item,
    PlaybackStatusEvent eventType,
    Duration position,
    Duration duration,
  ) {
    final source = _controller.currentItem!.source;
    return switch (source) {
      final TVEpisode s => Api.updatePlayedStatus(
        LibraryType.tv,
        s.id,
        position: position,
        duration: duration,
        eventType: eventType.name,
        others: item.others,
      ),
      final Movie s => Api.updatePlayedStatus(
        LibraryType.movie,
        s.id,
        position: position,
        duration: duration,
        eventType: eventType.name,
        others: item.others,
      ),
      _ => Future.value(),
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PlayerPlatformView(
          initialized: () async {
            try {
              final playlist = await widget.playlist;
              _controller.setPlaylist(playlist.$1);
              assert(playlist.$2.clamp(0, playlist.$1.length - 1) == playlist.$2);
              await _controller.next(playlist.$2);
              await _controller.play();
              setState(() {
                loading = false;
              });
            } catch (e) {
              _controller.playlistError.value = e;
            }
          },
        ),
        ListenableBuilder(
          listenable: _controller.playlistError,
          builder:
              (context, child) =>
                  _controller.playlistError.value == null
                      ? loading
                          ? Theme(
                            data: ThemeData(
                              colorSchemeSeed: widget.theme != null ? Color(widget.theme!) : null,
                              brightness: Brightness.dark,
                              drawerTheme: const DrawerThemeData(endShape: RoundedRectangleBorder()),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 28),
                              child: Builder(
                                builder: (context) {
                                  return Loading(color: Theme.of(context).colorScheme.primary);
                                },
                              ),
                            ),
                          )
                          : child!
                      : Theme(
                        data: ThemeData.dark(),
                        child: Scaffold(body: Center(child: ErrorMessage(error: _controller.playlistError.value))),
                      ),
          child: PlayerI18nAdaptor(
            child: PlayerControls(
              controller: _controller,
              theme: widget.theme,
              actions:
                  (context) => [
                    if (_controller.currentItem?.canSkipIntro ?? false)
                      ButtonSettingItem(
                        leading: const Icon(Icons.access_time),
                        title: Text(AppLocalizations.of(context)!.buttonSkipFromStart),
                        onTap: () async {
                          final time = await Navigator.of(context).push(
                            FadeInPageRoute<Duration>(
                              builder:
                                  (context) => SettingPage(
                                    title: AppLocalizations.of(context)!.buttonSkipFromStart,
                                    child: TimePicker(value: _controller.position.value),
                                  ),
                            ),
                          );
                          if (time != null) {
                            if (_controller.currentItem!.source is TVEpisode) {
                              final episode = await Api.tvEpisodeQueryById(
                                (_controller.currentItem!.source as TVEpisode).id,
                              );
                              Api.setSkipTime(SkipTimeType.intro, MediaType.season, episode.seasonId, time);
                              _controller.setSkipPosition(SkipTimeType.intro.name, time);
                            }
                          }
                        },
                      ),
                    if (_controller.currentItem?.canSkipEnding ?? false)
                      ButtonSettingItem(
                        leading: const Icon(Icons.access_time),
                        title: Text(AppLocalizations.of(context)!.buttonSkipFromEnd),
                        onTap: () async {
                          final time = await Navigator.of(context).push(
                            FadeInPageRoute<Duration>(
                              builder:
                                  (context) => SettingPage(
                                    title: AppLocalizations.of(context)!.buttonSkipFromEnd,
                                    child: TimePicker(
                                      value:
                                          _controller.duration.value > _controller.position.value
                                              ? _controller.duration.value - _controller.position.value
                                              : Duration.zero,
                                    ),
                                  ),
                            ),
                          );
                          if (time != null) {
                            if (_controller.currentItem!.source is TVEpisode) {
                              final episode = await Api.tvEpisodeQueryById(
                                (_controller.currentItem!.source as TVEpisode).id,
                              );
                              Api.setSkipTime(SkipTimeType.ending, MediaType.season, episode.seasonId, time);
                              _controller.setSkipPosition(SkipTimeType.ending.name, time);
                            }
                          }
                        },
                      ),
                    if (_controller.currentItem?.downloadable ?? false)
                      ButtonSettingItem(
                        leading: const Icon(Icons.download_outlined),
                        title: Text(AppLocalizations.of(context)!.buttonDownload),
                        onTap: () {
                          final item = _controller.currentItem;
                          if (item?.source is TVEpisode) {
                            showNotification(
                              context,
                              Api.downloadTaskCreate((item!.source as TVEpisode).fileId),
                              successText: AppLocalizations.of(context)!.tipsForDownload,
                              showSuccess: true,
                            );
                          } else if (item?.source is Movie) {
                            showNotification(
                              context,
                              Api.downloadTaskCreate((item!.source as Movie).fileId),
                              successText: AppLocalizations.of(context)!.tipsForDownload,
                              showSuccess: true,
                            );
                          }
                        },
                      ),
                  ],
              playlistItemBuilder: (context, index, onTap) {
                final item = _controller.playlist.value[index];
                return SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          FocusableImage(
                            width: 200,
                            height: 112,
                            poster: item.poster,
                            autofocus: index == _controller.index.value,
                            onTap: () => onTap(index),
                          ),
                          if (index == _controller.index.value)
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.play_circle_rounded, color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.title != null)
                            Text(
                              item.title!,
                              style: Theme.of(context).textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (item.description != null)
                            Text(
                              item.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

extension on PlaylistItemDisplay<dynamic> {
  bool get downloadable {
    if (source is Movie) {
      return !(source as Movie).downloaded;
    } else if (source is TVEpisode) {
      return !(source as TVEpisode).downloaded;
    } else {
      return false;
    }
  }

  bool get canSkipIntro {
    return source is TVEpisode;
  }

  bool get canSkipEnding {
    return source is TVEpisode;
  }
}
