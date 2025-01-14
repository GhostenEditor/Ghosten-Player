import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../components/async_image.dart';
import '../../components/gap.dart';
import '../../components/no_data.dart';
import '../../models/models.dart';
import '../../providers/user_config.dart';
import '../../utils/utils.dart';
import '../components/icon_button.dart';
import '../components/setting.dart';
import '../utils/notification.dart';
import '../utils/player.dart';

class SystemSettingsDownloader extends StatelessWidget {
  const SystemSettingsDownloader({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingPage(
        title: AppLocalizations.of(context)!.settingsItemDownload,
        child: StreamBuilder(
            stream: ConcatStream([Stream.value(null), Stream.periodic(const Duration(seconds: 1))])
                .switchMap((_) => Stream.fromFuture(Api.downloadTaskQueryByAll())),
            builder: (context, snapshot) {
              final completeList = (snapshot.data ?? []).where((item) => item.status == DownloadTaskStatus.complete).toList();
              final notCompleteList = (snapshot.data ?? []).where((item) => item.status != DownloadTaskStatus.complete).toList();
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                      child: ListTile(
                          title: Text(AppLocalizations.of(context)!.downloaderLabelDownloading, style: Theme.of(context).textTheme.labelMedium), dense: true)),
                  notCompleteList.isEmpty
                      ? const SliverToBoxAdapter(child: NoData())
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          sliver: SliverList.builder(
                            itemCount: notCompleteList.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = notCompleteList[index];
                              return SlidableSettingItem(
                                key: ValueKey(item.id),
                                leading: AspectRatio(
                                  aspectRatio: 1,
                                  child: item.poster == null
                                      ? Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black12,
                                            borderRadius: BorderRadius.all(Radius.circular(4)),
                                          ),
                                          child: const Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 24,
                                          ),
                                        )
                                      : AsyncImage(
                                          item.poster!,
                                          radius: BorderRadius.circular(6),
                                          ink: true,
                                        ),
                                ),
                                trailing: SizedBox.square(
                                  dimension: 28,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: item.status == DownloadTaskStatus.downloading ? item.progress : (item.progress ?? 0),
                                        color: switch (item.status) {
                                          DownloadTaskStatus.idle => Theme.of(context).colorScheme.secondary,
                                          DownloadTaskStatus.downloading => Theme.of(context).colorScheme.primary,
                                          DownloadTaskStatus.complete => throw UnimplementedError(),
                                          DownloadTaskStatus.failed => Theme.of(context).colorScheme.error,
                                        },
                                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      ),
                                      Builder(
                                          builder: (context) => IconTheme(
                                              data: IconTheme.of(context).copyWith(size: 16),
                                              child: switch (item.status) {
                                                DownloadTaskStatus.idle => const Icon(Icons.pause),
                                                DownloadTaskStatus.downloading => const Icon(Icons.download_rounded),
                                                DownloadTaskStatus.complete => throw UnimplementedError(),
                                                DownloadTaskStatus.failed => const Icon(Icons.close),
                                              }))
                                    ],
                                  ),
                                ),
                                title: Text(item.title),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item.createdAt.formatFullWithoutSec()),
                                        Text(item.size.toSizeDisplay()),
                                      ],
                                    ),
                                    Row(children: [
                                      if (item.speed != null) Text(item.speed!.toNetworkSpeed()),
                                      if (item.speed != null) Gap.hSM,
                                      Text(item.elapsed.toDisplay()),
                                      if (item.speed != null) const Text('/'),
                                      if (item.speed != null)
                                        Text(Duration(seconds: (item.size / item.speed! * (1 - (item.progress ?? 0))).toInt()).toDisplay()),
                                    ]),
                                  ],
                                ),
                                actions: [
                                  TVIconButton(icon: const Icon(Icons.play_arrow_rounded), onPressed: () => play(context, item.mediaType, item.mediaId)),
                                  if (item.status == DownloadTaskStatus.idle)
                                    TVIconButton(
                                        icon: const Icon(Icons.downloading_rounded),
                                        onPressed: () {
                                          final playerConfig = Provider.of<UserConfig>(navigatorKey.currentContext!, listen: false).playerConfig;
                                          Api.downloadTaskResumeById(
                                            item.id,
                                            parallels: playerConfig.enableParallel ? playerConfig.parallels : null,
                                            size: playerConfig.enableParallel ? playerConfig.sliceSize : null,
                                          );
                                        }),
                                  if (item.status == DownloadTaskStatus.downloading)
                                    TVIconButton(icon: const Icon(Icons.pause_rounded), onPressed: () => Api.downloadTaskPauseById(item.id)),
                                  TVIconButton(
                                      icon: const Icon(Icons.delete_outline_outlined),
                                      onPressed: () => showNotification(context, Api.downloadTaskDeleteById(item.id))),
                                ],
                              );
                            },
                          ),
                        ),
                  SliverToBoxAdapter(
                      child: ListTile(
                          title: Text(AppLocalizations.of(context)!.downloaderLabelDownloaded, style: Theme.of(context).textTheme.labelMedium), dense: true)),
                  completeList.isEmpty
                      ? const SliverToBoxAdapter(child: NoData())
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          sliver: SliverList.builder(
                            itemCount: completeList.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = completeList[index];
                              return SlidableSettingItem(
                                leading: AspectRatio(
                                  aspectRatio: 1,
                                  child: item.poster == null
                                      ? Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black12,
                                            borderRadius: BorderRadius.all(Radius.circular(4)),
                                          ),
                                          child: const Icon(
                                            Icons.image_not_supported_outlined,
                                            size: 24,
                                          ),
                                        )
                                      : AsyncImage(
                                          item.poster!,
                                          radius: BorderRadius.circular(6),
                                          ink: true,
                                        ),
                                ),
                                title: Text(item.title),
                                subtitle: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item.createdAt.formatFullWithoutSec()),
                                        Text(item.size.toSizeDisplay()),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (item.elapsed != Duration.zero) Text((item.size ~/ item.elapsed.inSeconds).toNetworkSpeed()),
                                        Text(item.elapsed.toDisplay()),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  TVIconButton(
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    onPressed: () => play(context, item.mediaType, item.mediaId),
                                  ),
                                  TVIconButton(
                                    icon: const Icon(Icons.delete_outline_outlined),
                                    onPressed: () async {
                                      final confirmed = await showConfirm(context, AppLocalizations.of(context)!.downloaderDeleteFileConfirmText);
                                      if (confirmed != null && context.mounted) {
                                        await showNotification(context, Api.downloadTaskDeleteById(item.id, deleteFile: confirmed));
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 12)),
                ],
              );
            }));
  }

  play(BuildContext context, MediaType mediaType, int id) async {
    switch (mediaType) {
      case MediaType.movie:
        final movie = await Api.movieQueryById(id);
        if (!context.mounted) return;
        await toPlayer(
          navigatorKey.currentContext!,
          [FromMedia.fromMovie(movie)],
          theme: movie.themeColor,
          playerType: PlayerType.movie,
        );
      case MediaType.episode:
        final episode = await Api.tvEpisodeQueryById(id);
        final season = await Api.tvSeasonQueryById(episode.seasonId);
        if (!context.mounted) return;
        await toPlayer(
          navigatorKey.currentContext!,
          season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList(),
          playerType: PlayerType.tv,
          id: episode.id,
          theme: season.themeColor,
        );
      default:
    }
  }
}
