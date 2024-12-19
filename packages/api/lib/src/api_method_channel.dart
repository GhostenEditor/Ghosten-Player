import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

import 'api_platform_interface.dart';
import 'errors.dart';
import 'models.dart';

const _pluginNamespace = 'com.ghosten.player/api';

class MethodChannelApi extends ApiPlatform {
  final _methodChannel = const MethodChannel(_pluginNamespace);

  @override
  late ApiClient client = Client(_methodChannel);

  @override
  Future<String?> databasePath() => _methodChannel.invokeMethod<String>('databasePath');

  @override
  Future<List<HdrType>?> supportedHdrTypes() async {
    final types = await _methodChannel.invokeMethod<List<int>>('supportedHdrTypes');
    return types?.map((t) => HdrType.fromInt(t)).toList();
  }

  @override
  Future<bool?> initialized() => _methodChannel.invokeMethod('initialized');

  @override
  Future<void> syncData(String filePath) => _methodChannel.invokeMethod('syncData', filePath);

  @override
  Future<void> rollbackData() => _methodChannel.invokeMethod('rollbackData').catchError((_) => throw RollbackDataException());

  @override
  Future<void> resetData() => _methodChannel.invokeMethod('resetData');

  @override
  Future<void> log(int level, String message) => _methodChannel.invokeMethod('log', {'level': level, 'message': message});

  @override
  Future<void> requestStoragePermission() async {
    final permit = await _methodChannel.invokeMethod('requestStoragePermission');
    if (permit != true) {
      throw StoragePermissionException();
    }
  }

  /// Session Start

  @override
  Future<SessionCreate> sessionCreate() async {
    final data = await client.put('/session/create');
    final id = data['id'];
    final ip = await _methodChannel.invokeMethod<String>('getLocalIpAddress');
    return SessionCreate(id: id, uri: baseUrl.replace(host: ip, path: '/session/webpage', queryParameters: {'id': id.toString()}));
  }

  /// Session End

  /// Driver Start

  @override
  Stream<dynamic> driverInsert(Json data) async* {
    final resp = await client.put('/driver/insert/cb', data: data);
    final eventChannel = EventChannel('$_pluginNamespace/update/${resp['id']}');
    yield* eventChannel.receiveBroadcastStream().map((event) => jsonDecode(event)).handleError((error) {
      throw ApiException.fromPlatformException(error);
    }, test: (error) => error is PlatformException);
  }

  /// Driver End

  /// Library Start

  @override
  Future<void> libraryRefreshById(int id) async {
    final data = await client.post('/library/refresh/id/cb', data: {'id': id});
    final eventChannel = EventChannel('$_pluginNamespace/update/${data['id']}');

    ApiPlatform.streamController.addStream(eventChannel.receiveBroadcastStream().map((data) => jsonDecode(data)['progress'] as double?).handleError((error) {
      throw ApiException.fromPlatformException(error);
    }, test: (error) => error is PlatformException).concatWith([TimerStream<double?>(null, const Duration(seconds: 3))]).distinct());
  }

  /// Library End

  /// Miscellaneous Start

  @override
  Future<bool> checkUpdate(
    String updateUrl,
    Version currentVersion, {
    required Future<void> Function(UpdateResp data, String url) needUpdate,
  }) async {
    if (!Platform.isAndroid) {
      return true;
    }
    try {
      final res = await Dio(BaseOptions(connectTimeout: const Duration(seconds: 30))).get(updateUrl);
      final data = UpdateResp.fromJson(res.data);
      final url = switch (await _methodChannel.invokeMethod('arch')) {
        'arm64' => data.assets.firstWhereOrNull((item) => item.name == 'app-arm64-v8a-release.apk'),
        _ => data.assets.firstWhereOrNull((item) => item.name == 'app-armeabi-v7a-release.apk'),
      }
          ?.url;
      if (url != null && currentVersion < data.tagName) {
        await needUpdate(data, url);
        return false;
      } else {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<List<NetworkDiagnotics>> networkDiagnostics() async* {
    final data = await client.post('/network/diagnostics/cb');
    final eventChannel = EventChannel('$_pluginNamespace/update/${data['id']}');
    yield* eventChannel
        .receiveBroadcastStream()
        .map((event) => (jsonDecode(event) as List<dynamic>).map((item) => NetworkDiagnotics.fromJson(item)).toList())
        .handleError((error) {
      throw ApiException.fromPlatformException(error);
    }, test: (error) => error is PlatformException);
  }

  /// Miscellaneous End

  /// Cast Start
  @override
  Stream<List<dynamic>> dlnaDiscover() async* {
    final data = await client.post('/dlna/discover/cb');
    final eventChannel = EventChannel('$_pluginNamespace/update/${data['id']}');
    yield* eventChannel.receiveBroadcastStream().map((event) => jsonDecode(event) as List<dynamic>).handleError((error) {
      throw ApiException.fromPlatformException(error);
    }, test: (error) => error is PlatformException);
  }

  ///  Cast End
}

class Client extends ApiClient {
  final MethodChannel _methodChannel;

  const Client(this._methodChannel);

  @override
  Future<T?> delete<T>(String path, {Object? data}) {
    return _send<T>('DELETE', path, data as Json?);
  }

  @override
  Future<T?> get<T>(String path, {Json? queryParameters}) {
    return _send<T>('GET', path, queryParameters);
  }

  @override
  Future<T?> post<T>(String path, {Object? data}) {
    return _send<T>('POST', path, data as Json?);
  }

  @override
  Future<T?> put<T>(String path, {Object? data}) {
    return _send<T>('PUT', path, data as Json?);
  }

  Future<T?> _send<T>(String method, String path, [Json? data]) {
    return _methodChannel
        .invokeMethod<String>(path, {
          'data': data != null
              ? method == 'GET'
                  ? Uri(
                      queryParameters: data.entries.fold({}, (acc, cur) {
                      if (cur.value != null) {
                        acc?[cur.key] = cur.value?.toString();
                      }
                      return acc;
                    })).toString().substring(1)
                  : jsonEncode(data)
              : '',
          'params': jsonEncode({
            'acceptLanguage': Localizations.localeOf(navigatorKey.currentState!.context).languageCode,
          })
        })
        .timeout(const Duration(seconds: 30))
        .then((value) {
          if (value?.isNotEmpty == true) {
            try {
              return jsonDecode(value!) as T;
            } catch (e) {
              return null;
            }
          } else {
            return null;
          }
        })
        .catchError((error) {
          throw ApiException.fromPlatformException(error);
        }, test: (error) {
          return error is PlatformException;
        })
        .catchError((error) {
          throw ApiException.fromTimeoutException(error);
        }, test: (error) {
          return error is TimeoutException;
        });
  }
}
