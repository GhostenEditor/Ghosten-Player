import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'file_picker_dialog.dart';
import 'file_picker_platform_interface.dart';
import 'models.dart';

class MethodChannelFilePicker extends FilePickerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('com.ghosten.file_picker');

  @override
  Future<String?> get externalStoragePath => methodChannel.invokeMethod<String>('externalStoragePath');

  @override
  Future<String?> get moviePath => methodChannel.invokeMethod<String>('moviePath');

  @override
  Future<String?> get musicPath => methodChannel.invokeMethod<String>('musicPath');

  @override
  Future<String?> get downloadPath => methodChannel.invokeMethod<String>('downloadPath');

  @override
  Future<String?> get cachePath => methodChannel.invokeMethod<String>('cachePath');

  @override
  Future<List<UsbStorage>?> get externalUsbStorages => methodChannel
      .invokeMethod<List<dynamic>>('externalUsbStorages')
      .then((s) => s?.map(UsbStorage.fromJson).toList());

  @override
  Future<bool> requestStoragePermission() async {
    return await methodChannel.invokeMethod<bool>('requestStoragePermission') ?? false;
  }

  @override
  Future<T?> showFilePicker<T>(
    BuildContext context, {
    String? title,
    Widget? empty,
    String? rootPath,
    Widget Function(AsyncSnapshot<List<T>>)? errorBuilder,
    required Widget Function(
      BuildContext context,
      T item, {
      required VoidCallback onPage,
      required ValueChanged<T?> onSubmit,
      required VoidCallback onRefresh,
      T? groupValue,
    })
    childBuilder,
    required FilePickerType type,
    required Future<List<T>> Function(T? id) onFetch,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (context) => FilePickerDialog(
          title: title,
          empty: empty,
          onFetch: onFetch,
          errorBuilder: errorBuilder,
          childBuilder: childBuilder,
        ),
      ),
    );
  }
}
