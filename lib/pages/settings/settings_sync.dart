import 'dart:async';

import 'package:api/api.dart';
import 'package:bluetooth/bluetooth.dart';
import 'package:flutter/material.dart' hide PopupMenuItem;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/no_data.dart';
import '../../components/popup_menu.dart';
import '../../const.dart';
import '../../utils/notification.dart';

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
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settingsItemDataSync),
          actions: [
            if (bluetoothState == BluetoothState.withPermission || bluetoothState == BluetoothState.discovering)
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    title: Text(AppLocalizations.of(context)!.dataSyncActionRescanBluetoothDevices),
                    leading: const Icon(Icons.sync),
                    onTap: () => startDiscovery(),
                  ),
                  PopupMenuItem(
                    title: Text(AppLocalizations.of(context)!.dataSyncActionSetDiscoverable),
                    leading: const Icon(Icons.remove_red_eye_outlined),
                    onTap: () => Bluetooth.requestDiscoverable(const Duration(seconds: 60)),
                  ),
                  PopupMenuItem(
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
          ],
        ),
        body: switch (bluetoothState) {
          BluetoothState.withPermission || BluetoothState.discovering => Column(
              children: [
                bluetoothState == BluetoothState.discovering ? const LinearProgressIndicator() : const SizedBox(height: 4),
                Expanded(
                  child: (bluetoothState != BluetoothState.discovering && devices.isEmpty)
                      ? const NoData()
                      : ListView(
                          children: [
                            ...devices.map((device) => ListTile(
                                  title: Text(device.name ?? AppLocalizations.of(context)!.tagUnknown),
                                  subtitle: Text(device.address),
                                  onTap: () => showNotification(context, startConnection(device)),
                                  trailing: Icon(device.isConnected
                                      ? Icons.import_export
                                      : device.bonded
                                          ? Icons.link
                                          : null),
                                ))
                          ],
                        ),
                ),
              ],
            ),
          BluetoothState.withoutPermission => Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AppLocalizations.of(context)!.dataSyncTipPermission),
                  ),
                  FilledButton(onPressed: () => Bluetooth.openSettings(), child: Text(AppLocalizations.of(context)!.dataSyncActionOpenSettings))
                ],
              ),
            ),
          BluetoothState.nonAdaptor => Center(child: Text(AppLocalizations.of(context)!.dataSyncTipNonBluetoothAdapter)),
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
