import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../file_picker.dart';
import 'file_picker_platform_interface.dart';

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
    final path = globalContext.getProperty<JSObject>('__TAURI__'.toJS).getProperty<JSObject>('path'.toJS);
    return path
        .callMethod<JSPromise>('videoDir'.toJS)
        .toDart
        .then((data) => data.dartify() as String?);
  }

  @override
  Future<String?> get musicPath {
    final path = globalContext.getProperty<JSObject>('__TAURI__'.toJS).getProperty<JSObject>('path'.toJS);
    return path
        .callMethod<JSPromise>('audioDir'.toJS)
        .toDart
        .then((data) => data.dartify() as String?);
  }

  @override
  Future<String?> get cachePath {
    final path = globalContext.getProperty<JSObject>('__TAURI__'.toJS).getProperty<JSObject>('path'.toJS);
    return path
        .callMethod<JSPromise>('cacheDir'.toJS)
        .toDart
        .then((data) => data.dartify() as String?);
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
        final dialog = globalContext.getProperty<JSObject>('__TAURI__'.toJS).getProperty<JSObject>('dialog'.toJS);
        final path = await dialog
            .callMethod<JSPromise>(
                'open'.toJS,
                {
                  'directory': true,
                  'defaultPath': rootPath,
                }.jsify())
            .toDart
            .then((data) => data.dartify() as T);

        if (path != null) {
          throw UnimplementedError();
        } else {
          return null;
        }
    }
  }
}
