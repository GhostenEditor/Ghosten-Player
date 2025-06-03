import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/player.dart';

import '../../components/gap.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../../validators/validators.dart';
import '../../views/image_viewer.dart';
import '../utils/notification.dart';
import '../utils/player.dart';

class FileViewer extends StatelessWidget {
  const FileViewer({
    super.key,
    required this.item,
    required this.driverId,
    required this.onPage,
    required this.onRefresh,
  });

  final int driverId;
  final DriverFile item;
  final VoidCallback onPage;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      offset: const Offset(1, 0),
      tooltip: '',
      itemBuilder:
          (context) => [
            PopupMenuItem(
              padding: EdgeInsets.zero,
              onTap: () async {
                final filename = await showDialog<String>(
                  context: context,
                  builder: (context) => _FileNameDialog(dialogTitle: AppLocalizations.of(context)!.buttonNewFolder),
                );
                if (filename != null && context.mounted) {
                  final resp = await showNotification(context, Api.fileMkdir(driverId, item.parentId, filename));
                  if (resp?.error == null) {
                    onRefresh();
                  }
                }
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.folder_open_rounded),
                title: Text(AppLocalizations.of(context)!.buttonNewFolder),
              ),
            ),
            if (item.viewable())
              PopupMenuItem(
                padding: EdgeInsets.zero,
                onTap: () async {
                  switch (item.category) {
                    case FileCategory.image:
                      navigateTo(context, ImageViewer(url: item.url!.normalize(), title: item.name));
                    case FileCategory.video:
                      toPlayer(context, [
                        PlaylistItemDisplay(
                          url: item.url?.normalize(),
                          fileId: item.fileId,
                          title: item.name,
                          description: item.updatedAt?.format(),
                          source: null,
                        ),
                      ]);
                    default:
                  }
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const Icon(Icons.play_arrow_rounded),
                  title: Text(AppLocalizations.of(context)!.buttonView),
                ),
              ),
            PopupMenuItem(
              padding: EdgeInsets.zero,
              onTap: () async {
                final filename = await showDialog<String>(
                  context: context,
                  builder:
                      (context) =>
                          _FileNameDialog(dialogTitle: AppLocalizations.of(context)!.buttonRename, filename: item.name),
                );
                if (filename != null && context.mounted) {
                  final resp = await showNotification(context, Api.fileRename(driverId, item.id, filename));
                  if (resp?.error == null) {
                    onRefresh();
                  }
                }
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.drive_file_rename_outline),
                title: Text(AppLocalizations.of(context)!.buttonRename),
              ),
            ),
            PopupMenuItem(
              padding: EdgeInsets.zero,
              onTap: () async {
                final flag = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText);
                if ((flag ?? false) && context.mounted) {
                  final resp = await showNotification(context, Api.fileRemove(driverId, item.id));
                  if (resp?.error == null) {
                    onRefresh();
                  }
                }
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.delete_outline),
                title: Text(AppLocalizations.of(context)!.buttonDelete),
              ),
            ),
            PopupMenuItem(
              padding: EdgeInsets.zero,
              onTap: () async {
                showModalBottomSheet(context: context, builder: (context) => FilePropertyBottomSheet(item: item));
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(AppLocalizations.of(context)!.buttonProperty),
              ),
            ),
          ],
      child: Focus(
        onKeyEvent:
            item.type == FileType.folder
                ? (FocusNode node, KeyEvent event) {
                  if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
                    onPage();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                }
                : null,
        child: ListTile(
          leading: Icon(item.icon()),
          title: Text(item.name, overflow: TextOverflow.ellipsis),
          subtitle: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                if (item.updatedAt != null) TextSpan(text: item.updatedAt!.formatFull()),
                if (item.type == FileType.file && item.updatedAt != null) const WidgetSpan(child: Gap.hMD),
                if (item.type == FileType.file && item.size != null) TextSpan(text: item.size!.toSizeDisplay()),
              ],
            ),
          ),
          trailing:
              item.type == FileType.folder
                  ? IconButton(icon: const Icon(Icons.chevron_right), onPressed: onPage)
                  : null,
        ),
      ),
    );
  }
}

class _FileNameDialog extends StatefulWidget {
  const _FileNameDialog({required this.dialogTitle, this.filename});

  final String dialogTitle;
  final String? filename;

  @override
  State<_FileNameDialog> createState() => _FileNameDialogState();
}

class _FileNameDialogState extends State<_FileNameDialog> {
  late final _controller = TextEditingController(text: widget.filename);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          autofocus: true,
          controller: _controller,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            filled: true,
            isDense: true,
            labelText: AppLocalizations.of(context)!.formLabelTitle,
          ),
          validator: (value) => requiredValidator(context, value),
          onEditingComplete: () => FocusScope.of(context).nextFocus(),
        ),
      ),
      actions: [
        FilledButton(
          child: Text(AppLocalizations.of(context)!.buttonConfirm),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_controller.text);
            }
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.buttonCancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class FilePropertyBottomSheet extends StatelessWidget {
  const FilePropertyBottomSheet({super.key, required this.item});

  final DriverFile item;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
      children: [
        Icon(item.icon(), size: 128),
        ListTile(title: Text(item.name, style: Theme.of(context).textTheme.headlineMedium)),
        _buildListTile(context, AppLocalizations.of(context)!.filePropertyCategory, _getCategory(context)),
        if (item.type == FileType.file)
          _buildListTile(context, AppLocalizations.of(context)!.filePropertySize, item.size?.toSizeDisplay() ?? ''),
        _buildListTile(
          context,
          AppLocalizations.of(context)!.filePropertyUpdateAt,
          item.updatedAt?.formatFullWithoutSec() ?? '',
        ),
        _buildListTile(
          context,
          AppLocalizations.of(context)!.filePropertyCreateAt,
          item.createdAt?.formatFullWithoutSec() ?? '',
        ),
        const SafeArea(child: SizedBox()),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, String leading, String title) {
    return ListTile(
      minLeadingWidth: 100,
      dense: true,
      leading: Text(leading),
      leadingAndTrailingTextStyle: Theme.of(context).textTheme.labelLarge,
      title: Text(title),
      titleTextStyle: Theme.of(context).textTheme.bodyLarge,
    );
  }

  String _getCategory(BuildContext context) {
    if (item.type == FileType.folder) {
      return AppLocalizations.of(context)!.fileCategory('folder');
    } else {
      final ext = item.name.split('.').lastOrNull?.toUpperCase() ?? '';
      return switch (item.category) {
        null || FileCategory.other => AppLocalizations.of(context)!.fileCategory(FileCategory.other.name),
        _ => '$ext ${AppLocalizations.of(context)!.fileCategory(item.category!.name)}',
      };
    }
  }
}

extension on DriverFile {
  bool viewable() {
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
