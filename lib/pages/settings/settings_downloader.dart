import 'package:api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PopupMenuItem;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rxdart/rxdart.dart';

import '../../components/async_image.dart';
import '../../components/focus_card.dart';
import '../../components/gap.dart';
import '../../components/no_data.dart';
import '../../components/popup_menu.dart';
import '../../models/models.dart';
import '../../utils/notification.dart';
import '../../utils/player.dart';
import '../../utils/utils.dart';

class SystemSettingsDownloader extends StatelessWidget {
  const SystemSettingsDownloader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Badge(label: const Text('Beta'), child: Text(AppLocalizations.of(context)!.settingsItemDownload))),
      body: StreamBuilder(
          stream:
              ConcatStream([Stream.value(null), Stream.periodic(const Duration(seconds: 1))]).switchMap((_) => Stream.fromFuture(Api.downloadTaskQueryByAll())),
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
                        sliver: SliverGrid.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 280, childAspectRatio: 0.75),
                          itemCount: notCompleteList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = notCompleteList[index];
                            return FocusCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AspectRatio(
                                      aspectRatio: 1,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          if (item.poster != null) AsyncImage(item.poster!, ink: true),
                                          if (item.poster != null) Container(color: Theme.of(context).colorScheme.surface.withAlpha(0x99)),
                                          Center(
                                            child: SizedBox.square(
                                              dimension: 60,
                                              child: CircularProgressIndicator(
                                                value: item.status == DownloadTaskStatus.downloading ? item.progress : (item.progress ?? 0),
                                                color: switch (item.status) {
                                                  DownloadTaskStatus.idle => Theme.of(context).colorScheme.secondary,
                                                  DownloadTaskStatus.downloading => Theme.of(context).colorScheme.primary,
                                                  DownloadTaskStatus.complete => throw UnimplementedError(),
                                                  DownloadTaskStatus.failed => Theme.of(context).colorScheme.error,
                                                },
                                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                strokeWidth: 6,
                                              ),
                                            ),
                                          ),
                                          if (item.progress != null)
                                            Center(
                                              child: RichText(
                                                text: TextSpan(children: [
                                                  TextSpan(
                                                      text: ' ${(item.progress! * 100).toStringAsFixed(1)}',
                                                      style: Theme.of(context).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold)),
                                                  TextSpan(text: ' %', style: Theme.of(context).textTheme.labelSmall),
                                                ]),
                                              ),
                                            ),
                                        ],
                                      )),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(item.title, overflow: TextOverflow.ellipsis),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(item.createdAt.formatFullWithoutSec(), style: Theme.of(context).textTheme.labelSmall),
                                              Text(item.size.toSizeDisplay(), style: Theme.of(context).textTheme.labelSmall),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              switch (item.status) {
                                                DownloadTaskStatus.idle => const Icon(Icons.play_arrow_rounded),
                                                DownloadTaskStatus.downloading => const Icon(Icons.pause),
                                                DownloadTaskStatus.complete => throw UnimplementedError(),
                                                DownloadTaskStatus.failed => const Icon(Icons.close),
                                              },
                                              const Spacer(),
                                              RichText(
                                                  text: TextSpan(children: [
                                                if (item.speed != null) TextSpan(text: item.speed!.toNetworkSpeed()),
                                                if (item.speed != null) const WidgetSpan(child: Gap.hSM),
                                                if (item.speed != null)
                                                  TextSpan(
                                                      text: Duration(seconds: (item.size / item.speed! * (1 - (item.progress ?? 0))).toInt()).toDisplay(),
                                                      style: Theme.of(context).textTheme.labelSmall),
                                                if (item.speed != null) const TextSpan(text: ' / '),
                                                TextSpan(text: item.elapsed.toDisplay()),
                                              ], style: Theme.of(context).textTheme.labelSmall))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  autofocus: kIsAndroidTV,
                                  leading: const Icon(Icons.play_arrow_rounded),
                                  title: Text(AppLocalizations.of(context)!.buttonPlay),
                                  onTap: () => play(context, item.mediaType, item.mediaId),
                                ),
                                if (item.status == DownloadTaskStatus.idle)
                                  PopupMenuItem(
                                    autofocus: kIsAndroidTV,
                                    leading: const Icon(Icons.downloading_rounded),
                                    title: Text(AppLocalizations.of(context)!.buttonResume),
                                    onTap: () => Api.downloadTaskResumeById(item.id),
                                  ),
                                if (item.status == DownloadTaskStatus.downloading)
                                  PopupMenuItem(
                                    autofocus: kIsAndroidTV,
                                    leading: const Icon(Icons.pause_rounded),
                                    title: Text(AppLocalizations.of(context)!.buttonPause),
                                    onTap: () => Api.downloadTaskPauseById(item.id),
                                  ),
                                PopupMenuItem(
                                  leading: const Icon(Icons.delete_outline_outlined),
                                  title: Text(AppLocalizations.of(context)!.buttonDelete),
                                  onTap: () => showNotification(context, Api.downloadTaskDeleteById(item.id)),
                                ),
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
                        sliver: SliverGrid.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 280, childAspectRatio: 0.78),
                          itemCount: completeList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = completeList[index];
                            return FocusCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AspectRatio(
                                      aspectRatio: 1,
                                      child: item.poster != null
                                          ? AsyncImage(item.poster!, ink: true)
                                          : Container(
                                              color: Theme.of(context).colorScheme.onSurface.withAlpha(0x11),
                                              child: const Icon(
                                                Icons.image_not_supported_outlined,
                                                size: 42,
                                              ),
                                            )),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(item.title, overflow: TextOverflow.ellipsis),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(item.createdAt.formatFullWithoutSec(), style: Theme.of(context).textTheme.labelSmall),
                                              Text(item.size.toSizeDisplay(), style: Theme.of(context).textTheme.labelSmall),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (item.elapsed != Duration.zero)
                                                Text((item.size ~/ item.elapsed.inSeconds).toNetworkSpeed(), style: Theme.of(context).textTheme.labelSmall),
                                              Text(item.elapsed.toDisplay(), style: Theme.of(context).textTheme.labelSmall),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              onTap: () {
                                switch (item.status) {
                                  case DownloadTaskStatus.idle:
                                    Api.downloadTaskResumeById(item.id);
                                  case DownloadTaskStatus.downloading:
                                    Api.downloadTaskPauseById(item.id);
                                  default:
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  autofocus: kIsAndroidTV,
                                  leading: const Icon(Icons.play_arrow_rounded),
                                  title: Text(AppLocalizations.of(context)!.buttonPlay),
                                  onTap: () => play(context, item.mediaType, item.mediaId),
                                ),
                                PopupMenuItem(
                                  leading: const Icon(Icons.delete_outline_outlined),
                                  title: Text(AppLocalizations.of(context)!.buttonDelete),
                                  onTap: () async {
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
          }),
    );
  }

  play(BuildContext context, MediaType mediaType, int id) async {
    switch (mediaType) {
      case MediaType.movie:
        final movie = await Api.movieQueryById(id);
        if (!context.mounted) return;
        await toPlayer(
          context,
          [FromMedia.fromMovie(movie)],
          theme: movie.themeColor,
          playerType: PlayerType.movie,
        );
      case MediaType.episode:
        final episode = await Api.tvEpisodeQueryById(id);
        final season = await Api.tvSeasonQueryById(episode.seasonId);
        if (!context.mounted) return;
        await toPlayer(
          context,
          season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList(),
          playerType: PlayerType.tv,
          id: episode.id,
          theme: season.themeColor,
        );
      default:
    }
  }
}
