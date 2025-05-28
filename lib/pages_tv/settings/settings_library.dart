import 'dart:convert';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../components/async_image.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../components/future_builder_handler.dart';
import '../components/icon_button.dart';
import '../components/setting.dart';
import '../components/stream_builder_handler.dart';
import '../utils/driver_file_picker.dart';
import '../utils/notification.dart';

class LibraryManage extends StatefulWidget {
  const LibraryManage({super.key, required this.title, required this.type});

  final String title;
  final LibraryType type;

  @override
  State<LibraryManage> createState() => _LibraryManageState();
}

class _LibraryManageState extends State<LibraryManage> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: widget.title,
      child: CustomScrollView(
        slivers: [
          StreamBuilderSliverHandler(
            initialData: const <ScheduleTask>[],
            stream: Stream.periodic(
              const Duration(seconds: 1),
            ).switchMap((_) => Stream.fromFuture(Api.scheduleTaskQueryByAll())),
            builder:
                (context, snapshot) =>
                    snapshot.requireData.isNotEmpty
                        ? SliverMainAxisGroup(
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.all(12),
                              sliver: SliverList.builder(
                                itemCount: snapshot.requireData.length,
                                itemBuilder: (context, index) {
                                  final item = snapshot.requireData[index];
                                  final data = jsonDecode(item.data ?? '{}') as Json;
                                  return SlidableSettingItem(
                                    actions: [
                                      if (item.status == ScheduleTaskStatus.running)
                                        TVIconButton(
                                          onPressed: () => Api.scheduleTaskPauseById(item.id),
                                          icon: const Icon(Icons.pause_rounded),
                                        ),
                                      if (item.status == ScheduleTaskStatus.paused)
                                        TVIconButton(
                                          onPressed: () => Api.scheduleTaskResumeById(item.id),
                                          icon: const Icon(Icons.pause_rounded),
                                        ),
                                      TVIconButton(
                                        onPressed: () => Api.scheduleTaskDeleteById(item.id),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                    title: switch (item.type) {
                                      ScheduleTaskType.syncLibrary => Text(
                                        AppLocalizations.of(context)!.scheduleTaskSyncTitle(item.status.name),
                                      ),
                                      ScheduleTaskType.scrapeLibrary => Text(
                                        AppLocalizations.of(context)!.scheduleTaskScrapeTitle(item.status.name),
                                      ),
                                    },
                                    subtitle: switch (item.type) {
                                      ScheduleTaskType.syncLibrary =>
                                        data['files'] != null
                                            ? Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.scheduleTaskSyncSubtitle(data['files'].toString()),
                                            )
                                            : null,
                                      ScheduleTaskType.scrapeLibrary =>
                                        data['progress'] != null
                                            ? Text('${((data['progress'] as double) * 100.0).toStringAsFixed(2)}%')
                                            : null,
                                    },
                                    trailing: switch (item.type) {
                                      ScheduleTaskType.syncLibrary => switch (item.status) {
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
                                      ScheduleTaskType.scrapeLibrary => switch (item.status) {
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
                                    },
                                  );
                                },
                              ),
                            ),
                            const SliverToBoxAdapter(child: DividerSettingItem()),
                          ],
                        )
                        : const SliverToBoxAdapter(),
          ),
          FutureBuilderSliverHandler<List<Library>>(
            initialData: const [],
            future: Api.libraryQueryAll(widget.type),
            builder: (context, snapshot) {
              return SliverPadding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverList.builder(
                      itemCount: snapshot.requireData.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.requireData[index];
                        return SlidableSettingItem(
                          autofocus: index == 0,
                          title: Text(item.filename),
                          leading: AspectRatio(
                            aspectRatio: 1,
                            child:
                                item.poster == null
                                    ? Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius: BorderRadius.all(Radius.circular(4)),
                                      ),
                                      child: const Icon(Icons.image_not_supported_outlined, size: 24),
                                    )
                                    : AsyncImage(item.poster!, radius: BorderRadius.circular(6), ink: true),
                          ),
                          subtitle: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Text(AppLocalizations.of(context)!.driverType(item.driverType.name)),
                              Text(item.driverName, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          actions: [
                            TVIconButton(
                              icon: const Icon(Icons.sync),
                              onPressed:
                                  () => showNotification(
                                    context,
                                    Api.libraryRefreshById(item.id, true),
                                    showSuccess: false,
                                  ),
                            ),
                            TVIconButton(
                              icon: const Icon(Icons.cloud_sync_rounded),
                              onPressed:
                                  () => showNotification(
                                    context,
                                    Api.libraryRefreshById(item.id, false),
                                    showSuccess: false,
                                  ),
                            ),
                            TVIconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final confirmed = await showConfirm(
                                  context,
                                  AppLocalizations.of(context)!.deleteConfirmText,
                                  AppLocalizations.of(context)!.deleteMediaGroupConfirmText,
                                );
                                if (confirmed ?? false) {
                                  if (!context.mounted) return;
                                  final resp = await showNotification(context, Api.libraryDeleteById(item.id));
                                  if (resp?.error == null && context.mounted) {
                                    setState(() {});
                                  }
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    if (snapshot.requireData.isNotEmpty) const SliverToBoxAdapter(child: DividerSettingItem()),
                    const SliverToBoxAdapter(child: GapSettingItem(height: 12)),
                    SliverToBoxAdapter(
                      child: IconButtonSettingItem(
                        icon: const Icon(Icons.add),
                        autofocus: snapshot.requireData.isEmpty,
                        onPressed: () async {
                          final resp = await navigateTo(
                            navigatorKey.currentContext!,
                            const DriverFilePicker(selectableType: FileType.folder),
                          );
                          if (context.mounted && resp is (int, DriverFile)) {
                            _addLibrary(context, resp.$1, resp.$2);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addLibrary(BuildContext context, int driverId, DriverFile file) async {
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
      setState(() {});
    }
  }
}
