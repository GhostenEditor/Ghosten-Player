import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

import '../file_picker.dart';
import 'file_picker_platform_interface.dart';

@JS('__TAURI__.dialog.open')
external Object open(Object config);

@JS('__TAURI__.path.videoDir')
external Object videoDir();

@JS('__TAURI__.path.audioDir')
external Object audioDir();

@JS('__TAURI__.path.cacheDir')
external Object cacheDir();

class FilePickerWeb extends FilePickerPlatform {
  FilePickerWeb();

  static void registerWith(Registrar registrar) {
    FilePickerPlatform.instance = FilePickerWeb();
  }

  @override
  Future<String?> get externalStoragePath {
    return moviePath;
  }

  @override
  Future<String?> get moviePath {
    return promiseToFuture<String?>(audioDir());
  }

  @override
  Future<String?> get musicPath {
    return promiseToFuture<String?>(videoDir());
  }

  @override
  Future<String?> get cachePath {
    return promiseToFuture<String?>(cacheDir());
  }

  @override
  Future<bool> requestStoragePermission() async => true;

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
  }) async {
    switch (type) {
      case FilePickerType.remote:
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
      case FilePickerType.local:
        final path = await promiseToFuture<String?>(open(jsify({'directory': true, 'defaultPath': rootPath})));
        if (path != null) {
          throw UnimplementedError();
        } else {
          return null;
        }
    }
  }
}
