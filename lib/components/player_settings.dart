import 'package:api/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide ListTile, SwitchListTile;
import 'package:provider/provider.dart';
import 'package:video_player/player.dart';

import '../adaptive/adaptive.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/player.dart';
import '../utils/utils.dart';

class PlayerSettings extends StatelessWidget {
  const PlayerSettings({
    super.key,
    required this.controller,
    required this.onSeekSpeedChanged,
    required this.onShowLiteProgressbarChanged,
  });

  final PlayerController controller;
  final ValueChanged<int>? onSeekSpeedChanged;
  final ValueChanged<bool> onShowLiteProgressbarChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return SettingPage.list(
      title: Text(localizations.settingsTitle),
      children: [
        ValueListenableBuilder(
          valueListenable: controller.trackGroup,
          builder: (context, value, _) => _buildTrackSelector(
            context,
            icon: const Icon(Icons.movie_outlined),
            label: localizations.videoSettingsVideo,
            tracks: value.video,
            selected: value.selectedVideo,
            onSelected: (id) => controller.setTrack('video', id),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: controller.trackGroup,
          builder: (context, value, _) => _buildTrackSelector(
            context,
            icon: const Icon(Icons.audiotrack_outlined),
            label: localizations.videoSettingsAudio,
            tracks: value.audio,
            selected: value.selectedAudio,
            onSelected: (id) => controller.setTrack('audio', id),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: controller.trackGroup,
          builder: (context, value, _) => _buildTrackSelector(
            context,
            icon: const Icon(Icons.subtitles_outlined),
            label: localizations.videoSettingsSubtitle,
            tracks: value.sub,
            selected: value.selectedSub,
            onSelected: (id) => controller.setTrack('sub', id),
          ),
        ),
        ListenableBuilder(
          listenable: controller.playbackSpeed,
          builder: (context, _) => MenuListTile(
            leading: const Icon(Icons.slow_motion_video_rounded),
            title: Text(localizations.videoSettingsSpeeding),
            trailing: Text('${controller.playbackSpeed.value}x'),
            initialValue: controller.playbackSpeed.value,
            onSelected: controller.setPlaybackSpeed,
            itemBuilder: (BuildContext context) => playerSpeedList
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
        ValueListenableBuilder(
          valueListenable: controller.trackGroup,
          builder: (context, value, _) =>
              (value.video.isEmpty && value.audio.isEmpty && value.sub.isEmpty) ? const SizedBox() : const Divider(),
        ),
        ValueListenableBuilder(
          valueListenable: controller.aspectRatio,
          builder: (context, value, _) => MenuListTile(
            leading: const Icon(Icons.aspect_ratio_rounded),
            title: Text(localizations.videoAspectRatio),
            initialValue: value,
            trailing: Text(value.label()),
            itemBuilder: (context) => AspectRatioType.values
                .map(
                  (aspectRatio) => CheckedPopupMenuItem(
                    checked: aspectRatio == controller.aspectRatio.value,
                    value: aspectRatio,
                    child: Text(aspectRatio.label()),
                  ),
                )
                .toList(),
            onSelected: (aspectRatio) {
              controller.aspectRatio.value = aspectRatio;
              controller.resizeMode.value = ResizeMode.fit;
              controller.setAspectRatio(aspectRatio.value());
              controller.setResizeMode(ResizeMode.values.indexOf(ResizeMode.fit));
            },
          ),
        ),
        ValueListenableBuilder(
          valueListenable: controller.resizeMode,
          builder: (context, value, _) => MenuListTile(
            leading: const Icon(Icons.zoom_out_map_rounded),
            title: Text(localizations.videoResizeMode),
            trailing: Text(value.label()),
            initialValue: value,
            itemBuilder: (context) => ResizeMode.values
                .map(
                  (resizeMode) => CheckedPopupMenuItem(
                    checked: resizeMode == value,
                    value: resizeMode,
                    child: Text(resizeMode.label()),
                  ),
                )
                .toList(),
            onSelected: (resizeMode) {
              controller.resizeMode.value = resizeMode;
              controller.aspectRatio.value = AspectRatioType.auto;
              controller.setAspectRatio(AspectRatioType.auto.value());
              controller.setResizeMode(ResizeMode.values.indexOf(resizeMode));
            },
          ),
        ),
        Consumer<PlayerConfig>(
          builder: (context, config, _) => ListTile(
            title: Text(localizations.subtitleSetting),
            leading: const Icon(Icons.subtitles_outlined),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final initialStyle = SubtitleSettings.fromJson(config.subtitleSettings);
              if (!context.mounted) {
                return;
              }
              final List<int>? style = await Navigator.of(context)
                  .push(FadeInPageRoute(builder: (context) => PlayerSubtitleSetting(subtitleSettings: initialStyle)));
              if (style != null) {
                config.setSubtitleSettings(style);
                await controller.setSubtitleStyle(style);
              }
            },
          ),
        ),
        const Divider(),
        Consumer<PlayerConfig>(
          builder: (context, config, _) => MenuListTile(
            title: Text(localizations.extensionRendererModeLabel),
            trailing: Text(
              localizations.extensionRendererMode(config.extensionRendererMode.toString()),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
            itemBuilder: (context) => [0, 1, 2]
                .map(
                  (i) => CheckedPopupMenuItem(
                    value: i,
                    checked: config.extensionRendererMode == i,
                    child: Text(localizations.extensionRendererMode(i.toString())),
                  ),
                )
                .toList(),
            onSelected: (value) async {
              config.setExtensionRendererMode(value);
              await PlayerController.setPlayerOption('extensionRendererMode', value);
            },
          ),
        ),
        Consumer<PlayerConfig>(
          builder: (context, config, _) => SwitchListTile(
            title: Text(localizations.playerEnableDecoderFallback),
            value: config.enableDecoderFallback,
            onChanged: (value) async {
              config.setEnableDecoderFallback(value);
              await PlayerController.setPlayerOption('enableDecoderFallback', value);
            },
          ),
        ),
        Consumer<PlayerConfig>(
          builder: (context, config, _) => SwitchListTile(
            title: Text(localizations.playerShowLiteProgressbar),
            value: config.showLiteProgressbar,
            onChanged: (value) async {
              config.setShowLiteProgressbar(value);
              onShowLiteProgressbarChanged(value);
            },
          ),
        ),
        const Divider(),
        if (onSeekSpeedChanged != null)
          Consumer<PlayerConfig>(
            builder: (context, config, _) => ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.playerFastForwardSpeed),
                  Text('${config.fastForwardSpeed} ${AppLocalizations.of(context)!.second}'),
                ],
              ),
              subtitle: MediaQuery(
                data: const MediaQueryData(navigationMode: .directional),
                child: Slider(
                  value: config.fastForwardSpeed.toDouble(),
                  min: 5,
                  max: 100,
                  divisions: 19,
                  padding: const .only(top: 24, bottom: 6),
                  label: config.fastForwardSpeed.toString(),
                  onChanged: (double value) {
                    config.setFastForwardSpeed(value.round());
                    onSeekSpeedChanged!(value.round());
                  },
                ),
              ),
            ),
          ),
        const Divider(),
        ValueListenableBuilder(
          valueListenable: controller.index,
          builder: (context, value, _) {
            final PlaylistItem? item = controller.currentItem;
            return item?.canSkipIntro ?? false
                ? ListTile(
                    title: Text(AppLocalizations.of(context)!.buttonSkipFromStart),
                    onTap: () async {
                      if (item?.source is TVEpisode) {
                        final TVEpisode episode = await Api.tvEpisodeQueryById((item!.source as TVEpisode).id);
                        if (context.mounted) {
                          final Duration? time = await context.pushNamed<Duration>(
                            .setSkipTime,
                            arguments: SetSkipTimeData(
                              skipTimeType: SkipTimeType.intro,
                              value: controller.position.value,
                              mediaType: MediaType.season,
                              id: episode.seasonId,
                            ),
                          );
                          if (time != null) {
                            controller.setSkipPosition(SkipTimeType.intro.name, time);
                          }
                        }
                      }
                    },
                  )
                : const SizedBox();
          },
        ),
        ValueListenableBuilder(
          valueListenable: controller.index,
          builder: (context, value, _) {
            final PlaylistItem? item = controller.currentItem;
            return item?.canSkipIntro ?? false
                ? ListTile(
                    title: Text(AppLocalizations.of(context)!.buttonSkipFromEnd),
                    onTap: () async {
                      if (item?.source is TVEpisode) {
                        final TVEpisode episode = await Api.tvEpisodeQueryById((item!.source as TVEpisode).id);
                        if (context.mounted) {
                          final Duration? time = await context.pushNamed<Duration>(
                            .setSkipTime,
                            arguments: SetSkipTimeData(
                              skipTimeType: SkipTimeType.ending,
                              value: controller.position.value,
                              mediaType: MediaType.season,
                              id: episode.seasonId,
                            ),
                          );
                          if (time != null) {
                            controller.setSkipPosition(SkipTimeType.ending.name, time);
                          }
                        }
                      }
                    },
                  )
                : const SizedBox();
          },
        ),
        ValueListenableBuilder(
          valueListenable: controller.index,
          builder: (context, value, _) {
            final PlaylistItem? item = controller.currentItem;
            return item?.downloadable ?? false
                ? ListTile(
                    title: Text(AppLocalizations.of(context)!.buttonDownload),
                    onTap: () async {
                      if (item?.source is TVEpisode) {
                        await showNotification(
                          context,
                          Api.downloadTaskCreate(
                            (item!.source as TVEpisode).fileId,
                            FilePicker.requestStoragePermission(),
                          ),
                          successText: AppLocalizations.of(context)!.tipsForDownload,
                        );
                      } else if (item?.source is Movie) {
                        await showNotification(
                          context,
                          Api.downloadTaskCreate((item!.source as Movie).fileId, FilePicker.requestStoragePermission()),
                          successText: AppLocalizations.of(context)!.tipsForDownload,
                        );
                      }
                    },
                  )
                : const SizedBox();
          },
        ),
        ValueListenableBuilder(
          valueListenable: controller.index,
          builder: (context, value, _) {
            final PlaylistItem? item = controller.currentItem;
            return item != null && (item.canSkipIntro || item.canSkipEnding || item.downloadable)
                ? const Divider()
                : const SizedBox();
          },
        ),
        ValueListenableBuilder(
          valueListenable: controller.trackGroup,
          builder: (context, value, _) => DefaultTextStyle(
            style: Theme.of(context).textTheme.bodySmall!,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                    children: [const Text('Codecs'), Text(value.selectedVideo?.codecs ?? localizations.tagUnknown)],
                  ),
                  TableRow(
                    children: [
                      const Text('Mime'),
                      Text(value.selectedVideo?.sampleMimeType ?? localizations.tagUnknown),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('FPS'),
                      Text(value.selectedVideo?.frameRate?.toString() ?? localizations.tagUnknown),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Size'),
                      Text('${value.selectedVideo?.width} x ${value.selectedVideo?.height}'),
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
                    children: [const Text('Codecs'), Text(value.selectedAudio?.codecs ?? localizations.tagUnknown)],
                  ),
                  TableRow(
                    children: [
                      const Text('Mime'),
                      Text(value.selectedAudio?.sampleMimeType ?? localizations.tagUnknown),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Bitrate'),
                      Text(value.selectedAudio?.bitrate.toString() ?? localizations.tagUnknown),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Focus(child: SizedBox()),
      ],
    );
  }

  Widget _buildTrackSelector(
    BuildContext context, {
    required Widget icon,
    required String label,
    required List<MediaTrack> tracks,
    MediaTrack? selected,
    required Function(dynamic) onSelected,
  }) {
    if (tracks.isEmpty) {
      return const SizedBox();
    }
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return MenuListTile(
      leading: icon,
      title: Text(label),
      initialValue: selected?.id,
      trailing: Text(selected?.name ?? localizations.none, overflow: TextOverflow.ellipsis),
      itemBuilder: (context) => [
        CheckedPopupMenuItem(checked: selected == null, child: Text(localizations.none)),
        ...tracks.map(
          (e) =>
              CheckedPopupMenuItem<String?>(checked: e.id == selected?.id, value: e.id, child: Text(_getTrackText(e))),
        ),
      ],
      onSelected: onSelected,
    );
  }

  String _getTrackText(MediaTrack track) {
    final List<dynamic> spans = [];
    if (track.name?.isNotEmpty ?? false) {
      spans.add(track.name);
    }
    if (track.label?.isNotEmpty ?? false) {
      spans.add(track.label);
    }
    if (track.sampleMimeType?.isNotEmpty ?? false) {
      final List<String> mimes = track.sampleMimeType!.split('/');
      if (mimes.length >= 2) {
        spans.add(mimes[1]);
      }
    }
    if (track.sampleRate != null && track.sampleRate! > 0) {
      spans.add('${track.sampleRate}Hz');
    }
    if (track.averageBitrate != null && track.averageBitrate! > 0) {
      spans.add('${track.averageBitrate}Bit/s');
    }
    return spans.join(', ');
  }
}

extension on PlaylistItem {
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
