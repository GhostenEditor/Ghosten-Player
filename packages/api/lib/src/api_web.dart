import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../api.dart';
import 'api_platform_interface.dart';
import 'fake_data.dart';

class ApiWeb extends ApiPlatform {
  ApiWeb();

  static void registerWith(Registrar registrar) {
    ApiPlatform.instance = ApiWeb();
  }

  @override
  late final Client client = Client();

  @override
  Future<void> resetData() {
    throw forbiddenException;
  }

  /// Session Start
  @override
  @override
  Future<SessionCreate> sessionCreate() async {
    return SessionCreate(id: '', uri: baseUrl.replace(path: '/session/webpage', queryParameters: {'id': ''}));
  }

  /// Session End

  /// Driver Start

  @override
  Stream<dynamic> driverInsert(Json data) async* {
    throw forbiddenException;
  }

  /// Driver End

  /// Library Start

  @override
  Future<void> libraryRefreshById(dynamic id, bool incremental, String behavior) async {
    await Future.delayed(Duration(seconds: 1));
    Stream<double?> s() async* {
      yield 0.2;
      await Future.delayed(Duration(seconds: 1));
      yield 0.4;
      await Future.delayed(Duration(seconds: 1));
      yield 0.6;
      await Future.delayed(Duration(seconds: 1));
      yield 0.8;
      await Future.delayed(Duration(seconds: 1));
      yield 1;
      await Future.delayed(Duration(seconds: 3));
      yield null;
    }

    ApiPlatform.streamController.addStream(s());
  }

  /// Library End

  /// Miscellaneous Start
  @override
  Stream<List<NetworkDiagnotics>> networkDiagnostics() async* {
    final items = [
      {'domain': 'openapi.alipan.com', 'ip': '***.***.***.***', 'status': 'success'},
      {'domain': 'api.themoviedb.org', 'ip': '***.***.***.***', 'status': 'success'},
      {'domain': 'image.tmdb.org', 'ip': '***.***.***.***', 'status': 'success'},
      {'domain': 'drive-pc.quark.cn', 'ip': '***.***.***.***', 'status': 'success'}
    ];
    await Future.delayed(Duration(seconds: 2));
    yield items.take(1).map(NetworkDiagnotics.fromJson).toList();
    await Future.delayed(Duration(seconds: 1));
    yield items.take(2).map(NetworkDiagnotics.fromJson).toList();
    await Future.delayed(Duration(seconds: 1));
    yield items.take(3).map(NetworkDiagnotics.fromJson).toList();
    await Future.delayed(Duration(seconds: 1));
    yield items.take(4).map(NetworkDiagnotics.fromJson).toList();
  }

  /// Miscellaneous End

  /// Cast Start
  @override
  Stream<List<dynamic>> dlnaDiscover() async* {
    await Future.delayed(Duration(seconds: 1));
    yield [
      {'id': '1', 'friendlyName': '投屏设备'}
    ];
  }

  ///  Cast End
}

final forbiddenException = PlatformException(code: '40301');

class Client extends ApiClient {
  @override
  Future<T?> delete<T>(String path, {Object? data}) async {
    return switch (path) {
      _ => throw forbiddenException,
    };
  }

  @override
  Future<T?> get<T>(String path, {Json? queryParameters}) async {
    return switch (path) {
      '/session/status' => {
          'status': 'created',
          'data': '',
        },
      '/file/info' => {
          'filename': '展示文件.mp4',
          'driverType': 'webdav',
          'createAt': DateTime.now().subtract(Duration(days: 20)).toString(),
          'size': 1 << 31,
        },
      '/player/history' => episodes
          .where((episode) => episode['lastPlayedTime'] != null)
          .map((episode) => {
                'mediaType': 'episode',
                ...episode,
              })
          .toList(),
      '/playback/info' => {
          'url': 'http://127.0.0.1',
          'subtitles': [],
        },
      '/server/query/all' => servers,
      '/download/task/query/all' => downloadTasks,
      '/playlist/query/all' => playlists,
      '/playlist/channels/query/id' => channels,
      '/tv/recommendation' => series.take(6).toList(),
      '/tv/series/query/all' => series.take(queryParameters?['limit'] ?? 100).toList(),
      '/tv/series/nextToPlay/query/all' => episodes.where((item) => item['lastPlayedTime'] != null).toList(),
      '/tv/series/query/id' => series.firstWhere((el) => el['id'] == 61),
      '/tv/season/query/id' => seasons.firstWhere((el) => el['id'] == queryParameters!['id']),
      '/tv/episode/query/id' => episodes.firstWhere((el) => el['id'] == queryParameters!['id']),
      '/movie/query/all' => movies,
      '/movie/nextToPlay/query/all' => movies.take(2).toList(),
      '/movie/recommendation' => movies,
      '/movie/query/id' => movies[0],
      '/studio/query/all' => studios,
      '/genre/query/all' => genres,
      '/keyword/query/all' => keywords,
      '/cast/query/all' => actors,
      '/crew/query/all' => [],
      '/driver/query/all' => drivers,
      '/driver/setting/query/id' => {
          if (queryParameters!['id'] != 2) 'concurrency': 3,
          if (queryParameters['id'] == 1) 'proxy': true,
          if (queryParameters['id'] != 2) 'sliceSize': 5,
        },
      '/library/query/all' => [
          {
            'driverAvatar': null,
            'driverId': 0,
            'driverName': 'TEST Name',
            'driverType': 'webdav',
            'filename': 'TEST',
            'id': 0,
            'poster': null,
            'type': queryParameters!['type']
          }
        ],
      '/dns/override/query/all' => dns,
      '/log/query/page' => {
          'offset': 0,
          'limit': 50,
          'count': 1,
          'data': [
            {'level': 3, 'time': DateTime.now().toString(), 'message': '这是一条展示用日志！'}
          ]
        },
      _ => null
    } as T?;
    // return null;
  }

