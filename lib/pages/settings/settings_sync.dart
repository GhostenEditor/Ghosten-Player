import 'dart:async';

import 'package:api/api.dart';
import 'package:bluetooth/bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/no_data.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../utils/notification.dart';

class SettingsSyncPage extends StatefulWidget {
  const SettingsSyncPage({super.key});

  @override
  State<SettingsSyncPage> createState() => _SettingsSyncPageState();
}

enum BluetoothState { withPermission, withoutPermission, discovering, nonAdaptor }

class _SettingsSyncPageState extends State<SettingsSyncPage> {
  final _devices = <BluetoothDevice>[];
  StreamSubscription<BluetoothDevice>? _subscription;
  BluetoothState _bluetoothState = BluetoothState.withoutPermission;
  bool _needStartServer = true;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _needStartServer = false;
    Bluetooth.close().catchError((_) {});
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      if (await Bluetooth.requestPermission() && await Bluetooth.requestEnable()) {
        setState(() => _bluetoothState = BluetoothState.withPermission);
        _startServer();
        _startDiscovery();
      }
    } catch (e) {
      setState(() => _bluetoothState = BluetoothState.nonAdaptor);
    }
  }

  void _startServer() {
    Bluetooth.startServer().listen(
      (device) async {
        Bluetooth.connection().listen((resp) async {
          switch (resp.type) {
            case BlueToothMessageType.file:
              await Bluetooth.disconnect();
              if (mounted) {
                final confirmed = await showConfirm(
                  context,
                  AppLocalizations.of(
                    context,
                  )!.dataSyncConfirmSync(device.name ?? AppLocalizations.of(context)!.tagUnknown),
                );
                if (confirmed ?? false) {
                  Api.syncData(resp.data);
                }
              }
            case BlueToothMessageType.text:
              Bluetooth.write(BluetoothMessage.text(appVersion));
          }
        });
      },
      onError: (error) {
        if (mounted) {
          showNotification(context, Future.error(error));
        }
      },
      onDone: () {
        if (_needStartServer) _startServer();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsItemDataSync),
        actions: [
          if (_bluetoothState == BluetoothState.withPermission || _bluetoothState == BluetoothState.discovering)
            PopupMenuButton(
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      padding: EdgeInsets.zero,
                      onTap: () => _startDiscovery(),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(AppLocalizations.of(context)!.dataSyncActionRescanBluetoothDevices),
                        leading: const Icon(Icons.sync),
                      ),
                    ),
                    PopupMenuItem(
                      padding: EdgeInsets.zero,
                      onTap: () => Bluetooth.requestDiscoverable(const Duration(seconds: 60)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(AppLocalizations.of(context)!.dataSyncActionSetDiscoverable),
                        leading: const Icon(Icons.remove_red_eye_outlined),
                      ),
                    ),
                    PopupMenuItem(
                      padding: EdgeInsets.zero,
                      onTap: () async {
                        final flag = await showConfirm(context, AppLocalizations.of(context)!.dataSyncConfirmRollback);
                        if ((flag ?? false) && context.mounted) {
                          showNotification(context, Api.rollbackData());
                        }
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(AppLocalizations.of(context)!.dataSyncActionRollback),
                        leading: const Icon(Icons.settings_backup_restore),
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body: switch (_bluetoothState) {
        BluetoothState.withPermission || BluetoothState.discovering => Column(
          children: [
            if (_bluetoothState == BluetoothState.discovering)
              const LinearProgressIndicator()
            else
              const SizedBox(height: 4),
            Expanded(
              child:
                  (_bluetoothState != BluetoothState.discovering && _devices.isEmpty)
                      ? const NoData()
                      : ListView(
                        children: [
                          ..._devices.map(
                            (device) => ListTile(
                              title: Text(device.name ?? AppLocalizations.of(context)!.tagUnknown),
                              subtitle: Text(device.address),
                              onTap: () => showNotification(context, _startConnection(device)),
                              trailing: Icon(
                                device.isConnected
                                    ? Icons.import_export
                                    : device.bonded
                                    ? Icons.link
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
        BluetoothState.withoutPermission => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(AppLocalizations.of(context)!.dataSyncTipPermission),
              ),
              FilledButton(
                onPressed: () => Bluetooth.openSettings(),
                child: Text(AppLocalizations.of(context)!.dataSyncActionOpenSettings),
              ),
            ],
          ),
        ),
        BluetoothState.nonAdaptor => Center(child: Text(AppLocalizations.of(context)!.dataSyncTipNonBluetoothAdapter)),
      },
    );
  }

  void _startDiscovery() {
    setState(() {
      _devices.clear();
      _bluetoothState = BluetoothState.discovering;
    });
    if (_subscription != null) {
      _subscription!.cancel();
    }
    Bluetooth.getBondedDevices().then((value) => setState(() => _devices.addAll(value)));
    _subscription = Bluetooth.startDiscovery().listen(
      (device) {
        final index = _devices.indexWhere((element) => element.address == device.address);
        if (index >= 0) {
          _devices[index] = device;
        } else {
          _devices.add(device);
        }
        setState(() {});
      },
      onError: (error) {},
      onDone: () {
        setState(() => _bluetoothState = BluetoothState.withPermission);
      },
    );
  }

  Future<void> _startConnection(BluetoothDevice device) async {
    await Bluetooth.connect(device.address);
    await Bluetooth.write(BluetoothMessage.text(appVersion));
    final resp = await Bluetooth.connection().first;
    switch (resp.type) {
      case BlueToothMessageType.text:
        final remoteVersion = Version.fromString(resp.data);
        final localVersion = Version.fromString(appVersion);
        if (localVersion > remoteVersion) {
          await Bluetooth.disconnect();
          if (mounted) {
            throw PlatformException(
              message: AppLocalizations.of(context)!.dataSyncTipOutOfDate(device.name ?? ''),
              code: '',
            );
          }
        } else {
          await Bluetooth.write(BluetoothMessage.file((await Api.databasePath())!));
        }
      case BlueToothMessageType.file:
        if (mounted) throw PlatformException(message: AppLocalizations.of(context)!.dataSyncTipSyncError, code: '');
    }
  }
}
