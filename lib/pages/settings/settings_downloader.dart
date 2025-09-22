import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../components/async_image.dart';
import '../../components/focus_card.dart';
import '../../components/gap.dart';
import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../utils/notification.dart';
import '../utils/player.dart';

class SystemSettingsDownloader extends StatefulWidget {
  const SystemSettingsDownloader({super.key});

  @override
  State<SystemSettingsDownloader> createState() => _SystemSettingsDownloaderState();
}

class _SystemSettingsDownloaderState extends State<SystemSettingsDownloader> {
  final _stream = ConcatStream([
    Stream.value(null),
    Stream.periodic(const Duration(seconds: 1)),
  ]).switchMap((_) => Stream.fromFuture(Api.downloadTaskQueryByAll()));
  StreamSubscription<List<DownloadTask>>? _subscription;
  List<DownloadTask> _completeList = [];
  List<DownloadTask> _notCompleteList = [];

  @override
  void initState() {
    super.initState();
    _subscription = _stream.listen((data) {
      _completeList = data.where((item) => item.status == DownloadTaskStatus.complete).toList();
      _notCompleteList = data.where((item) => item.status != DownloadTaskStatus.complete).toList();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsItemDownload)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(
                AppLocalizations.of(context)!.downloaderLabelDownloading,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              dense: true,
            ),
          ),
          if (_notCompleteList.isEmpty)
            const SliverToBoxAdapter(child: NoData())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  childAspectRatio: 0.75,
                ),
                itemCount: _notCompleteList.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = _notCompleteList[index];
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
                              if (item.poster != null)
                                Container(color: Theme.of(context).colorScheme.surface.withAlpha(0x99)),
                              Center(
                                child: SizedBox.square(
                                  dimension: 60,
                                  child: CircularProgressIndicator(
                                    value:
                                        item.status == DownloadTaskStatus.downloading
                                            ? item.progress
                                            : (item.progress ?? 0),
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
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: ' ${(item.progress! * 100).toStringAsFixed(1)}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(text: ' %', style: Theme.of(context).textTheme.labelSmall),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
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
                                    Text(
                                      item.createdAt.formatFullWithoutSec(),
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
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
                                      text: TextSpan(
                                        children: [
                                          if (item.speed != null) TextSpan(text: item.speed!.toNetworkSpeed()),
                                          if (item.speed != null) const WidgetSpan(child: Gap.hSM),
                                          if (item.speed != null)
                                            TextSpan(
                                              text:
                                                  Duration(
                                                    seconds:
                                                        (item.size / item.speed! * (1 - (item.progress ?? 0))).toInt(),
                                                  ).toDisplay(),
                                              style: Theme.of(context).textTheme.labelSmall,
                                            ),
                                          if (item.speed != null) const TextSpan(text: ' / '),
                                          TextSpan(text: item.elapsed.toDisplay()),
                                        ],
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            padding: EdgeInsets.zero,
                            onTap: () => _play(context, item.mediaType, item.mediaId),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              leading: const Icon(Icons.play_arrow_rounded),
                              title: Text(AppLocalizations.of(context)!.buttonPlay),
                            ),
                          ),
                          if (item.status == DownloadTaskStatus.idle)
                            PopupMenuItem(
                              padding: EdgeInsets.zero,
                              onTap: () => Api.downloadTaskResumeById(item.id),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                leading: const Icon(Icons.downloading_rounded),
                                title: Text(AppLocalizations.of(context)!.buttonResume),
                              ),
                            ),
                          if (item.status == DownloadTaskStatus.downloading)
                            PopupMenuItem(
                              padding: EdgeInsets.zero,
                              onTap: () => Api.downloadTaskPauseById(item.id),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                leading: const Icon(Icons.pause_rounded),
                                title: Text(AppLocalizations.of(context)!.buttonPause),
                              ),
                            ),
                          PopupMenuItem(
                            padding: EdgeInsets.zero,
                            onTap: () => showNotification(context, Api.downloadTaskDeleteById(item.id)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              leading: const Icon(Icons.delete_outline_outlined),
                              title: Text(AppLocalizations.of(context)!.buttonDelete),
                            ),
                          ),
                        ],
                  );
                },
              ),
            ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(
                AppLocalizations.of(context)!.downloaderLabelDownloaded,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              dense: true,
            ),
          ),
          if (_completeList.isEmpty)
            const SliverToBoxAdapter(child: NoData())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  childAspectRatio: 0.78,
                ),
                itemCount: _completeList.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = _completeList[index];
                  return FocusCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child:
                              item.poster != null
                                  ? AsyncImage(item.poster!, ink: true)
                                  : ColoredBox(
                                    color: Theme.of(context).colorScheme.onSurface.withAlpha(0x11),
                                    child: const Icon(Icons.image_not_supported_outlined, size: 42),
                                  ),
                        ),
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
                                    Text(
                                      item.createdAt.formatFullWithoutSec(),
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    Text(item.size.toSizeDisplay(), style: Theme.of(context).textTheme.labelSmall),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (item.elapsed != Duration.zero)
                                      Text(
                                        (item.size ~/ item.elapsed.inSeconds).toNetworkSpeed(),
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    Text(item.elapsed.toDisplay(), style: Theme.of(context).textTheme.labelSmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            padding: EdgeInsets.zero,
                            onTap: () => _play(context, item.mediaType, item.mediaId),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              leading: const Icon(Icons.play_arrow_rounded),
                              title: Text(AppLocalizations.of(context)!.buttonPlay),
                            ),
                          ),
                          PopupMenuItem(
                            padding: EdgeInsets.zero,
                            onTap: () async {
                              final confirmed = await showConfirm(
                                context,
                                AppLocalizations.of(context)!.downloaderDeleteFileConfirmText,
                              );
                              if (confirmed != null && context.mounted) {
                                await showNotification(
                                  context,
                                  Api.downloadTaskDeleteById(item.id, deleteFile: confirmed),
                                );
                              }
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              leading: const Icon(Icons.delete_outline_outlined),
                              title: Text(AppLocalizations.of(context)!.buttonDelete),
                            ),
                          ),
                        ],
                  );
                },
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 12)),
        ],
      ),
    );
  }

  Future<void> _play(BuildContext context, MediaType mediaType, dynamic id) async {
    switch (mediaType) {
      case MediaType.movie:
        final movie = await Api.movieQueryById(id);
        if (!context.mounted) return;
        _subscription?.pause();
        await toPlayer(context, [FromMedia.fromMovie(movie)], theme: movie.themeColor);
        _subscription?.resume();
      case MediaType.episode:
        final episode = await Api.tvEpisodeQueryById(id);
        final season = await Api.tvSeasonQueryById(episode.seasonId);
        if (!context.mounted) return;
        _subscription?.pause();
        await toPlayer(
          context,
          season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList(),
          index: season.episodes.indexWhere((e) => episode.id == e.id),
          theme: season.themeColor,
        );
        _subscription?.resume();
      default:
    }
  }
}
