import 'package:api/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/appbar_progress.dart';
import '../../components/error_message.dart';
import '../../components/focus_card.dart';
import '../../components/future_builder_handler.dart';
import '../../components/no_data.dart';
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
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            padding: EdgeInsets.zero,
                            onTap: () => showFilePicker(FilePickerType.remote, item.id, '/'),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              leading: const Icon(Icons.folder_outlined),
                              title: Text(AppLocalizations.of(context)!.pageTitleFileViewer),
                            ),
                          ),
                          PopupMenuItem(
                            padding: EdgeInsets.zero,
                            onTap: () => navigateTo(context, AccountPreference(account: item)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              leading: const Icon(Icons.edit_outlined),
                              title: Text(AppLocalizations.of(context)!.buttonEdit),
                            ),
                          ),
                          PopupMenuItem(
                            padding: EdgeInsets.zero,
                            onTap: () async {
                              final confirmed = await showConfirm(context, AppLocalizations.of(context)!.deleteAccountTip);
                              if (confirmed == true) {
                                if (!context.mounted) return;
                                final resp = await showNotification(context, Api.driverDeleteById(item.id));
                                if (resp?.error == null) setState(() {});
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

class AccountPreference extends StatelessWidget {
  final DriverAccount account;

  const AccountPreference({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    bool proxy = false;
    int? concurrency;
    int? sliceSize;
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.pageTitleAccountSetting)),
        body: FutureBuilderHandler(
          future: Api.driverSettingQueryById(account.id),
          builder: (context, snapshot) {
            final data = snapshot.requireData!;
            proxy = data['proxy'] ?? false;
            concurrency = data['concurrency'];
            sliceSize = data['sliceSize'];
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                Api.driverSettingUpdateById(account.id, {
                  if (data.containsKey('proxy')) 'proxy': proxy,
                  if (data.containsKey('concurrency')) 'concurrency': concurrency,
                  if (data.containsKey('sliceSize')) 'sliceSize': concurrency == null ? null : sliceSize,
                });
                Navigator.of(context).pop();
              },
              child: StatefulBuilder(builder: (context, setState) {
                return ListView(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
                  children: [
                    if (data.containsKey('proxy'))
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.accountUseProxy),
                        value: proxy,
                        onChanged: (value) => setState(() {
                          proxy = value;
                          if (!proxy) {
                            concurrency = null;
                            sliceSize = null;
                          }
                        }),
                      ),
                    if (data.containsKey('concurrency'))
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.playerOpenFileWithParallelThreads),
                        value: concurrency != null,
                        onChanged: (!data.containsKey('proxy') || proxy)
                            ? (value) => setState(() {
                                  concurrency = value ? 4 : null;
                                  sliceSize = value ? 5 : null;
                                })
                            : null,
                      ),
                    if (data.containsKey('concurrency') && concurrency != null)
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.playerParallelsCount),
                        trailing: Stepper(
                          min: 2,
                          max: 8,
                          value: concurrency ?? 4,
                          onChanged: (value) => setState(() => concurrency = value),
                        ),
                      ),
                    if (data.containsKey('sliceSize') && concurrency != null)
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.playerSliceSize),
                        trailing: Stepper(
                          min: 1,
                          max: 20,
                          value: sliceSize ?? 5,
                          onChanged: (value) => setState(() => sliceSize = value),
                        ),
                      ),
                  ],
                );
              }),
            );
          },
        ));
  }
}

class Stepper extends StatelessWidget {
  final int value;
  final int? max;
  final int? min;
  final int step;
  final Function(int) onChanged;

  const Stepper({super.key, this.max, this.min, this.step = 1, required this.onChanged, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(1000)),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: min == null || value > min! ? () => onChanged(clamp(value - step)) : null,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.remove,
                size: 16,
                color: min == null || value > min! ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
          SizedBox(
            width: 20,
            child: Text(value.toString(), textAlign: TextAlign.center),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: max == null || value < max! ? () => onChanged(clamp(value + step)) : null,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.add,
                size: 16,
                color: max == null || value < max! ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int clamp(int v) {
    if (max != null) {
      v = v < max! ? v : max!;
    }
    if (min != null) {
      v = v > min! ? v : min!;
    }
    return v;
  }
}
