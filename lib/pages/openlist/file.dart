import 'package:api/api.dart' hide PageData;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:openlist/openlist.dart';

import '../../components/error_message.dart';
import '../../components/no_data.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../components/loading.dart';
import '../utils/notification.dart';
import '../viewers/file_viewer.dart';

class OpenlistFile extends StatefulWidget {
  const OpenlistFile({super.key});

  @override
  State<OpenlistFile> createState() => _OpenlistFileState();
}

class _OpenlistFileState extends State<OpenlistFile> {
  final _controller = FileViewerController<DriverFile>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FilePickerDialog<DriverFile>(
      controller: _controller,
      defaultTitle: Row(spacing: 12, children: [Image.asset(assetsOpenlistLogo, width: 22), const Text('Openlist')]),
      titleBuilder: (item) => Text(item?.name ?? 'Home'),
      firstPageProgressIndicatorBuilder: (context) => const Loading(),
      newPageProgressIndicatorBuilder: (context) => const Padding(padding: EdgeInsets.all(16), child: Loading()),
      noItemsFoundIndicatorBuilder: (_) => const NoData(),
      firstPageErrorIndicatorBuilder: (context) => Center(child: ErrorMessage(error: _controller.error)),
      actions: [
        PopupMenuButton(
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  padding: EdgeInsets.zero,
                  onTap: () async {
                    final filename = await showDialog<String>(
                      context: context,
                      builder: (context) => FileNameDialog(dialogTitle: AppLocalizations.of(context)!.buttonNewFolder),
                    );
                    if (filename != null && context.mounted) {
                      final resp = await showNotification(
                        context,
                        OpenlistClient.fileMkdir([..._controller.routers.map((e) => e.name), filename].join('/')),
                      );
                      if (resp?.error == null) {
                        _controller.refresh();
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
      fetchData: (index) async {
        final resp = await OpenlistClient.fileList(
          path: _controller.routers.map((e) => e.name).join('/'),
          per_page: 30,
          page: index + 1,
        );
        return PageData(items: resp.$1, count: resp.$2, limit: 30);
      },
      itemBuilder: (context, item, int index) {
        return FileViewer(
          item: item,
          onPage: () => _controller.nextPage(item),
          onRefresh: _controller.refresh,
          onRename: (filename) => OpenlistClient.fileRename(filename, '${item.url}/${item.name}'),
          onRemove: () => OpenlistClient.fileDelete(item.url?.toString() ?? '', [item.name]),
        );
      },
    );
  }
}
