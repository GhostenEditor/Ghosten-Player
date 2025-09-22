import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  Future<bool?> initialized() async {
    final port = await _methodChannel.invokeMethod<int>('initialized');
    if (port != null) {
      baseUrl = baseUrl.replace(port: port);
      return true;
    }
    return false;
  }

  @override
  Future<String?> arch() async {
    return _methodChannel.invokeMethod('arch');
  }

  @override
  Future<void> syncData(String filePath) => _methodChannel.invokeMethod('syncData', filePath);

  @override
  Future<void> rollbackData() => _methodChannel
      .invokeMethod('rollbackData')
      .catchError((_) => throw PlatformException(code: rollbackDataExceptionCode));

  @override
  Future<void> resetData() => _methodChannel.invokeMethod('resetData');

  @override
  Future<void> log(int level, String message) =>
      _methodChannel.invokeMethod('log', {'level': level, 'message': message});

  @override
  Future<void> requestStoragePermission() async {
    final permit = await _methodChannel.invokeMethod('requestStoragePermission');
    if (permit != true) {
      throw PlatformException(code: storagePermissionExceptionCode);
    }
  }

  @override
  Future<void> requestStorageManagePermission() async {
    final permit = await _methodChannel.invokeMethod('requestStorageManagePermission');
    if (permit != true) {
      throw PlatformException(code: storagePermissionExceptionCode);
    }
  }

  /// Session Start

  @override
  Future<SessionCreate> sessionCreate() async {
    final data = await client.put<Json>('/session/create');
    final id = data!['id'];
    final ip = await _methodChannel.invokeMethod<String>('getLocalIpAddress');
    return SessionCreate(
      id: id,
      uri: baseUrl.replace(host: ip, path: '/session/webpage', queryParameters: {'id': id.toString()}),
    );
  }

  /// Session End

  /// Driver Start

  @override
  Stream<dynamic> driverInsert(Json data) async* {
    final resp = await client.put<Json>('/driver/insert/cb', data: data);
    final eventChannel = EventChannel('$_pluginNamespace/update/${resp!['id']}');
    yield* eventChannel.receiveBroadcastStream().map((event) => jsonDecode(event));
  }

  /// Driver End

  /// Miscellaneous Start

  @override
  Future<UpdateData?> checkUpdate(String updateUrl, bool prerelease, Version currentVersion) async {
    if (!Platform.isAndroid) {
      return null;
    }
    final res = await Dio(BaseOptions(connectTimeout: const Duration(seconds: 30))).get(updateUrl);
    final Iterable<UpdateResp> data = (res.data as List<dynamic>)
        .cast<Json>()
        .map(UpdateResp.fromJson)
        .where((el) => prerelease || !el.prerelease);

    final latest = data.first;
    final suffix = switch (appFlavor) {
      'tv' => '-tv',
      _ => '',
    };
    final arch = await this.arch();
    final url = latest.assets.firstWhereOrNull((item) => item.name == 'app-$arch$suffix-release.apk')?.url;
    if (url != null && currentVersion < latest.version) {
      return UpdateData(
        url: url,
        version: latest.version,
        comment: data
            .where((el) => el.version > currentVersion)
            .map((el) => '## v${el.version}\n${el.comment}')
            .join('\n'),
        createAt: latest.createAt,
      );
    } else {
      return null;
    }
  }

  @override
  Stream<List<NetworkDiagnotics>> networkDiagnostics() async* {
    final data = await client.post<Json>('/network/diagnostics/cb');
    final eventChannel = EventChannel('$_pluginNamespace/update/${data!['id']}');
    yield* eventChannel.receiveBroadcastStream().map(
      (event) => (jsonDecode(event) as List<dynamic>).map((item) => NetworkDiagnotics.fromJson(item)).toList(),
    );
  }

  /// Miscellaneous End

  /// Cast Start
  @override
  Stream<List<dynamic>> dlnaDiscover() async* {
    final data = await client.post<Json>('/dlna/discover/cb');
    final eventChannel = EventChannel('$_pluginNamespace/update/${data!['id']}');
    yield* eventChannel.receiveBroadcastStream().map((event) => jsonDecode(event) as List<dynamic>);
  }

  ///  Cast End
}

class Client extends ApiClient {
  const Client(this._methodChannel);

  final MethodChannel _methodChannel;

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
                        }),
                      ).toString().substring(1)
                    : jsonEncode(data)
              : '',
          'params': jsonEncode({
            'acceptLanguage': Localizations.localeOf(navigatorKey.currentState!.context).languageCode,
          }),
        })
        .timeout(const Duration(seconds: 30))
        .then((value) {
          if (value?.isNotEmpty ?? false) {
            try {
              return jsonDecode(value!) as T;
            } catch (e) {
              return null;
            }
          } else {
            return null;
          }
        })
        .catchError(
          (error) {
            throw PlatformException(code: '40800', message: (error as TimeoutException).message);
          },
          test: (error) {
            return error is TimeoutException;
          },
        );
  }
}
