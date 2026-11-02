import 'package:api/api.dart' hide PageData;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter/services.dart';
import 'package:video_player/player.dart';

import '../adaptive/adaptive.dart';
import '../components/components.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../utils/utils.dart';
import 'abstract.dart';

class StorageMenu extends Menu {
  const StorageMenu(this.item);

  final Storage item;

  @override
  List<Widget> build(BuildContext context) {
    return [
      ListTile(
        onTap: () => _showFilePicker(context, FilePickerType.remote, item.id, '/'),
        title: Text(AppLocalizations.of(context)!.pageTitleFileViewer),
        leading: const Icon(Icons.folder_outlined),
      ),
      if (item.type != DriverType.webdav)
        ListTile(
          title: Text(AppLocalizations.of(context)!.buttonEdit),
          onTap: () => context.pushNamed(.settingsStoragePreference, arguments: item),
          leading: const Icon(Icons.edit_outlined),
        ),
      ListTile(
        onTap: () async {
          final bool? flag = await showConfirm(
            context,
            AppLocalizations.of(context)!.deleteAccountConfirmText,
            AppLocalizations.of(context)!.deleteAccountTip,
          );
          if ((flag ?? false) && context.mounted) {
            await showNotification(context, Api.storageDeleteById(item.id));
          }
        },
        title: Text(AppLocalizations.of(context)!.buttonDelete),
        leading: const Icon(Icons.delete_outline_rounded),
      ),
    ];
  }

  Future<DriverFile?> _showFilePicker(
    BuildContext context,
    FilePickerType type,
    int driverId,
    String defaultPath,
  ) async {
    final controller = FileViewerController<DriverFile>();
    final DriverFile? file = await FilePicker.showFilePicker(
      context,
      controller: controller,
      type: type,
      contentPadding: SettingPageTheme.of(context).contentPadding!,
      defaultTitle: Text(AppLocalizations.of(context)!.pageTitleFileViewer),
      actions: [
        PopupMenuButton(
          offset: const Offset(1, 0),
          tooltip: '',
          itemBuilder: (context) => [
            PopupMenuItem(
              padding: EdgeInsets.zero,
              onTap: () async {
                final String? filename = await context.pushNamed<String>(
                  .fileRename,
                  arguments: {'dialogTitle': AppLocalizations.of(context)!.buttonNewFolder},
                );
                if (filename != null && context.mounted) {
                  final AsyncSnapshot<void>? resp = await showNotification(
                    context,
                    Api.fileMkdir(driverId, controller.currentItem.value?.id ?? defaultPath, filename),
                  );
                  if (resp?.error == null) {
                    controller.refresh();
                  }
                }
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.folder_open_rounded),
                title: Text(AppLocalizations.of(context)!.buttonNewFolder),
              ),
            ),
          ],
        ),
      ],
      titleBuilder: (item) => Text(item?.name ?? 'Home'),
      firstPageErrorIndicatorBuilder: (_) => Center(child: ErrorMessage(error: controller.error)),
      noItemsFoundIndicatorBuilder: (_) => const NoData(),
      fetchData: (index) async {
        final List<DriverFile> items = await Api.fileList(driverId, controller.currentItem.value?.id ?? defaultPath);
        return PageData(items: items, count: items.length, limit: 99999999);
      },
      itemBuilder: (context, item, index) => _FileViewer(
        item: item,
        onRefresh: controller.refresh,
        onPage: () => controller.nextPage(item),
        onRemove: () => Api.fileRemove(driverId, item.id),
        onRename: (filename) => Api.fileRename(driverId, item.id, filename),
      ),
    );
    controller.dispose();
    return file;
  }
}

class _FileViewer extends StatelessWidget {
  const _FileViewer({
    required this.item,
    required this.onPage,
    required this.onRefresh,
    required this.onRename,
    required this.onRemove,
  });

  final DriverFile item;
  final VoidCallback onPage;
  final VoidCallback onRefresh;

