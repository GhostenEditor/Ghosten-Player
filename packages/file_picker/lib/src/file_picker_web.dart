import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'file_picker_dialog.dart';
import 'file_picker_platform_interface.dart';
import 'models.dart';

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
  }) async {
    switch (type) {
      case FilePickerType.remote:
        return Navigator.of(context).push<T>(
          MaterialPageRoute(
            builder: (context) => FilePickerDialog(
              title: title,
              empty: empty,
              onFetch: onFetch,
              childBuilder: childBuilder,
              errorBuilder: errorBuilder,
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
