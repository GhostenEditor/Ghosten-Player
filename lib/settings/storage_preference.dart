import 'package:api/api.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide ListTile, SwitchListTile;

import '../adaptive/adaptive.dart';
import '../components/components.dart';
import '../l10n/app_localizations.dart';
import '../utils/notification.dart';

class SettingsStoragePreferencePage extends StatelessWidget {
  const SettingsStoragePreferencePage({super.key, required this.storage});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    return switch (storage.type) {
      DriverType.alipan => _AlipanSettings(id: storage.id),
      DriverType.quark => _QuarkSettings(id: storage.id),
      _ => const Scaffold(body: NoData()),
    };
  }
}

class _QuarkSettings extends StatelessWidget {
  const _QuarkSettings({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return FutureBuilderHandler(
      future: Api.storageSettingQueryById(id),
      builder: (context, snapshot) {
        final List<dynamic> data = snapshot.requireData;
        int? concurrency = data[0];
        int? sliceSize = data[1];
        return EditPage(
          title: Text(AppLocalizations.of(context)!.pageTitleAccountSetting),
          useAssistance: false,
          onResetButtonPressed: () async {
            final AsyncSnapshot<void>? resp = await showNotification(
              context,
              Api.storageSettingUpdateById(id, [null, null]),
            );
            if (resp?.error == null && context.mounted) {
              Navigator.pop(context, true);
            }
          },
          onConfirmButtonPressed: () async {
            final AsyncSnapshot<void>? resp = await showNotification(
              context,
              Api.storageSettingUpdateById(id, [concurrency, if (concurrency == null) null else sliceSize]),
            );
            if (resp?.error == null && context.mounted) {
              Navigator.pop(context, true);
            }
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return ListView(
                children: [
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.playerParallelsCount),
                    trailing: NumberStepper(
                      min: 2,
                      max: 32,
                      value: concurrency,
                      onChanged: (value) => setState(() => concurrency = value),
                    ),
                  ),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.playerSliceSize),
                    trailing: NumberStepper(
                      min: 1,
                      max: 20,
                      value: sliceSize,
                      onChanged: (value) => setState(() => sliceSize = value),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _AlipanSettings extends StatelessWidget {
  const _AlipanSettings({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return FutureBuilderHandler(
      future: Api.storageSettingQueryById(id),
      builder: (context, snapshot) {
        final List<dynamic> data = snapshot.requireData;
        bool? proxy = data[0] ?? false;
        int? concurrency = data[1];
        int? sliceSize = data[2];
        _AlipanVideoClarity? alipanVideoClarity = _AlipanVideoClarity.fromString(data[3]);

        return EditPage(
          title: Text(AppLocalizations.of(context)!.pageTitleAccountSetting),
          useAssistance: false,
          onResetButtonPressed: () async {
            final AsyncSnapshot<void>? resp = await showNotification(
              context,
              Api.storageSettingUpdateById(id, [null, null, null, null]),
            );
            if (resp?.error == null && context.mounted) {
              Navigator.pop(context, true);
            }
          },
          onConfirmButtonPressed: () async {
            final AsyncSnapshot<void>? resp = await showNotification(
              context,
              Api.storageSettingUpdateById(id, [proxy, concurrency, sliceSize, alipanVideoClarity?.name.toUpperCase()]),
            );
            if (resp?.error == null && context.mounted) {
              Navigator.pop(context, true);
            }
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              return ListView(
                children: [
                  SwitchListTile(
                    title: Text(AppLocalizations.of(context)!.accountUseProxy),
                    value: proxy ?? false,
                    onChanged: (value) => setState(() {
                      proxy = value;
                      if (proxy == false) {
                        concurrency = null;
                        sliceSize = null;
                      }
                    }),
                  ),
                  if (proxy ?? false)
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.playerParallelsCount),
                      trailing: NumberStepper(
                        min: 2,
                        max: 6,
                        value: concurrency,
                        onChanged: (value) => setState(() => concurrency = value),
                      ),
                    ),
                  if (proxy ?? false)
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.playerSliceSize),
                      trailing: NumberStepper(
                        min: 1,
                        max: 20,
                        value: sliceSize,
                        onChanged: (value) => setState(() => sliceSize = value),
                      ),
                    ),
                  if (!(proxy ?? false))
                    MenuListTile(
                      initialValue: alipanVideoClarity,
                      onSelected: (value) => setState(() => alipanVideoClarity = value),
                      title: Text(AppLocalizations.of(context)!.playerVideoClarity),
                      subtitle: Text(AppLocalizations.of(context)!.playerAlipanVideoClarityTip),
                      trailing: Text(alipanVideoClarity?.name.toUpperCase() ?? 'NONE'),
                      itemBuilder: (context) {
                        return [
                          CheckedPopupMenuItem(checked: alipanVideoClarity == null, child: const Text('NONE')),
                          ..._AlipanVideoClarity.values.map(
                            (clarity) => CheckedPopupMenuItem(
                              checked: alipanVideoClarity == clarity,
                              value: clarity,
                              child: Text(clarity.name.toUpperCase()),
                            ),
                          ),
                        ];
                      },
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

enum _AlipanVideoClarity {
  ld,
  sd,
  hd,
  fhd,
  qhd;

  static _AlipanVideoClarity? fromString(String? str) {
    final String? s = str?.toLowerCase();
    return _AlipanVideoClarity.values.firstWhereOrNull((element) => element.name == s);
  }
}
