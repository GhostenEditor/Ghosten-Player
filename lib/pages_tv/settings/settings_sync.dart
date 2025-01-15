import 'dart:async';

import 'package:api/api.dart';
import 'package:bluetooth/bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/no_data.dart';
import '../../const.dart';
import '../components/filled_button.dart';
import '../components/loading.dart';
import '../components/setting.dart';
import '../utils/notification.dart';

class SettingsSyncPage extends StatefulWidget {
  const SettingsSyncPage({super.key});

  @override
  State<SettingsSyncPage> createState() => _SettingsSyncPageState();
}

enum BluetoothState { withPermission, withoutPermission, discovering, nonAdaptor }

class _SettingsSyncPageState extends State<SettingsSyncPage> {
  final devices = <BluetoothDevice>[];
  StreamSubscription<BluetoothDevice>? subscription;
  BluetoothState bluetoothState = BluetoothState.withoutPermission;
  bool needStartServer = true;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    needStartServer = false;
    Bluetooth.close().catchError((_) {});
    subscription?.cancel();
    super.dispose();
  }

  init() async {
    try {
      if (await Bluetooth.requestPermission() && await Bluetooth.requestEnable()) {
        setState(() => bluetoothState = BluetoothState.withPermission);
        startServer();
        startDiscovery();
      }
    } catch (e) {
      setState(() => bluetoothState = BluetoothState.nonAdaptor);
    }
  }

  startServer() {
    Bluetooth.startServer().listen((device) async {
      Bluetooth.connection().listen((resp) async {
        switch (resp.type) {
          case BlueToothMessageType.file:
            await Bluetooth.disconnect();
            if (mounted) {
              final confirmed =
                  await showConfirm(context, AppLocalizations.of(context)!.dataSyncConfirmSync(device.name ?? AppLocalizations.of(context)!.tagUnknown));
              if (confirmed == true) {
                Api.syncData(resp.data);
              }
            }
          case BlueToothMessageType.text:
            Bluetooth.write(BluetoothMessage.text(appVersion));
        }
      });
    }, onError: (error) {
      if (mounted) {
        showNotification(context, Future.error(error));
      }
    }, onDone: () {
      if (needStartServer) startServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: switch (bluetoothState) {
      BluetoothState.withPermission || BluetoothState.discovering => Row(
          children: [
            Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(AppLocalizations.of(context)!.settingsItemDataSync, style: Theme.of(context).textTheme.displaySmall),
                      const SizedBox(height: 32),
                      ButtonSettingItem(
                        autofocus: true,
                        title: Text(AppLocalizations.of(context)!.dataSyncActionRescanBluetoothDevices),
                        leading: const Icon(Icons.sync),
                        onTap: () => startDiscovery(),
                      ),
                      ButtonSettingItem(
                        title: Text(AppLocalizations.of(context)!.dataSyncActionSetDiscoverable),
                        leading: const Icon(Icons.remove_red_eye_outlined),
                        onTap: () => Bluetooth.requestDiscoverable(const Duration(seconds: 60)),
                      ),
                      const Spacer(),
                      ButtonSettingItem(
                        title: Text(AppLocalizations.of(context)!.dataSyncActionRollback),
                        leading: const Icon(Icons.settings_backup_restore),
                        onTap: () async {
                          final confirmed = await showConfirm(context, AppLocalizations.of(context)!.dataSyncConfirmRollback);
                          if (confirmed == true && context.mounted) {
                            showNotification(context, Api.rollbackData());
                          }
                        },
                      ),
                    ],
                  ),
                )),
            Flexible(
                flex: 3,
                child: devices.isEmpty
                    ? bluetoothState == BluetoothState.discovering
                        ? const Center(child: Loading())
                        : const NoData()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 36),
                        itemBuilder: (context, index) {
                          if (index < devices.length) {
                            final device = devices[index];
                            return ButtonSettingItem(
                              title: Text(device.name ?? AppLocalizations.of(context)!.tagUnknown),
                              subtitle: Text(device.address),
                              onTap: () => showNotification(context, startConnection(device)),
                              trailing: Icon(device.isConnected
                                  ? Icons.import_export
                                  : device.bonded
                                      ? Icons.link
                                      : null),
                            );
                          } else {
                            return const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Loading());
                          }
                        },
                        itemCount: bluetoothState == BluetoothState.discovering ? devices.length + 1 : devices.length)),
          ],
        ),
      BluetoothState.withoutPermission => Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.dataSyncTipPermission,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              TVFilledButton(
                  autofocus: true,
                  onPressed: () => Bluetooth.openSettings(),
                  child: Text(
                    AppLocalizations.of(context)!.dataSyncActionOpenSettings,
                  ))
            ],
          ),
        ),
      BluetoothState.nonAdaptor =>
        Center(child: Text(AppLocalizations.of(context)!.dataSyncTipNonBluetoothAdapter, style: Theme.of(context).textTheme.displaySmall)),
    });
  }

  startDiscovery() {
    setState(() {
      devices.clear();
      bluetoothState = BluetoothState.discovering;
    });
    if (subscription != null) {
      subscription!.cancel();
    }
    Bluetooth.getBondedDevices().then((value) => setState(() => devices.addAll(value)));
    subscription = Bluetooth.startDiscovery().listen(
        (device) {
          final index = devices.indexWhere((element) => element.address == device.address);
          if (index >= 0) {
            devices[index] = device;
          } else {
            devices.add(device);
          }
          setState(() {});
        },
        onError: (error) {},
        onDone: () {
          setState(() => bluetoothState = BluetoothState.withPermission);
        });
  }

  Future<void> startConnection(BluetoothDevice device) async {
    await Bluetooth.connect(device.address);
    await Bluetooth.write(BluetoothMessage.text(appVersion));
    final resp = await Bluetooth.connection().first;
    switch (resp.type) {
      case BlueToothMessageType.text:
        final remoteVersion = Version.fromString(resp.data);
        final localVersion = Version.fromString(appVersion);
        if (localVersion > remoteVersion) {
          await Bluetooth.disconnect();
          if (mounted) throw Exception(AppLocalizations.of(context)!.dataSyncTipOutOfDate(device.name ?? ''));
        } else {
          await Bluetooth.write(BluetoothMessage.file((await Api.databasePath())!));
        }
      case BlueToothMessageType.file:
        if (mounted) throw Exception(AppLocalizations.of(context)!.dataSyncTipSyncError);
    }
  }
}
