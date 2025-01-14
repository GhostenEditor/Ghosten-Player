import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/async_image.dart';
import '../../models/models.dart';
import '../../utils/player.dart';
import '../../utils/utils.dart';
import '../components/future_builder_handler.dart';
import '../components/setting.dart';

class SystemSettingsPlayerHistory extends StatefulWidget {
  const SystemSettingsPlayerHistory({super.key});

  @override
  State<SystemSettingsPlayerHistory> createState() => _SystemSettingsPlayerHistoryState();
}

class _SystemSettingsPlayerHistoryState extends State<SystemSettingsPlayerHistory> {
  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemPlayerHistory,
      child: FutureBuilderHandler(
          future: Api.playerHistory(),
          builder: (context, snapshot) {
            return ListView(padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32), children: [
              ...snapshot.requireData.indexed.map((entry) => ButtonSettingItem(
                    autofocus: entry.$1 == 0,
                    leading: entry.$2.poster != null
                        ? AspectRatio(
                            aspectRatio: 1,
                            child: AsyncImage(
                              entry.$2.poster!,
                              radius: const BorderRadius.all(Radius.circular(4)),
                              ink: true,
                            ),
                          )
                        : AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 24,
                              ),
                            ),
                          ),
                    title: Text(entry.$2.title, overflow: TextOverflow.ellipsis, maxLines: 2),
                    subtitle: Row(
                      children: [
                        Text(AppLocalizations.of(context)!.timeAgo(entry.$2.lastPlayedTime.fromNow().fromNowFormat(context))),
                        const Spacer(),
                        Text(entry.$2.lastPlayedPosition.toDisplay()),
                        const Text(' / '),
                        Text(entry.$2.duration.toDisplay()),
                      ],
                    ),
                    trailing: entry.$2.duration > Duration.zero
                        ? SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              value: entry.$2.lastPlayedPosition.inMilliseconds / entry.$2.duration.inMilliseconds,
                              backgroundColor: Colors.black,
                            ))
                        : null,
                    onTap: () async {
                      switch (entry.$2.mediaType) {
                        case MediaType.movie:
                          final movie = await Api.movieQueryById(entry.$2.id);
                          if (!context.mounted) return;
                          await toPlayer(
                            navigatorKey.currentContext!,
                            [FromMedia.fromMovie(movie)],
                            theme: movie.themeColor,
                            playerType: PlayerType.movie,
                          );
                          setState(() {});
                        case MediaType.episode:
                          final episode = await Api.tvEpisodeQueryById(entry.$2.id);
                          final season = await Api.tvSeasonQueryById(episode.seasonId);
                          if (!context.mounted) return;
                          await toPlayer(
                            navigatorKey.currentContext!,
                            season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList(),
                            playerType: PlayerType.tv,
                            id: episode.id,
                            theme: season.themeColor,
                          );
                          setState(() {});
                        default:
                      }
                    },
                  ))
            ]);
          }),
    );
  }
}
