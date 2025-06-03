import 'dart:convert';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rxdart/rxdart.dart';

import '../components/async_image.dart';
import '../components/focus_card.dart';
import '../components/future_builder_handler.dart';
import '../components/stream_builder_handler.dart';
import '../l10n/app_localizations.dart';
import 'utils/notification.dart';
import 'utils/utils.dart';

class LibraryManage extends StatefulWidget {
  const LibraryManage({super.key, required this.type});

  final LibraryType type;

  @override
  State<LibraryManage> createState() => _LibraryManageState();
}

class _LibraryManageState extends State<LibraryManage> {
  bool _refresh = false;
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_refresh);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(switch (widget.type) {
            LibraryType.tv => AppLocalizations.of(context)!.settingsItemTV,
            LibraryType.movie => AppLocalizations.of(context)!.settingsItemMovie,
          }),
        ),
        body: Scrollbar(
          controller: _controller,
          child: CustomScrollView(
            controller: _controller,
            slivers: [
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  return StreamBuilderSliverHandler(
                    initialData: const <ScheduleTask>[],
                    stream: Stream.periodic(
                      const Duration(seconds: 1),
                    ).switchMap((_) => Stream.fromFuture(Api.scheduleTaskQueryByAll())),
                    builder:
                        (context, snapshot) => SliverList.builder(
                          itemCount: snapshot.requireData.length,
                          itemBuilder: (context, index) {
                            final item = snapshot.requireData[index];
                            return Slidable(
                              endActionPane: ActionPane(
                                extentRatio: (48 * 2) / constraints.crossAxisExtent,
                                motion: const BehindMotion(),
                                children: [
                                  if (item.status == ScheduleTaskStatus.running)
                                    IconButton(
                                      onPressed: () => Api.scheduleTaskPauseById(item.id),
                                      icon: const Icon(Icons.pause_rounded),
                                    ),
                                  if (item.status == ScheduleTaskStatus.paused)
                                    IconButton(
                                      onPressed: () => Api.scheduleTaskResumeById(item.id),
                                      icon: const Icon(Icons.pause_rounded),
                                    ),
                                  IconButton(
                                    onPressed: () => Api.scheduleTaskDeleteById(item.id),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                              child: Builder(
                                builder: (context) {
                                  final data = jsonDecode(item.data ?? '{}') as Json;
                                  return switch (item.type) {
                                    ScheduleTaskType.syncLibrary => ListTile(
                                      dense: true,
                                      title: Text(
                                        AppLocalizations.of(context)!.scheduleTaskSyncTitle(item.status.name),
                                      ),
                                      subtitle:
                                          data['files'] != null
                                              ? Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.scheduleTaskSyncSubtitle(data['files'].toString()),
                                              )
                                              : null,
                                      trailing: switch (item.status) {
                                        ScheduleTaskStatus.idle => const SizedBox(),
                                        ScheduleTaskStatus.running => const SizedBox.square(
                                          dimension: 12,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        ScheduleTaskStatus.paused => const Icon(Icons.pause_rounded),
                                        ScheduleTaskStatus.completed => Icon(
                                          Icons.check_rounded,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        ScheduleTaskStatus.error => Icon(
                                          Icons.error,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      },
                                      onTap: () {},
                                    ),
                                    ScheduleTaskType.scrapeLibrary => ListTile(
                                      dense: true,
                                      title: Text(
                                        AppLocalizations.of(context)!.scheduleTaskScrapeTitle(item.status.name),
                                      ),
                                      subtitle:
                                          data['progress'] != null
                                              ? Text('${((data['progress'] as double) * 100.0).toStringAsFixed(2)}%')
                                              : null,
                                      trailing: switch (item.status) {
                                        ScheduleTaskStatus.idle => null,
                                        ScheduleTaskStatus.running => SizedBox.square(
                                          dimension: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value: data['progress'] as double?,
                                          ),
                                        ),
                                        ScheduleTaskStatus.paused => const Icon(Icons.pause_rounded),
                                        ScheduleTaskStatus.completed => Icon(
                                          Icons.check_rounded,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        ScheduleTaskStatus.error => Icon(
                                          Icons.error,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      },
                                      onTap: () {},
                                    ),
                                  };
                                },
                              ),
                            );
                          },
                        ),
                  );
                },
              ),
              FutureBuilderSliverHandler<List<Library>>(
                future: Api.libraryQueryAll(widget.type),
                fillRemaining: true,
                builder:
                    (context, snapshot) => SliverPadding(
                      padding: const EdgeInsets.all(8),
                      sliver: SliverGrid.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240,
                          childAspectRatio: 1.25,
                        ),
                        itemCount: snapshot.requireData.length + 1,
                        itemBuilder: (context, index) {
                          if (index == snapshot.requireData.length) {
                            return FocusCard(
                              child: const Center(
                                child: IconButton.filledTonal(onPressed: null, icon: Icon(Icons.add)),
                              ),
                              onTap: () async {
                                final res = await showDriverFilePicker(context, switch (widget.type) {
                                  LibraryType.tv => AppLocalizations.of(context)!.pageTitleCreateTVLibrary,
                                  LibraryType.movie => AppLocalizations.of(context)!.pageTitleCreateMovieLibrary,
                                }, selectableType: FileType.folder);
                                if (res != null && context.mounted) {
                                  addLibrary(context, res.$1, res.$2);
                                }
                              },
                            );
                          } else {
                            final item = snapshot.requireData[index];
                            return _LibraryItem(
                              key: ValueKey(item.id),
                              item: item,
                              type: widget.type,
                              needUpdate: () => setState(() => _refresh = true),
                            );
                          }
                        },
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addLibrary(BuildContext context, int driverId, DriverFile file) async {
    final resp = await showNotification<bool>(
      context,
      Future(() async {
        final id = await Api.libraryInsert(
          type: widget.type,
          driverId: driverId,
          id: file.id,
          parentId: file.parentId,
          filename: file.name,
        );
        await Api.libraryRefreshById(id, false);
        return true;
      }),
    );
    if (resp?.data ?? false) {
      setState(() => _refresh = true);
    }
  }
}

class _LibraryItem extends StatelessWidget {
  const _LibraryItem({super.key, required this.item, required this.needUpdate, required this.type});

  final Library item;
  final VoidCallback needUpdate;
  final LibraryType type;

  @override
  Widget build(BuildContext context) {
    return FocusCard(
      itemBuilder:
          (context) => [
            PopupMenuItem(
              padding: EdgeInsets.zero,
              onTap:
                  () =>
                      showNotification(context, refreshMedia(context, item.id, incremental: true), showSuccess: false),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.sync),
                title: Text(AppLocalizations.of(context)!.buttonSyncLibrary),
              ),
            ),
            PopupMenuItem(
              padding: EdgeInsets.zero,
              onTap:
                  () =>
                      showNotification(context, refreshMedia(context, item.id, incremental: false), showSuccess: false),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.cloud_sync_rounded),
                title: Text(AppLocalizations.of(context)!.buttonScraperLibrary),
              ),
            ),
            PopupMenuItem(
              padding: EdgeInsets.zero,
              onTap: () async {
                final confirmed = await showConfirm(context, AppLocalizations.of(context)!.deleteMediaGroupConfirmText);
                if (confirmed ?? false) {
                  if (!context.mounted) return;
                  final resp = await showNotification(context, Api.libraryDeleteById(item.id));
                  if (resp?.error == null) needUpdate();
                }
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.delete_outline),
                title: Text(AppLocalizations.of(context)!.buttonDelete),
              ),
            ),
          ],
      child: Column(
        children: [
          Expanded(
            child:
                item.poster == null
                    ? Container(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(0x11),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 12,
                        children: [
                          switch (type) {
                            LibraryType.tv => const Icon(Icons.tv, size: 36),
                            LibraryType.movie => const Icon(Icons.movie_creation_outlined, size: 36),
                          },
                          Text(
                            item.filename,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                    : AsyncImage(item.poster!, ink: true),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child:
                      item.driverAvatar == null
                          ? const Icon(Icons.image_not_supported, size: 30)
                          : AsyncImage(item.driverAvatar!, width: 36, height: 36, radius: BorderRadius.circular(6)),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.driverName, overflow: TextOverflow.ellipsis),
                      Text(
                        AppLocalizations.of(context)!.driverType(item.driverType.name),
                        style: Theme.of(context).textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> refreshMedia(BuildContext context, dynamic id, {required bool incremental}) async {
    await Api.libraryRefreshById(id, incremental);
    needUpdate();
  }
}
