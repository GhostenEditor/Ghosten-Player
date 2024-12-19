import 'package:api/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide PopupMenuItem;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/appbar_progress.dart';
import '../../components/error_message.dart';
import '../../components/focus_card.dart';
import '../../components/future_builder_handler.dart';
import '../../components/no_data.dart';
import '../../components/popup_menu.dart';
import '../../platform_api.dart';
import '../../utils/notification.dart';
import '../../utils/utils.dart';
import '../../views/file_viewer.dart';
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
                        autofocus: PlatformApi.isAndroidTV() && index == 0,
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
                        autofocus: PlatformApi.isAndroidTV() && index == 0,
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            autofocus: PlatformApi.isAndroidTV(),
                            leading: const Icon(Icons.folder_outlined),
                            title: Text(AppLocalizations.of(context)!.pageTitleFileViewer),
                            onTap: () async {
                              await showFilePicker(FilePickerType.remote, item.id, '/');
                            },
                          ),
                          PopupMenuItem(
                            autofocus: PlatformApi.isAndroidTV(),
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
                              child: item.avatar == null
                                  ? const Icon(Icons.account_circle, size: 160)
                                  : CachedNetworkImage(imageUrl: item.avatar!, fit: BoxFit.cover),
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
          return FileViewer(item: item, driverId: driverId, onRefresh: onRefresh, onPage: onPage);
        });
  }
}
