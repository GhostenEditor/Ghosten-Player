import 'package:api/api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../components/async_image.dart';
import '../../components/error_message.dart';
import '../../components/focus_card.dart';
import '../../components/future_builder_handler.dart';
import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../utils/notification.dart';
import '../viewers/file_viewer.dart';
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.pageTitleAccount)),
      body: FutureBuilderHandler<List<DriverAccount>>(
        future: Api.driverQueryAll(),
        builder: (context, snapshot) {
          return Scrollbar(
            controller: _controller,
            child: GridView.builder(
              controller: _controller,
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ).copyWith(bottom: MediaQuery.paddingOf(context).bottom + 8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.7,
              ),
              itemCount: snapshot.requireData.length + 1,
              itemBuilder: (context, index) {
                if (index == snapshot.requireData.length) {
                  return FocusCard(
                    onTap: () async {
                      final flag = await navigateTo<bool>(context, const AccountLoginPage());
                      if (flag ?? false) setState(() {});
                    },
                    child: const Center(child: IconButton.filledTonal(onPressed: null, icon: Icon(Icons.add))),
                  );
                } else {
                  final item = snapshot.requireData[index];
                  return FocusCard(
                    itemBuilder:
                        (BuildContext context) => [
                          PopupMenuItem(
                            padding: EdgeInsets.zero,
                            onTap: () => _showFilePicker(FilePickerType.remote, item.id, '/'),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              leading: const Icon(Icons.folder_outlined),
                              title: Text(AppLocalizations.of(context)!.pageTitleFileViewer),
                            ),
                          ),
                          if (item.type != DriverType.webdav)
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
                              final confirmed = await showConfirm(
                                context,
                                AppLocalizations.of(context)!.deleteAccountTip,
                              );
                              if (confirmed ?? false) {
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
                          child:
                              item.avatar == null
                                  ? const Icon(Icons.account_circle, size: 160)
                                  : AsyncImage(item.avatar!, ink: true, radius: BorderRadius.circular(4)),
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
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<DriverFile?> _showFilePicker(FilePickerType type, int driverId, String defaultPath) {
    return FilePicker.showFilePicker(
      context,
      type: type,
      title: AppLocalizations.of(context)!.pageTitleFileViewer,
      errorBuilder: (snapshot) => Center(child: ErrorMessage(error: snapshot.error)),
      empty: const NoData(),
      onFetch: (item) => Api.fileList(driverId, item?.id ?? defaultPath),
      childBuilder: (context, item, {required onPage, required onSubmit, required onRefresh, groupValue}) {
        return FileViewer(item: item, driverId: driverId, onRefresh: onRefresh, onPage: onPage);
      },
    );
  }
}

class AccountPreference extends StatelessWidget {
  const AccountPreference({super.key, required this.account});

  final DriverAccount account;

  @override
  Widget build(BuildContext context) {
    bool proxy = false;
    int? concurrency;
    int? sliceSize;
    _AlipanVideoClarity alipanVideoClarity;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.pageTitleAccountSetting)),
      body: FutureBuilderHandler(
        future: Api.driverSettingQueryById(account.id),
        builder: (context, snapshot) {
          final data = snapshot.requireData!;
          proxy = data['proxy'] ?? false;
          concurrency = data['concurrency'];
          sliceSize = data['sliceSize'];
          alipanVideoClarity = _AlipanVideoClarity.fromString(data['alipanVideoClarity']);
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              Api.driverSettingUpdateById(account.id, {
                if (data.containsKey('proxy')) 'proxy': proxy,
                if (data.containsKey('concurrency')) 'concurrency': concurrency,
                if (data.containsKey('sliceSize')) 'slice_size': concurrency == null ? null : sliceSize,
                if (data.containsKey('alipanVideoClarity'))
                  'alipan_video_clarity':
                      alipanVideoClarity == _AlipanVideoClarity.none ? null : alipanVideoClarity.name,
              });
              Navigator.of(context).pop();
            },
            child: StatefulBuilder(
              builder: (context, setState) {
                final children = [
                  if (data.containsKey('proxy'))
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context)!.accountUseProxy),
                      value: proxy,
                      onChanged:
                          (value) => setState(() {
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
                      onChanged:
                          (!data.containsKey('proxy') || proxy)
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
                        max: data.containsKey('proxy') ? 6 : 32,
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
                  if (data.containsKey('alipanVideoClarity'))
                    PopupMenuButton(
                      tooltip: '',
                      offset: const Offset(1, 0),
                      enabled: !proxy,
                      onSelected: (value) => setState(() => alipanVideoClarity = value),
                      itemBuilder:
                          (BuildContext context) =>
                              _AlipanVideoClarity.values
                                  .map(
                                    (clarity) => CheckedPopupMenuItem(
                                      checked: alipanVideoClarity == clarity,
                                      value: clarity,
                                      child: Text(clarity.name.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                      child: ListTile(
                        enabled: !proxy,
                        title: Text(AppLocalizations.of(context)!.playerVideoClarity),
                        subtitle: Text(AppLocalizations.of(context)!.playerAlipanVideoClarityTip),
                        trailing: Text(alipanVideoClarity.name.toUpperCase()),
                      ),
                    ),
                ];
                return children.isNotEmpty ? ListView(children: children) : const NoData();
              },
            ),
          );
        },
      ),
    );
  }
}

class Stepper extends StatelessWidget {
  const Stepper({super.key, this.max, this.min, this.step = 1, required this.onChanged, required this.value});

  final int value;
  final int? max;
  final int? min;
  final int step;
  final Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Theme.of(context).colorScheme.primary),
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(1000),
      ),
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
                color:
                    min == null || value > min!
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
          SizedBox(width: 20, child: Text(value.toString(), textAlign: TextAlign.center)),
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: max == null || value < max! ? () => onChanged(clamp(value + step)) : null,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.add,
                size: 16,
                color:
                    max == null || value < max!
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primaryContainer,
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

// ignore_for_file: constant_identifier_names
enum _AlipanVideoClarity {
  none,
  LD,
  SD,
  HD,
  FHD,
  QHD;

  static _AlipanVideoClarity fromString(String? str) {
    return _AlipanVideoClarity.values.firstWhere(
      (element) => element.name == str,
      orElse: () => _AlipanVideoClarity.none,
    );
  }
}