  @override
  Future<T?> post<T>(String path, {Object? data}) async {
    switch (path) {
      case '/download/task/pause/id':
        final item = downloadTasks.firstWhere((el) => el['id'] == (data as dynamic)['id']);
        item['speed'] = null;
        item['status'] = 'idle';
      case '/download/task/resume/id':
        final item = downloadTasks.firstWhere((el) => el['id'] == (data as dynamic)['id']);
        item['status'] = 'downloading';
        item['speed'] = 19323377;
      case '/file/list':
        return fileList as T;
      case '/file/rename':
      case '/playlist/update/id':
        throw forbiddenException;
      case '/playlist/refresh/id':
      case '/tv/series/sync/id':
        return Future.delayed(Duration(seconds: 3));
      case '/tv/season/number/update':
        final item = seasons.firstWhere((el) => el['id'] == (data as dynamic)['id']);
        item['season'] = (data as dynamic)['season'];
        return (data as dynamic)['season'];
      case '/skipTime/update':
        final id = (data as dynamic)['id'];
        final type = (data as dynamic)['type'];
        final time = (data as dynamic)['time'];
        final mediaType = MediaType.fromString((data as dynamic)['mediaType']);
        final item = switch (mediaType) {
          MediaType.movie => throw UnimplementedError(),
          MediaType.series => series.firstWhere((el) => el['id'] == id),
          MediaType.season => seasons.firstWhere((el) => el['id'] == id),
          MediaType.episode => episodes.firstWhere((el) => el['id'] == id),
        };
        switch (type) {
          case 'intro':
            item['skipIntro'] = time;
          case 'ending':
            item['skipEnding'] = time;
        }
        item['updateAt'] = DateTime.now().toString();
      case '/markWatched/update':
        final type = MediaType.fromString((data as dynamic)['type']);
        final id = (data as dynamic)['id'];
        final watched = (data as dynamic)['marked'];
        final item = switch (type) {
          MediaType.movie => movies.firstWhere((el) => el['id'] == id),
          MediaType.series => series.firstWhere((el) => el['id'] == id),
          MediaType.season => seasons.firstWhere((el) => el['id'] == id),
          MediaType.episode => episodes.firstWhere((el) => el['id'] == id),
        };
        item['watched'] = watched;
        item['updateAt'] = DateTime.now().toString();
      case '/markFavorite/update':
        final type = MediaType.fromString((data as dynamic)['type']);
        final id = (data as dynamic)['id'];
        final favorite = (data as dynamic)['marked'];
        final item = switch (type) {
          MediaType.movie => movies.firstWhere((el) => el['id'] == id),
          MediaType.series => series.firstWhere((el) => el['id'] == id),
          MediaType.season => seasons.firstWhere((el) => el['id'] == id),
          MediaType.episode => episodes.firstWhere((el) => el['id'] == id),
        };
        item['favorite'] = favorite;
        item['updateAt'] = DateTime.now().toString();
      case '/dns/override/update/id':
        final id = (data as dynamic)['id'];
        final domain = (data as dynamic)['domain'];
        final ip = (data as dynamic)['ip'];
        final item = dns.firstWhere((el) => el['id'] == id);
        item['domain'] = domain;
        item['ip'] = ip;
    }
    return null;
  }

  @override
  Future<T?> put<T>(String path, {Object? data}) async {
    return switch (path) {
      '/file/mkdir' || '/server/insert' || '/playlist/insert' || '/library/insert' || '/dns/override/insert' => throw forbiddenException,
      _ => null,
    };
  }
}
