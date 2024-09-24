import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'file_picker_method_channel.dart';
import 'models.dart';

abstract class FilePickerPlatform extends PlatformInterface {
  FilePickerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FilePickerPlatform _instance = MethodChannelFilePicker();

  static FilePickerPlatform get instance => _instance;

  static set instance(FilePickerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> get externalStoragePath => throw UnimplementedError('externalStoragePath() has not been implemented.');

  Future<String?> get moviePath => throw UnimplementedError('moviePath() has not been implemented.');

  Future<String?> get musicPath => throw UnimplementedError('musicPath() has not been implemented.');

  Future<String?> get downloadPath => throw UnimplementedError('downloadPath() has not been implemented.');

  Future<String?> get cachePath => throw UnimplementedError('cachePath() has not been implemented.');

  Future<bool> requestStoragePermission() {
    throw UnimplementedError('requestStoragePermission() has not been implemented.');
  }

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
    }) childBuilder,
    required FilePickerType type,
    required Future<List<T>> Function(T? id) onFetch,
  }) {
    throw UnimplementedError('showFilePicker() has not been implemented.');
  }
}
