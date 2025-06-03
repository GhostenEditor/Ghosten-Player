import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:video_player/player.dart';

import '../../../l10n/app_localizations.dart';
import '../../dialogs/timer_picker.dart';
import '../../utils/notification.dart';

mixin PlayerActionsMixin<S extends StatefulWidget> on State<S> {
  List<Widget> actions<T>(BuildContext context, PlayerController<T> controller) {
    return [
      if (controller.currentItem?.canSkipIntro ?? false)
        ListTile(
          title: Text(AppLocalizations.of(context)!.buttonSkipFromStart),
          onTap: () async {
            final time = await showDialog<Duration>(
              context: context,
              builder:
                  (context) => TimerPickerDialog(
                    value: controller.position.value,
                    title: AppLocalizations.of(context)!.buttonSkipFromStart,
                  ),
            );
            if (time != null) {
              if (controller.currentItem?.source is TVEpisode) {
                final episode = await Api.tvEpisodeQueryById((controller.currentItem!.source as TVEpisode).id);
                Api.setSkipTime(SkipTimeType.intro, MediaType.season, episode.seasonId, time);
                controller.setSkipPosition(SkipTimeType.intro.name, time);
              }
            }
          },
        ),
      if (controller.currentItem?.canSkipEnding ?? false)
        ListTile(
          title: Text(AppLocalizations.of(context)!.buttonSkipFromEnd),
          onTap: () async {
            final time = await showDialog<Duration>(
              context: context,
              builder:
                  (context) => TimerPickerDialog(
                    value:
                        controller.duration.value > controller.position.value
                            ? controller.duration.value - controller.position.value
                            : Duration.zero,
                    title: AppLocalizations.of(context)!.buttonSkipFromEnd,
                  ),
            );
            if (time != null) {
              if (controller.currentItem?.source is TVEpisode) {
                final episode = await Api.tvEpisodeQueryById((controller.currentItem!.source as TVEpisode).id);
                Api.setSkipTime(SkipTimeType.ending, MediaType.season, episode.seasonId, time);
                controller.setSkipPosition(SkipTimeType.ending.name, time);
              }
            }
          },
        ),
      if (controller.currentItem?.downloadable ?? false)
        ListTile(
          title: Text(AppLocalizations.of(context)!.buttonDownload),
          onTap: () async {
            final item = controller.currentItem;
            if (item?.source is TVEpisode) {
              showNotification(
                context,
                Api.downloadTaskCreate((item!.source as TVEpisode).fileId),
                successText: AppLocalizations.of(context)!.tipsForDownload,
              );
            } else if (item?.source is Movie) {
              showNotification(
                context,
                Api.downloadTaskCreate((item!.source as Movie).fileId),
                successText: AppLocalizations.of(context)!.tipsForDownload,
              );
            }
          },
        ),
    ];
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
