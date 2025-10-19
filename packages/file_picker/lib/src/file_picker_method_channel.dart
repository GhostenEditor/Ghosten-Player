import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
  Future<String?> get filePath => methodChannel.invokeMethod<String>('filePath');

  @override
  Future<List<UsbStorage>?> externalUsbStorages() {
    return methodChannel
        .invokeMethod<List<dynamic>>('externalUsbStorages')
        .then((s) => s?.map(UsbStorage.fromJson).toList());
  }

  @override
  Future<bool> requestStoragePermission() async {
    return await methodChannel.invokeMethod<bool>('requestStoragePermission') ?? false;
  }

  @override
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
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (context) => FilePickerDialog(
          defaultTitle: defaultTitle,
          titleBuilder: titleBuilder,
          actions: actions,
          fetchData: fetchData,
          itemBuilder: itemBuilder,
          controller: controller,
          firstPageProgressIndicatorBuilder: firstPageProgressIndicatorBuilder,
          newPageProgressIndicatorBuilder: newPageProgressIndicatorBuilder,
          noItemsFoundIndicatorBuilder: noItemsFoundIndicatorBuilder,
          firstPageErrorIndicatorBuilder: firstPageErrorIndicatorBuilder,
        ),
      ),
    );
  }
}
