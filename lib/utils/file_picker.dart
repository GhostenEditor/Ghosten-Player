import 'package:api/api.dart' hide PageData;
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter/services.dart';

import '../adaptive/adaptive.dart';
import '../components/components.dart';
import '../l10n/app_localizations.dart';
import 'date_time.dart';
import 'int.dart';
import 'navigator.dart';

Future<(int, DriverFile)?> showDriverFilePicker(
  BuildContext context,
  String title, {
  FileType? fileType,
  FileType? selectableType,
}) async {
  final (Storage, String?)? result = await context.pushNamed<(Storage, String?)>(.storagePicker);

  if (!context.mounted || result == null) {
    return null;
  }
  final Storage storage = result.$1;
  final String? path = result.$2;
  final DriverFile? file = storage.type == .local
      ? await getDirectoryPath(initialDirectory: path).then((dir) => dir != null ? DriverFile.fromLocalDir(dir) : null)
      : await _showFilePicker(
          context,
          title: title,
          type: FilePickerType.remote,
          driverId: storage.id,
          defaultPath: path ?? '/',
          fileType: fileType,
          selectableType: selectableType,
        );
  if (file == null) {
    return null;
  }
  return (storage.id, file);
}

Future<DriverFile?> _showFilePicker(
  BuildContext context, {
  required String title,
  required FilePickerType type,
  required int driverId,
  required String defaultPath,
  FileType? fileType,
  FileType? selectableType,
}) async {
  final controller = FileViewerController<DriverFile>();
  Future<void> submit(DriverFile? file) async {
    if (file == null) {
      return;
    }
    Navigator.of(context).pop(file);
  }

  final DriverFile? file = await FilePicker.showFilePicker(
    context,
    controller: controller,
    type: type,
    contentPadding: SettingPageTheme.of(context).contentPadding!,
    defaultTitle: Text(AppLocalizations.of(context)!.pageTitleFileViewer),
    titleBuilder: (item) => Text(item?.name ?? 'Home'),
    actions: [],
    firstPageErrorIndicatorBuilder: (_) => Center(child: ErrorMessage(error: controller.error)),
    noItemsFoundIndicatorBuilder: (_) => const NoData(),
    fetchData: (index) async {
      final List<DriverFile> items = await Api.fileList(
        driverId,
        controller.currentItem.value?.id ?? defaultPath,
        type: fileType,
      );
      return PageData(items: items, count: items.length, limit: 99999999);
    },
    itemBuilder: (context, item, index) {
      return Focus(
        skipTraversal: true,
        onKeyEvent: item.type == FileType.folder
            ? (FocusNode node, KeyEvent event) {
                if (event is KeyUpEvent) {
                  switch (event.logicalKey) {
                    case LogicalKeyboardKey.arrowRight:
                      controller.nextPage(item);
                      return KeyEventResult.handled;
                    case LogicalKeyboardKey.select:
                    case LogicalKeyboardKey.enter:
                      submit(item);
                      return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              }
            : null,
        child: ListTile(
          dense: true,
          leading: Radio<DriverFile>(
            value: item,
            onChanged: (selectableType == null || item.type == selectableType) ? submit : null,
          ),
          contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 4),
          enabled: selectableType == null || item.type == selectableType,
          title: Text(item.name),
          subtitle: Row(
            spacing: 12,
            children: [
              if (item.updatedAt != null) Text(item.updatedAt!.formatFull()),
              if (item.size != null) Text(item.size!.toSizeDisplay()),
            ],
          ),
          trailing: item.type == FileType.folder
              ? IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => controller.nextPage(item))
              : null,
          onTap: item.type == FileType.folder ? () => controller.nextPage(item) : null,
        ),
      );
    },
  );
  controller.dispose();
  return file;
}
