import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../components/async_image.dart';
import '../components/focus_card.dart';
import '../components/future_builder_handler.dart';
import '../providers/user_config.dart';
import 'components/appbar_progress.dart';
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
            bottom: const AppbarProgressIndicator(),
          ),
          body: FutureBuilderHandler<List<Library>>(
            initialData: const [],
            future: Api.libraryQueryAll(widget.type),
            builder: (context, snapshot) => Scrollbar(
              controller: _controller,
              child: GridView.builder(
                controller: _controller,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 240, childAspectRatio: 1.25),
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.requireData.length + 1,
                itemBuilder: (context, index) {
                  if (index == snapshot.requireData.length) {
                    return FocusCard(
                      child: const Center(
                        child: IconButton.filledTonal(
                          onPressed: null,
                          icon: Icon(Icons.add),
                        ),
                      ),
                      onTap: () async {
                        final res = await showDriverFilePicker(
                            context,
                            switch (widget.type) {
                              LibraryType.tv => AppLocalizations.of(context)!.pageTitleCreateTVLibrary,
                              LibraryType.movie => AppLocalizations.of(context)!.pageTitleCreateMovieLibrary,
                            },
                            selectableType: FileType.folder);
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
          )),
    );
  }

  Future<void> addLibrary(BuildContext context, int driverId, DriverFile file) async {
    final scraperBehavior = Provider.of<UserConfig>(context, listen: false).scraperBehavior;
    final resp = await showNotification<bool>(context, Future(() async {
      final id = await Api.libraryInsert(
        type: widget.type,
        driverId: driverId,
        id: file.id,
        parentId: file.parentId,
        filename: file.name,
      );
      await Api.libraryRefreshById(id, false, scraperBehavior);
      return true;
    }));
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
      itemBuilder: (context) => [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          onTap: () => showNotification(context, refreshMedia(context, item.id, incremental: false), showSuccess: false),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(Icons.sync),
            title: Text(AppLocalizations.of(context)!.buttonSyncLibrary),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          onTap: () => showNotification(context, refreshMedia(context, item.id, incremental: true), showSuccess: false),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(Icons.cloud_sync_rounded),
            title: Text(AppLocalizations.of(context)!.buttonIncrementalSyncLibrary),
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
        )
      ],
      child: Column(
        children: [
          Expanded(
            child: item.poster == null
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
                  child: item.driverAvatar == null
                      ? const Icon(Icons.image_not_supported, size: 30)
                      : AsyncImage(item.driverAvatar!, width: 36, height: 36, radius: BorderRadius.circular(6)),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.driverName, overflow: TextOverflow.ellipsis),
                      Text(AppLocalizations.of(context)!.driverType(item.driverType.name),
                          style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis),
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

  Future<void> refreshMedia(BuildContext context, int id, {required bool incremental}) async {
    await Api.libraryRefreshById(
      id,
      incremental,
      Provider.of<UserConfig>(context, listen: false).scraperBehavior,
    );
    needUpdate();
  }
}
