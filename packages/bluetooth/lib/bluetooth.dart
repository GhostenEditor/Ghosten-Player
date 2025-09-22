import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const bluetoothConnectTimeoutException = '60003';
const bluetoothNonAdaptorException = '60004';

class Bluetooth {
  static const String namespace = 'com.ghosten.bluetooth';
  static const MethodChannel methodChannel = MethodChannel('$namespace/methods');
  static const EventChannel _discoveryChannel = EventChannel('$namespace/discovery');
  static const EventChannel _connectionChannel = EventChannel('$namespace/connection');
  static const EventChannel _connectedChannel = EventChannel('$namespace/connected');

  static Future<bool> requestEnable() async {
    return await methodChannel
            .invokeMethod('requestEnable')
            .catchError((error) => throw PlatformException(code: bluetoothNonAdaptorException)) ??
        false;
  }

  static Stream<BluetoothDevice> startServer() async* {
    await methodChannel.invokeMethod('startServer');
    late StreamSubscription<dynamic> subscription;
    final controller = StreamController(
      onCancel: () {
        subscription.cancel();
      },
    );

    subscription = _connectedChannel.receiveBroadcastStream().listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );

    yield* controller.stream.map((data) => BluetoothDevice.fromMap(data));
  }

  static Future<bool> connect(String address) async {
    return await methodChannel
            .invokeMethod('connect', address)
            .catchError((error) => throw PlatformException(code: bluetoothConnectTimeoutException)) ??
        false;
  }

  static Future<int> requestDiscoverable(Duration duration) async {
    return await methodChannel.invokeMethod('requestDiscoverable', duration.inSeconds) ?? 0;
  }

  static Future<List<BluetoothDevice>> getBondedDevices() async {
    final data = await methodChannel.invokeMethod<List<dynamic>>('getBondedDevices');
    return data!.map((e) => BluetoothDevice.fromMap(e)).toList();
  }

  static Future<bool> requestPermission() async {
    return await methodChannel
            .invokeMethod('requestPermission')
            .catchError((error) => throw PlatformException(code: bluetoothNonAdaptorException)) ??
        false;
  }

  static Stream<BluetoothDevice> startDiscovery() async* {
    await methodChannel.invokeMethod('startDiscovery');
    late StreamSubscription<dynamic> subscription;
    final controller = StreamController(
      onCancel: () {
        subscription.cancel();
      },
    );

    subscription = _discoveryChannel.receiveBroadcastStream().listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );

    yield* controller.stream.map((data) => BluetoothDevice.fromMap(data));
  }

  static Stream<BluetoothMessage> connection() async* {
    late StreamSubscription<dynamic> subscription;
    final controller = StreamController(
      onCancel: () {
        subscription.cancel();
      },
    );

    subscription = _connectionChannel.receiveBroadcastStream().listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );

    yield* controller.stream.map((data) => BluetoothMessage.fromChannel(data));
  }

  static Future<void> disconnect() {
    return methodChannel.invokeMethod('disconnect');
  }

  static Future<void> write(BluetoothMessage data) {
    return switch (data.type) {
      BlueToothMessageType.file => _writeFile(data.data),
      BlueToothMessageType.text => _writeText(data.data),
    };
  }

  static Future<void> _writeText(String data) {
    return methodChannel.invokeMethod('writeText', data);
  }

  static Future<void> _writeFile(String path) {
    return methodChannel.invokeMethod('writeFile', path);
  }

  static Future<void> openSettings() {
    return methodChannel.invokeMethod('openSettings');
  }

  static Future<void> close() {
    return methodChannel.invokeMethod('close');
  }

  static int generateId() {
    return _generatedId++;
  }

  static int _generatedId = 0;
}

enum BluetoothDeviceType {
  classic,
  le,
  dual,
  unknown;

  static BluetoothDeviceType fromInt(int i) {
    return switch (i) {
      0 => BluetoothDeviceType.unknown,
      1 => BluetoothDeviceType.classic,
      2 => BluetoothDeviceType.le,
      3 => BluetoothDeviceType.dual,
      _ => BluetoothDeviceType.unknown,
    };
  }
}

enum BluetoothDeviceBondState {
  none,
  bonding,
  bonded;

  static BluetoothDeviceBondState fromInt(int i) {
    return switch (i) {
      10 => BluetoothDeviceBondState.none,
      11 => BluetoothDeviceBondState.bonding,
      12 => BluetoothDeviceBondState.bonded,
      _ => BluetoothDeviceBondState.none,
    };
  }
}

@immutable
class BluetoothDevice {
  BluetoothDevice.fromMap(Map<dynamic, dynamic> map)
    : name = map['name'],
      address = map['address'],
      isConnected = map['isConnected'],
      type = BluetoothDeviceType.fromInt(map['type']),
      bondState = BluetoothDeviceBondState.fromInt(map['bondState']);
  final String? name;
  final String address;
  final BluetoothDeviceType type;
  final BluetoothDeviceBondState bondState;
  final bool isConnected;

  bool get bonded => bondState == BluetoothDeviceBondState.bonded;

  @override
  bool operator ==(Object other) {
    return other is BluetoothDevice && other.address == address;
  }

  @override
  int get hashCode => address.hashCode;
}

enum BlueToothMessageType {
  file,
  text;

  static BlueToothMessageType fromInt(int i) {
    return switch (i) {
      0 => BlueToothMessageType.text,
      1 => BlueToothMessageType.file,
      _ => BlueToothMessageType.text,
    };
  }
}

class BluetoothMessage {
  BluetoothMessage.fromChannel(List<dynamic> d) : type = BlueToothMessageType.fromInt(d[0]), data = d[1];

  BluetoothMessage.text(String text) : type = BlueToothMessageType.text, data = text;

  BluetoothMessage.file(String filePath) : type = BlueToothMessageType.file, data = filePath;
  final BlueToothMessageType type;
  final String data;
}
