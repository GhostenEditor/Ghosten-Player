import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../components/async_image.dart';
import '../../components/future_builder_handler.dart';
import '../../components/gap.dart';
import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../utils/player.dart';

class SystemSettingsPlayerHistory extends StatefulWidget {
  const SystemSettingsPlayerHistory({super.key});

  @override
  State<SystemSettingsPlayerHistory> createState() => _SystemSettingsPlayerHistoryState();
}

class _SystemSettingsPlayerHistoryState extends State<SystemSettingsPlayerHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsItemPlayerHistory)),
      body: FutureBuilderHandler(
        future: Api.playerHistory(),
        builder: (context, snapshot) {
          return snapshot.requireData.isEmpty
              ? const NoData()
              : ListView.builder(
                itemBuilder: (context, index) {
                  final item = snapshot.requireData[index];
                  return ListTile(
                    leading:
                        item.poster != null
                            ? AspectRatio(
                              aspectRatio: 1,
                              child: AsyncImage(item.poster!, radius: const BorderRadius.all(Radius.circular(4))),
                            )
                            : AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                                ),
                                child: const Icon(Icons.image_not_supported_outlined, size: 24),
                              ),
                            ),
                    title: Text(item.title, overflow: TextOverflow.ellipsis, maxLines: 2),
                    trailing:
                        item.duration > Duration.zero
                            ? SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                value: item.lastPlayedPosition.inMilliseconds / item.duration.inMilliseconds,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ),
                            )
                            : null,
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.labelSmall,
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(
                                    context,
                                  )!.timeAgo(item.lastPlayedTime.fromNow().fromNowFormat(context)),
                                ),
                                const WidgetSpan(child: Gap.hLG),
                                TextSpan(text: item.lastPlayedPosition.toDisplay()),
                                const TextSpan(text: ' / '),
                                TextSpan(text: item.duration.toDisplay()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      switch (item.mediaType) {
                        case MediaType.movie:
                          final movie = await Api.movieQueryById(item.id);
                          if (!context.mounted) return;
                          await toPlayer(context, [FromMedia.fromMovie(movie)], theme: movie.themeColor);
                          setState(() {});
                        case MediaType.episode:
                          final episode = await Api.tvEpisodeQueryById(item.id);
                          final season = await Api.tvSeasonQueryById(episode.seasonId);
                          if (!context.mounted) return;
                          await toPlayer(
                            context,
                            season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList(),
                            index: season.episodes.indexWhere((e) => episode.id == e.id),
                            theme: season.themeColor,
                          );
                          setState(() {});
                        default:
                      }
                    },
                  );
                },
                itemCount: snapshot.requireData.length,
              );
        },
      ),
    );
  }
}
