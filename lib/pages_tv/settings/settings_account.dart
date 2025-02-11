import 'package:api/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/async_image.dart';
import '../../components/no_data.dart';
import '../../utils/utils.dart';
import '../components/future_builder_handler.dart';
import '../components/icon_button.dart';
import '../components/setting.dart';
import '../mixins/update.dart';
import '../utils/notification.dart';
import '../utils/utils.dart';
import '../views/file_viewer.dart';
import 'settings_login.dart';

class SettingsAccountPage extends StatefulWidget {
  const SettingsAccountPage({super.key});

  @override
  State<SettingsAccountPage> createState() => _SettingsAccountPageState();
}

class _SettingsAccountPageState extends State<SettingsAccountPage> {
  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.pageTitleAccount,
      child: FutureBuilderHandler<List<DriverAccount>>(
          initialData: const [],
          future: Api.driverQueryAll(),
          builder: (context, snapshot) {
            return ListView(padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32), children: [
              ...snapshot.requireData.indexed.map((entry) => SlidableSettingItem(
                    autofocus: entry.$1 == 0,
                    title: Text(entry.$2.name),
                    subtitle: Text(AppLocalizations.of(context)!.driverType(entry.$2.type.name)),
                    leading: AspectRatio(
                      aspectRatio: 1,
                      child: entry.$2.avatar == null
                          ? const AspectRatio(aspectRatio: 1, child: Icon(Icons.account_circle, size: 48))
                          : AsyncImage(
                              entry.$2.avatar!,
                              radius: BorderRadius.circular(6),
                              ink: true,
                            ),
                    ),
                    actions: [
                      TVIconButton(onPressed: () => showFilePicker(context, FilePickerType.remote, entry.$2.id, '/'), icon: const Icon(Icons.folder_outlined)),
                      TVIconButton(onPressed: () => navigateToSlideLeft(context, AccountPreference(account: entry.$2)), icon: const Icon(Icons.edit_outlined)),
                      TVIconButton(
                          onPressed: () async {
                            final confirmed = await showConfirm(
                                context, AppLocalizations.of(context)!.deleteAccountConfirmText, AppLocalizations.of(context)!.deleteAccountTip);
                            if (confirmed == true && context.mounted) {
                              final resp = await showNotification(context, Api.driverDeleteById(entry.$2.id));
                              if (resp?.error == null) {
                                setState(() {});
                                updateController.add(null);
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_outline)),
                    ],
                  )),
              if (snapshot.requireData.isNotEmpty) const DividerSettingItem(),
              const GapSettingItem(height: 12),
              IconButtonSettingItem(
                autofocus: snapshot.requireData.isEmpty,
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final flag = await navigateTo<bool>(navigatorKey.currentContext!, const SettingsLoginPage());
                  if (flag == true) setState(() {});
                },
              ),
            ]);
          }),
    );
  }

  Future<void> showFilePicker(BuildContext context, FilePickerType type, int driverId, String defaultPath) {
    return navigateToSlideLeft(context, _FileListPage(driverId: driverId, parentFileId: defaultPath));
  }
}

class _FileListPage extends StatefulWidget {
  final int driverId;
  final String parentFileId;
  final String? title;
  final FileType? type;

  const _FileListPage({
    required this.driverId,
    required this.parentFileId,
    this.type,
    this.title,
  });

  @override
  State<_FileListPage> createState() => _FileListPageState();
}

class _FileListPageState extends State<_FileListPage> {
  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: widget.title ?? AppLocalizations.of(context)!.pageTitleFileViewer,
      child: FutureBuilderHandler(
          future: Api.fileList(widget.driverId, widget.parentFileId, type: widget.type),
          builder: (context, snapshot) {
            return snapshot.requireData.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
                    itemCount: snapshot.requireData.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.requireData[index];
                      return FileViewer(
                        autofocus: index == 0,
                        item: item,
                        driverId: widget.driverId,
                        onRefresh: () => setState(() {}),
                        onPage: () => onPage(item.id, item.name),
                      );
                    })
                : const NoData();
          }),
    );
  }

  onPage(String parentFileId, [String? title]) {
    navigateToSlideLeft(
        context,
        _FileListPage(
          driverId: widget.driverId,
          parentFileId: parentFileId,
          type: widget.type,
          title: title,
        ));
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
    return SettingPage(
        title: AppLocalizations.of(context)!.pageTitleAccountSetting,
        child: FutureBuilderHandler(
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
                      SwitchSettingItem(
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
                      SwitchSettingItem(
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
                      StepperSettingItem(
                        title: Text(AppLocalizations.of(context)!.playerParallelsCount),
                        min: 2,
                        max: 8,
                        value: concurrency ?? 4,
                        onChanged: (value) => setState(() => concurrency = value),
                      ),
                    if (data.containsKey('sliceSize') && concurrency != null)
                      StepperSettingItem(
                        title: Text(AppLocalizations.of(context)!.playerSliceSize),
                        min: 1,
                        max: 20,
                        value: sliceSize ?? 5,
                        onChanged: (value) => setState(() => sliceSize = value),
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
  final Function(int) onChange;

  const Stepper({super.key, this.max, this.min, this.step = 1, required this.onChange, required this.value});

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
            onTap: min == null || value > min! ? () => onChange(clamp(value - step)) : null,
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
            onTap: max == null || value < max! ? () => onChange(clamp(value + step)) : null,
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
