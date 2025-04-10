import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'file_picker_dialog.dart';
import 'file_picker_platform_interface.dart';
import 'models.dart';

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
    return path.callMethod<JSPromise>('videoDir'.toJS).toDart.then((data) => data?.dartify() as String?);
  }

  @override
  Future<String?> get musicPath {
    final path = globalContext.getProperty<JSObject>('__TAURI__'.toJS).getProperty<JSObject>('path'.toJS);
    return path.callMethod<JSPromise>('audioDir'.toJS).toDart.then((data) => data?.dartify() as String?);
  }

  @override
  Future<String?> get cachePath {
    final path = globalContext.getProperty<JSObject>('__TAURI__'.toJS).getProperty<JSObject>('path'.toJS);
    return path.callMethod<JSPromise>('cacheDir'.toJS).toDart.then((data) => data?.dartify() as String?);
  }

  @override
  Future<bool> requestStoragePermission() async => true;

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
    }) childBuilder,
    required FilePickerType type,
    required Future<List<T>> Function(T? id) onFetch,
  }) async {
    switch (type) {
      case FilePickerType.remote:
        return Navigator.of(context).push<T>(MaterialPageRoute(
            builder: (context) => FilePickerDialog(
                  title: title,
                  empty: empty,
                  onFetch: onFetch,
                  childBuilder: childBuilder,
                  errorBuilder: errorBuilder,
                )));
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
            .then((data) => data?.dartify() as T);

        if (path != null) {
          throw UnimplementedError();
        } else {
          return null;
        }
    }
  }
}
