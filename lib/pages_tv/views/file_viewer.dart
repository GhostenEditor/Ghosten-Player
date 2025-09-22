import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/player.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../../validators/validators.dart';
import '../../views/image_viewer.dart';
import '../components/filled_button.dart';
import '../components/keyboard_reopen.dart';
import '../components/list_tile.dart';
import '../components/setting.dart';
import '../utils/notification.dart';
import '../utils/player.dart';
import '../utils/utils.dart';

class FileViewer extends StatelessWidget {
  const FileViewer({
    super.key,
    required this.item,
    required this.driverId,
    required this.onPage,
    required this.onRefresh,
    this.autofocus = false,
  });

  final bool autofocus;
  final int driverId;
  final DriverFile item;
  final VoidCallback onPage;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Focus(
      skipTraversal: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.contextMenu) {
          showModalBottomSheet(
            context: context,
            builder:
                (context) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TVListTile(
                        autofocus: true,
                        leading: const Icon(Icons.folder_open_rounded),
                        title: Text(AppLocalizations.of(context)!.buttonNewFolder),
                        onTap: () async {
                          final filename = await navigateToSlideLeft<String>(
                            context,
                            _FileNameDialog(dialogTitle: AppLocalizations.of(context)!.buttonNewFolder),
                          );
                          if (filename != null && context.mounted) {
                            final resp = await showNotification(
                              context,
                              Api.fileMkdir(driverId, item.parentId, filename),
                            );
                            if (resp?.error == null) {
                              onRefresh();
                            }
                          }
                        },
                      ),
                      if (item.viewable())
                        TVListTile(
                          leading: const Icon(Icons.play_arrow_rounded),
                          title: Text(AppLocalizations.of(context)!.buttonView),
                          onTap: () async {
                            switch (item.category) {
                              case FileCategory.image:
                                navigateTo(
                                  navigatorKey.currentContext!,
                                  ImageViewer(url: item.url!.normalize(), title: item.name),
                                );
                              case FileCategory.video:
                                toPlayer(navigatorKey.currentContext!, (
                                  [
                                    PlaylistItemDisplay(
                                      url: item.url!.normalize(),
                                      title: item.name,
                                      description: item.updatedAt?.format(),
                                      source: null,
                                    ),
                                  ],
                                  0,
                                ));
                              default:
                            }
                          },
                        ),
                      TVListTile(
                        leading: const Icon(Icons.drive_file_rename_outline),
                        title: Text(AppLocalizations.of(context)!.buttonRename),
                        onTap: () async {
                          final filename = await navigateToSlideLeft<String>(
                            context,
                            _FileNameDialog(
                              dialogTitle: AppLocalizations.of(context)!.buttonRename,
                              filename: item.name,
                            ),
                          );
                          if (filename != null && context.mounted) {
                            final resp = await showNotification(context, Api.fileRename(driverId, item.id, filename));
                            if (resp?.error == null) {
                              onRefresh();
                            }
                          }
                        },
                      ),
                      TVListTile(
                        leading: const Icon(Icons.delete_outline),
                        title: Text(AppLocalizations.of(context)!.buttonDelete),
                        onTap: () async {
                          final flag = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText);
                          if ((flag ?? false) && context.mounted) {
                            final resp = await showNotification(context, Api.fileRemove(driverId, item.id));
                            if (resp?.error == null) {
                              onRefresh();
                            }
                          }
                        },
                      ),
                      TVListTile(
                        leading: const Icon(Icons.info_outline_rounded),
                        title: Text(AppLocalizations.of(context)!.buttonProperty),
                        onTap: () async {
                          showDialog(
                            context: navigatorKey.currentContext!,
                            builder: (context) => FilePropertyBottomSheet(item: item),
                          );
                        },
                      ),
                    ],
                  ),
                ),
          );
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TVListTile(
        autofocus: autofocus,
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
        onTap: item.type == FileType.file ? () => {} : onPage,
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
    return SettingPage(
      title: widget.dialogTitle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: KeyboardReopen(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  autofocus: true,
                  controller: _controller,
                  decoration: InputDecoration(isDense: true, labelText: AppLocalizations.of(context)!.formLabelTitle),
                  validator: (value) => requiredValidator(context, value),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
              ),
              const Spacer(),
              TVFilledButton(
                child: Text(AppLocalizations.of(context)!.buttonConfirm),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop(_controller.text);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilePropertyBottomSheet extends StatelessWidget {
  const FilePropertyBottomSheet({super.key, required this.item});

  final DriverFile item;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
        child: Column(
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
        ),
      ),
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
