import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'api_platform_interface.dart';
import 'models.dart';

class ApiWeb extends ApiPlatform {
  ApiWeb();

  static void registerWith(Registrar registrar) {
    ApiPlatform.instance = ApiWeb();
  }

  @override
  late final Client client = Client(baseUrl);

  /// Session Start
  @override
  @override
  Future<SessionCreate> sessionCreate() async {
    final data = await client.put('/session/create');
    final id = data['id'];
    return SessionCreate(id: id, uri: baseUrl.replace(path: '/session/webpage', queryParameters: {'id': id.toString()}));
  }

  /// Session End

  /// Library Start

  @override
  Future<void> libraryRefreshById(int id) async {
    final data = await client.post('/library/refresh/id/cb', data: {'id': id});
    final sessionId = data['id'];
    Stream<double?> s() async* {
      loop:
      while (true) {
        try {
          final session = await sessionStatus(sessionId);
          switch (session.status) {
            case SessionStatus.progressing:
              yield session.data['progress'];
            case SessionStatus.finished:
              yield 1;
              break loop;
            case SessionStatus.failed:
              yield -1;
              break loop;
            case SessionStatus.created:
            case SessionStatus.data:
          }
        } catch (e) {
          yield null;
          rethrow;
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }
      await Future.delayed(const Duration(milliseconds: 3000));
      yield null;
    }

    ApiPlatform.streamController.addStream(s());
  }

  /// Library End

  /// Cast Start
  @override
  Stream<dynamic> dlnaDiscover() async* {
    final data = await client.post<JsonList>('/dlna/discover/cb');
    yield* Stream.fromIterable(data!);
  }

  ///  Cast End
}

class Client extends ApiClient {
  late final Dio _client;

  Client(Uri baseUrl) {
    _client = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      baseUrl: baseUrl.toString(),
      validateStatus: (status) => status != null && status >= 200 && status < 300 || status == 304,
    ))
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options..headers.putIfAbsent('content-type', () => 'application/json'));
        },
        onError: (error, handler) {
          handler.reject(error);
        },
      ))
      ..interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        options.headers['Accept-Language'] = Localizations.localeOf(navigatorKey.currentContext!).languageCode;
        return handler.next(options);
      }));
  }

  @override
  Future<T?> delete<T>(String path, {Object? data}) {
    return _client.delete<T>(path, data: data).then((resp) => resp.data);
  }

  @override
  Future<T?> get<T>(String path, {Json? queryParameters}) {
    return _client.get<T>(path, queryParameters: queryParameters).then((resp) => resp.data);
  }

  @override
  Future<T?> post<T>(String path, {Object? data}) {
    return _client.post<T>(path, data: data).then((resp) => resp.data);
  }

  @override
  Future<T?> put<T>(String path, {Object? data}) {
    return _client.put<T>(path, data: data).then((resp) => resp.data);
  }
}
