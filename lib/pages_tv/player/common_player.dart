import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:video_player/player.dart';

import '../../components/player_i18n_adaptor.dart';
import '../components/focusable_image.dart';
import '../components/setting.dart';
import '../components/time_picker.dart';
import '../utils/notification.dart';
import '../utils/utils.dart';
import 'player_controls.dart';

class CommonPlayerPage<T> extends StatefulWidget {
  const CommonPlayerPage({
    super.key,
    required this.playlist,
    required this.index,
    this.theme,
    this.isTV = false,
  });

  final List<PlaylistItemDisplay<T>> playlist;
  final int index;
  final int? theme;
  final bool isTV;

  @override
  State<CommonPlayerPage<T>> createState() => _CommonPlayerPageState();
}

class _CommonPlayerPageState<T> extends State<CommonPlayerPage<T>> {
  final _controller = PlayerController<T>(Api.log);

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
          initialized: () {
            _controller.setSources(widget.playlist);
            _controller.play();
          },
        ),
        PlayerI18nAdaptor(
          child: PlayerControls(
            controller: _controller,
            theme: widget.theme,
            actions: (context) => [
              if (_controller.currentItem?.canSkipIntro ?? false)
                ButtonSettingItem(
                  leading: const Icon(Icons.access_time),
                  title: Text(AppLocalizations.of(context)!.buttonSkipFromStart),
                  onTap: () async {
                    final time = await Navigator.of(context).push(FadeInPageRoute<Duration>(
                        builder: (context) => SettingPage(
                            title: AppLocalizations.of(context)!.buttonSkipFromStart,
                            child: TimePicker(
                              value: _controller.position.value,
                            ))));
                    if (time != null) {
                      if (T is TVEpisode) {
                        final episode = await Api.tvEpisodeQueryById((_controller.currentItem!.source as TVEpisode).id);
                        Api.setSkipTime(SkipTimeType.intro, MediaType.season, episode.seasonId, time);
                        _controller.setSkipPosition(
                            SkipTimeType.intro.name, _controller.playlist.value.map((item) => max(time.inMilliseconds, item.start.inMilliseconds)).toList());
                      }
                    }
                  },
                ),
              if (_controller.currentItem?.canSkipEnding ?? false)
                ButtonSettingItem(
                  leading: const Icon(Icons.access_time),
                  title: Text(AppLocalizations.of(context)!.buttonSkipFromEnd),
                  onTap: () async {
                    final time = await Navigator.of(context).push(FadeInPageRoute<Duration>(
                        builder: (context) => SettingPage(
                            title: AppLocalizations.of(context)!.buttonSkipFromEnd,
                            child: TimePicker(
                              value: _controller.duration.value > _controller.position.value
                                  ? _controller.duration.value - _controller.position.value
                                  : Duration.zero,
                            ))));
                    if (time != null) {
                      if (T is TVEpisode) {
                        final episode = await Api.tvEpisodeQueryById((_controller.currentItem!.source as TVEpisode).id);
                        Api.setSkipTime(SkipTimeType.ending, MediaType.season, episode.seasonId, time);
                        _controller.setSkipPosition(SkipTimeType.ending.name, List.generate(_controller.playlist.value.length, (index) => time.inMilliseconds));
                      }
                    }
                  },
                ),
              if (_controller.currentItem?.downloadable ?? false)
                ButtonSettingItem(
                  leading: const Icon(Icons.download_outlined),
                  title: Text(AppLocalizations.of(context)!.buttonDownload),
                  onTap: () {
                    final item = _controller.currentItem!;
                    showNotification(
                      context,
                      Api.downloadTaskCreate(item.url!.queryParameters['id']),
                      successText: AppLocalizations.of(context)!.tipsForDownload,
                    );
                  },
                ),
            ],
            onMediaChange: (index, position, duration) {
              final item = _controller.playlist.value[index];
              if (item.source is TVEpisode) {
                Api.updatePlayedStatus(LibraryType.tv, (item.source as TVEpisode).id, position: position, duration: duration);
              } else if (item.source is Movie) {
                Api.updatePlayedStatus(LibraryType.movie, (item.source as Movie).id, position: position, duration: duration);
              }
            },
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
                              )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.title != null) Text(item.title!, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                        if (item.description != null) Text(item.description!, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ],
                ),
              );
            },
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
