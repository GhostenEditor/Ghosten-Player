import 'dart:async';
import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:player_view/player.dart';
import 'package:provider/provider.dart';

import '../../components/async_image.dart';
import '../../components/focus_card.dart';
import '../../dialogs/timer_picker.dart';
import '../../models/models.dart';
import '../../platform_api.dart';
import '../../providers/user_config.dart';
import '../../utils/notification.dart';
import 'cast_adaptor.dart';

class CommonPlayerPage extends StatefulWidget {
  final List<ExPlaylistItem> playlist;
  final int index;
  final int? theme;
  final PlayerType playerType;
  final bool isTV;

  const CommonPlayerPage({
    super.key,
    required this.playlist,
    required this.index,
    required this.playerType,
    this.theme,
    this.isTV = false,
  });

  @override
  State<CommonPlayerPage> createState() => _CommonPlayerPageState();
}

class _CommonPlayerPageState extends State<CommonPlayerPage> {
  late final userConfig = context.read<UserConfig>();
  late final controller = PlayerController<ExPlaylistItem>(widget.playlist, widget.index, Api.log);
  late final StreamSubscription<bool> _pipSubscription;
  final cast = const CastAdaptor();

  @override
  void initState() {
    _pipSubscription = PlatformApi.pipEvent.listen((flag) {
      controller.pipMode.value = flag;
    });
    super.initState();
  }

  @override
  void dispose() {
    _pipSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlayerControls(
      localizations: PlayerLocalizations(
        settingsTitle: AppLocalizations.of(context)!.settingsTitle,
        videoSettingsVideo: AppLocalizations.of(context)!.videoSettingsVideo,
        videoSettingsAudio: AppLocalizations.of(context)!.videoSettingsAudio,
        videoSettingsSubtitle: AppLocalizations.of(context)!.videoSettingsSubtitle,
        videoSettingsSpeeding: AppLocalizations.of(context)!.videoSettingsSpeeding,
        videoSize: AppLocalizations.of(context)!.videoSize,
        videoSettingsNone: AppLocalizations.of(context)!.none,
        tagUnknown: AppLocalizations.of(context)!.tagUnknown,
        willSkipEnding: AppLocalizations.of(context)!.willSkipEnding,
      ),
      controller: controller,
      isTV: widget.isTV,
      showThumbnails: userConfig.playerConfig.showThumbnails,
      seekStep: Duration(seconds: userConfig.playerConfig.speed),
      extensionRendererMode: userConfig.playerConfig.mode,
      enableDecoderFallback: userConfig.playerConfig.enableDecoderFallback,
      theme: widget.theme,
      cast: cast,
      actions: (context) => [
        if (controller.currentItem.canSkipIntro)
          ListTile(
            title: Text(AppLocalizations.of(context)!.buttonSkipFromStart),
            onTap: () async {
              final time = await showDialog<Duration>(
                  context: context,
                  builder: (context) => TimerPickerDialog(value: controller.position.value, title: AppLocalizations.of(context)!.buttonSkipFromStart));
              if (time != null) {
                if (widget.playerType == PlayerType.tv) {
                  final episode = await Api.tvEpisodeQueryById(controller.currentItem.id);
                  Api.setSkipTime(SkipTimeType.intro, MediaType.season, episode.seasonId, time);
                  controller.setSkipPosition(
                      SkipTimeType.intro.name, controller.playlist.map((item) => max(time.inMilliseconds, item.start.inMilliseconds)).toList());
                }
              }
            },
          ),
        if (controller.currentItem.canSkipEnding)
          ListTile(
            title: Text(AppLocalizations.of(context)!.buttonSkipFromEnd),
            onTap: () async {
              final time = await showDialog<Duration>(
                  context: context,
                  builder: (context) => TimerPickerDialog(
                      value: controller.duration.value > controller.position.value ? controller.duration.value - controller.position.value : Duration.zero,
                      title: AppLocalizations.of(context)!.buttonSkipFromEnd));
              if (time != null) {
                if (widget.playerType == PlayerType.tv) {
                  final episode = await Api.tvEpisodeQueryById(controller.currentItem.id);
                  Api.setSkipTime(SkipTimeType.ending, MediaType.season, episode.seasonId, time);
                  controller.setSkipPosition(SkipTimeType.ending.name, List.generate(controller.playlist.length, (index) => time.inMilliseconds));
                }
              }
            },
          ),
        if (controller.currentItem.downloadable)
          ListTile(
            title: Text(AppLocalizations.of(context)!.buttonDownload),
            onTap: () async {
              final item = controller.currentItem;
              if (!context.mounted) return;
              final playerConfig = Provider.of<UserConfig>(navigatorKey.currentContext!, listen: false).playerConfig;
              switch (widget.playerType) {
                case PlayerType.tv:
                  showNotification(
                    context,
                    Api.downloadTaskCreate(
                      item.url.queryParameters['id']!,
                      parallels: playerConfig.enableParallel ? playerConfig.parallels : null,
                      size: playerConfig.enableParallel ? playerConfig.sliceSize : null,
                    ),
                    successText: AppLocalizations.of(context)!.tipsForDownload,
                  );
                case PlayerType.movie:
                  showNotification(
                    context,
                    Api.downloadTaskCreate(
                      item.url.queryParameters['id']!,
                      parallels: playerConfig.enableParallel ? playerConfig.parallels : null,
                      size: playerConfig.enableParallel ? playerConfig.sliceSize : null,
                    ),
                    successText: AppLocalizations.of(context)!.tipsForDownload,
                  );
                case PlayerType.live:
              }
            },
            trailing: const Badge(label: Text('Beta')),
          ),
      ],
      onMediaChange: (index, position, duration) {
        final item = controller.playlist[index];
        switch (widget.playerType) {
          case PlayerType.tv:
            Api.updatePlayedStatus(LibraryType.tv, item.id, position: position, duration: duration);
          case PlayerType.movie:
            Api.updatePlayedStatus(LibraryType.movie, item.id, position: position, duration: duration);
          case PlayerType.live:
        }
      },
      playlistItemBuilder: (context, index, onTap) {
        final item = controller.playlist[index];
        return SizedBox(
          width: 200,
          child: FocusCard(
            autofocus: index == controller.index.value,
            onTap: () => onTap(index),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      item.poster != null
                          ? AsyncImage(
                              item.poster!,
                              ink: true,
                              fit: widget.playerType == PlayerType.live ? BoxFit.contain : BoxFit.cover,
                              padding: widget.playerType == PlayerType.live ? const EdgeInsets.only(left: 40, right: 40, top: 20) : EdgeInsets.zero,
                            )
                          : Container(color: Theme.of(context).colorScheme.onSurface.withAlpha(0x11), child: const Icon(Icons.image_not_supported, size: 50)),
                      if (index == controller.index.value)
                        Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.play_circle_rounded, color: Theme.of(context).colorScheme.primary),
                            )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.title != null) Text(item.title!, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                      if (item.description != null) Text(item.description!, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
