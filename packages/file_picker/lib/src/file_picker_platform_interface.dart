import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../file_picker.dart';
import 'file_picker_method_channel.dart';

abstract class FilePickerPlatform extends PlatformInterface {
  FilePickerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FilePickerPlatform _instance = MethodChannelFilePicker();

  static FilePickerPlatform get instance => _instance;

  static set instance(FilePickerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> get externalStoragePath =>
      throw UnimplementedError('externalStoragePath() has not been implemented.');

  Future<String?> get moviePath => throw UnimplementedError('moviePath() has not been implemented.');

  Future<String?> get musicPath => throw UnimplementedError('musicPath() has not been implemented.');

  Future<String?> get downloadPath => throw UnimplementedError('downloadPath() has not been implemented.');

  Future<String?> get cachePath => throw UnimplementedError('cachePath() has not been implemented.');

  Future<String?> get filePath => throw UnimplementedError('filePath() has not been implemented.');

  Future<List<UsbStorage>?> externalUsbStorages() {
    throw UnimplementedError('externalUsbStorages() has not been implemented.');
  }

  Future<void> requestStoragePermission() {
    throw UnimplementedError('requestStoragePermission() has not been implemented.');
  }

  Future<void> requestStorageManagePermission() async {
    throw UnimplementedError('requestStoragePermission() has not been implemented.');
  }

  Future<T?> showFilePicker<T>(
    BuildContext context, {
    String? rootPath,
    required FilePickerType type,
    Widget? defaultTitle,
    required Widget Function(T?) titleBuilder,
    required List<Widget> actions,
    required Future<PageData<T>> Function(int) fetchData,
    required ItemWidgetBuilder<T> itemBuilder,
    required FileViewerController<T> controller,
    WidgetBuilder? firstPageProgressIndicatorBuilder,
    WidgetBuilder? newPageProgressIndicatorBuilder,
    WidgetBuilder? noItemsFoundIndicatorBuilder,
    WidgetBuilder? firstPageErrorIndicatorBuilder,
  }) {
    throw UnimplementedError('showFilePicker() has not been implemented.');
  }
}

class UsbStorage {
  // ignore: avoid_dynamic_calls
  UsbStorage.fromJson(dynamic json) : desc = json['desc'], path = json['path'];
  final String desc;
  final String path;
}