  final Future<void> Function(String) onRename;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    return Focus(
      skipTraversal: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyUpEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowLeft:
              _showMenu(context);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight:
              onPage();
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: ListTile(
        dense: true,
        leading: Icon(item.icon()),
        title: Text(item.name, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          spacing: 12,
          children: [
            if (item.updatedAt != null) Text(item.updatedAt!.formatFull()),
            if (item.type == FileType.file && item.size != null) Text(item.size!.toSizeDisplay()),
          ],
        ),
        trailing: item.type == FileType.folder ? const Icon(Icons.chevron_right) : null,
        onTap: item.type == FileType.file ? () => _play(context) : onPage,
        onLongPress: () => _showMenu(context),
      ),
    );
  }

  Future<void> _play(BuildContext context) async {
    switch (item.category) {
      case FileCategory.image:
        await context.pushNamed(.imageViewer, arguments: {'url': item.url!.normalize(), 'title': item.name});
      case FileCategory.video:
        await context.pushNamed(
          .player,
          arguments: PlaylistData(
            playlist: [
              PlaylistItem(
                url: item.url?.normalize(),
                title: item.name,
                description: item.updatedAt?.format(),
                source: item,
              ),
            ],
          ),
        );
      default:
    }
  }

  String _getCategory(BuildContext context) {
    if (item.type == FileType.folder) {
      return AppLocalizations.of(context)!.fileCategory('folder');
    } else {
      final String ext = item.name.split('.').lastOrNull?.toUpperCase() ?? '';
      return switch (item.category) {
        null || FileCategory.other => AppLocalizations.of(context)!.fileCategory(FileCategory.other.name),
        _ => '$ext ${AppLocalizations.of(context)!.fileCategory(item.category!.name)}',
      };
    }
  }

  void _showMenu(BuildContext context) {
    context.showContextMenu([
      if (item.viewable())
        ListTile(
          leading: const Icon(Icons.play_arrow_rounded),
          title: Text(AppLocalizations.of(context)!.buttonView),
          onTap: () {
            Navigator.of(context).pop();
            _play(context);
          },
        ),
      ListTile(
        leading: const Icon(Icons.drive_file_rename_outline),
        title: Text(AppLocalizations.of(context)!.buttonRename),
        onTap: () async {
          Navigator.of(context).pop();
          final String? filename = await context.pushNamed<String>(
            .fileRename,
            arguments: {'dialogTitle': AppLocalizations.of(context)!.buttonRename, 'filename': item.name},
          );
          if (filename != null && context.mounted) {
            final AsyncSnapshot<void>? resp = await showNotification(context, onRename(filename));
            if (resp?.error == null) {
              onRefresh();
            }
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.delete_outline_rounded),
        title: Text(AppLocalizations.of(context)!.buttonDelete),
        onTap: () async {
          Navigator.of(context).pop();
          final bool? flag = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText);
          if ((flag ?? false) && context.mounted) {
            final AsyncSnapshot<void>? resp = await showNotification(context, onRemove());
            if (resp?.error == null) {
              onRefresh();
            }
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.info_outline_rounded),
        title: Text(AppLocalizations.of(context)!.buttonProperty),
        onTap: () {
          Navigator.of(context).pop();
          context.showContextMenu([
            Icon(item.icon(), size: 128),
            ListTile(title: Text(item.name, style: Theme.of(context).textTheme.headlineMedium)),
            ListTile(
              leading: Text(AppLocalizations.of(context)!.filePropertyCategory),
              title: Text(_getCategory(context)),
            ),
            if (item.type == FileType.file)
              ListTile(
                leading: Text(AppLocalizations.of(context)!.filePropertySize),
                title: Text(item.size?.toSizeDisplay() ?? ''),
              ),
            ListTile(
              leading: Text(AppLocalizations.of(context)!.filePropertyUpdateAt),
              title: Text(item.updatedAt?.formatFullWithoutSec() ?? ''),
            ),
            ListTile(
              leading: Text(AppLocalizations.of(context)!.filePropertyCreateAt),
              title: Text(item.createdAt?.formatFullWithoutSec() ?? ''),
            ),
          ]);
        },
      ),
    ]);
  }
}

extension on DriverFile {
  bool viewable() {
    if (url == null) {
      return false;
    }
    switch (category) {
      case FileCategory.image:
      case FileCategory.video:
      case FileCategory.audio:
        return true;
      default:
        return false;
    }
  }

  IconData icon() {
    if (type == FileType.folder) {
      return Icons.folder_outlined;
    } else {
      return switch (category) {
        FileCategory.video => Icons.movie_outlined,
        FileCategory.audio => Icons.music_note_outlined,
        FileCategory.image => Icons.image_outlined,
        FileCategory.doc => Icons.article_outlined,
        _ => Icons.note_outlined,
      };
    }
  }
}
