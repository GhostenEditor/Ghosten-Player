import 'package:api/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PopupMenuItem;
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/appbar_progress.dart';
import '../../components/error_message.dart';
import '../../components/focus_card.dart';
import '../../components/future_builder_handler.dart';
import '../../components/gap.dart';
import '../../components/no_data.dart';
import '../../components/popup_menu.dart';
import '../../utils/notification.dart';
import '../../utils/utils.dart';
import '../../validators/validators.dart';
import 'account_login.dart';

class AccountManage extends StatefulWidget {
  const AccountManage({super.key});

  @override
  State<AccountManage> createState() => _AccountManageState();
}

class _AccountManageState extends State<AccountManage> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pageTitleAccount),
        bottom: const AppbarProgressIndicator(),
      ),
      body: FutureBuilderHandler<List<DriverAccount>>(
          initialData: const [],
          future: Api.driverQueryAll(),
          builder: (context, snapshot) {
            return Scrollbar(
              controller: _controller,
              child: GridView.builder(
                  controller: _controller,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, childAspectRatio: 0.7),
                  itemCount: snapshot.requireData.length + 1,
                  itemBuilder: (context, index) {
                    if (index == snapshot.requireData.length) {
                      return FocusCard(
                        autofocus: kIsAndroidTV && index == 0,
                        onTap: () async {
                          final flag = await navigateTo<bool>(context, const AccountLoginPage());
                          if (flag == true) setState(() {});
                        },
                        child: const Center(
                          child: IconButton.filledTonal(
                            onPressed: null,
                            icon: Icon(Icons.add),
                          ),
                        ),
                      );
                    } else {
                      final item = snapshot.requireData[index];
                      return FocusCard(
                        autofocus: kIsAndroidTV && index == 0,
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            autofocus: kIsAndroidTV,
                            leading: const Icon(Icons.folder_outlined),
                            title: Text(AppLocalizations.of(context)!.pageTitleFileViewer),
                            onTap: () async {
                              await showFilePicker(FilePickerType.remote, item.id, '/');
                            },
                          ),
                          PopupMenuItem(
                            autofocus: kIsAndroidTV,
                            leading: const Icon(Icons.delete_outline),
                            title: Text(AppLocalizations.of(context)!.buttonDelete),
                            onTap: () async {
                              final confirmed = await showConfirm(context, AppLocalizations.of(context)!.deleteAccountConfirmText);
                              if (confirmed == true) {
                                if (!context.mounted) return;
                                final resp = await showNotification(context, Api.driverDeleteById(item.id));
                                if (resp?.error == null) setState(() {});
                              }
                            },
                          ),
                        ],
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: item.avatar == null ? const Icon(Icons.account_circle, size: 160) : Image.network(item.avatar!),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item.name, overflow: TextOverflow.ellipsis),
                                    Text(AppLocalizations.of(context)!.driverType(item.type.name)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  }),
            );
          }),
    );
  }

  Future<DriverFile?> showFilePicker(FilePickerType type, int driverId, String defaultPath) {
    return FilePicker.showFilePicker(context,
        type: type,
        title: AppLocalizations.of(context)!.pageTitleFileViewer,
        errorBuilder: (snapshot) => Center(child: ErrorMessage(snapshot: snapshot)),
        empty: const NoData(),
        onFetch: (item) => Api.fileList(driverId, item?.id ?? defaultPath),
        childBuilder: (context, item, {required onPage, required onSubmit, required onRefresh, groupValue}) {
          return PopupMenuButton(
            offset: const Offset(1, 0),
            itemBuilder: (context) => [
              PopupMenuItem(
                autofocus: kIsAndroidTV,
                leading: const Icon(Icons.folder_open),
                title: Text(AppLocalizations.of(context)!.buttonRename),
                onTap: () async {
                  final filename = await showDialog<String>(context: context, builder: (context) => _FileRenameDialog(filename: item.name));
                  if (filename != null && context.mounted) {
                    final resp = await showNotification(context, Api.fileRename(driverId, item.id, filename));
                    if (resp?.error == null) {
                      onRefresh();
                    }
                  }
                },
              ),
              PopupMenuItem(
                autofocus: kIsAndroidTV,
                leading: const Icon(Icons.delete_outline),
                title: Text(AppLocalizations.of(context)!.buttonDelete),
                onTap: () async {
                  final confirmed = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText);
                  if (confirmed == true && context.mounted) {
                    final resp = await showNotification(context, Api.fileRemove(driverId, item.id));
                    if (resp?.error == null) {
                      onRefresh();
                    }
                  }
                },
              ),
            ],
            child: Focus(
              onKeyEvent: item.type == FileType.folder
                  ? (FocusNode node, KeyEvent event) {
                      if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
                        onPage();
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    }
                  : null,
              child: ListTile(
                leading: item.type == FileType.folder ? const Icon(Icons.folder_outlined) : const Icon(Icons.note_outlined),
                title: Text(item.name, overflow: TextOverflow.ellipsis),
                subtitle: RichText(
                    text: TextSpan(style: Theme.of(context).textTheme.bodySmall, children: [
                  if (item.updatedAt != null) TextSpan(text: item.updatedAt!.formatFull()),
                  if (item.type == FileType.file && item.updatedAt != null) const WidgetSpan(child: Gap.hMD),
                  if (item.type == FileType.file && item.size != null) TextSpan(text: item.size!.toSizeDisplay()),
                ])),
                trailing: item.type == FileType.folder ? IconButton(icon: const Icon(Icons.chevron_right), onPressed: onPage) : null,
              ),
            ),
          );
        });
  }
}

class _FileRenameDialog extends StatefulWidget {
  final String filename;

  const _FileRenameDialog({required this.filename});

  @override
  State<_FileRenameDialog> createState() => _FileRenameDialogState();
}

class _FileRenameDialogState extends State<_FileRenameDialog> {
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
      title: Text(AppLocalizations.of(context)!.buttonRename),
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
              Navigator.of(context).pop((_controller.text));
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
