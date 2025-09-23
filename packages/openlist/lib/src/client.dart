import 'dart:convert';

import 'package:api/api.dart';
import 'package:dio/dio.dart';

import 'openlist_platform_interface.dart';

class OpenlistClient {
  static String? authorization;
  static Dio client = Dio(BaseOptions(baseUrl: 'http://localhost:5244'))
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (authorization == null) {
            try {
              await auth();
            } on DioException catch (e) {
              handler.reject(e);
              return;
            }
          }
          handler.next(options..headers.putIfAbsent('Authorization', () => authorization));
        },
        onResponse: (response, handler) async {
          if (response.statusCode == 200 && response.data['code'] == 401) {
            try {
              await auth();
              handler.resolve(await client.fetch(response.requestOptions));
            } on DioException catch (e) {
              handler.reject(e);
              return;
            }
          } else {
            if (response.data['code'] == 200) {
              handler.resolve(response..data = response.data['data']);
            } else {
              handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  type: DioExceptionType.badResponse,
                  response: response..statusCode = response.data['code'],
                  message: response.data['message'],
                ),
              );
            }
          }
        },
      ),
    );

  static Future<dynamic> auth() async {
    final resp = await Dio(BaseOptions(baseUrl: 'http://localhost:5244')).post(
      '/api/auth/login',
      data: {'username': 'admin', 'password': await OpenlistPlatform.instance.getAdminPassword()},
    );
    if (resp.data['code'] != 200) {
      throw DioException(
        requestOptions: resp.requestOptions,
        type: DioExceptionType.badResponse,
        response: resp..statusCode = resp.data['code'],
        message: resp.data['message'],
      );
    } else {
      authorization = resp.data['data']['token'];
    }
  }

  static Future<List<StorageInfo>> storageList() async {
    final resp = await client.get('/api/admin/storage/list');
    final data = resp.data['content'] as List<dynamic>;
    return List.generate(data.length, (index) => StorageInfo.fromJson(data[index]));
  }

  static Future<dynamic> storageCreate(dynamic data) async {
    final resp = await client.post('/api/admin/storage/create', data: data);
    return resp.data['content'];
  }

  static Future<dynamic> storageUpdate(dynamic data) {
    return client.post('/api/admin/storage/update', data: data);
  }

  static Future<dynamic> storageDelete(int id) {
    return client.post('/api/admin/storage/delete', queryParameters: {'id': id});
  }

  static Future<dynamic> storageToggle(int id, bool disabled) {
    return client.post('/api/admin/storage/${disabled ? 'enable' : 'disable'}', queryParameters: {'id': id});
  }

  static Future<dynamic> storageLoadAll() {
    return client.post('/api/admin/storage/load_all');
  }

  static Future<(List<DriverFile>, int)> fileList({
    String path = '/',
    int? per_page,
    int? page,
    bool refresh = false,
  }) async {
    final resp = await client.post(
      '/api/fs/list',
      data: {'path': path, 'per_page': per_page, 'page': page, 'refresh': refresh},
    );
    final data = resp.data['content'] as List<dynamic>? ?? [];
    return (
      List.generate(
        data.length,
        (index) => DriverFile.fromJson({
          'name': data[index]['name'],
          'category': switch (data[index]['type']) {
            1 => 'folder',
            2 => 'video',
            3 => 'audio',
            4 => 'text',
            5 => 'image',
            _ => 'other',
          },
          'id': data[index]['path'],
          'parentId': '',
          'type': data[index]['is_dir'] ? 'folder' : 'file',
          'createdAt': data[index]['created'],
          'updatedAt': data[index]['modified'],
          'size': data[index]['size'],
          'fileId': data[index]['fileId'],
        }),
      ),
      resp.data['total'] as int,
    );
  }

  static Future<void> fileRename(String name, String path) {
    return client.post('/api/fs/rename', data: {'name': name, 'path': path});
  }

  static Future<void> fileMkdir(String path) {
    return client.post('/api/fs/mkdir', data: {'path': path});
  }

  static Future<void> fileDelete(String dir, List<String> names) {
    return client.post('/api/fs/remove', data: {'dir': dir, 'names': names});
  }

  static Future<List<String>> driverNames() async {
    final resp = await client.get('/api/admin/driver/names');
    return resp.data.cast<String>()..sort();
  }

  static Future<DriverInfo> driverInfo(String driver) async {
    final resp = await client.get('/api/admin/driver/info', queryParameters: {'driver': driver});
    return DriverInfo.fromJson(resp.data);
  }
}

class DriverInfo {
  DriverInfo.fromJson(Json json)
    : common = List.generate(json['common'].length, (index) => DriverInfoItem.fromJson(json['common'][index])),
      additional = List.generate(
        json['additional'].length,
        (index) => DriverInfoItem.fromJson(json['additional'][index]),
      ),
      config = DriverInfoConfig.fromJson(json['config']);
  final List<DriverInfoItem> common;
  final List<DriverInfoItem> additional;
  final DriverInfoConfig config;
}

class DriverInfoConfig {
  DriverInfoConfig.fromJson(Json json)
    : name = json['name'],
      local_sort = json['local_sort'],
      only_local = json['only_local'],
      only_proxy = json['only_proxy'],
      no_cache = json['no_cache'],
      no_upload = json['no_upload'],
      need_ms = json['need_ms'],
      default_root = json['default_root'],
      alert = json['alert'];
  final String name;
  final bool local_sort;
  final bool only_local;
  final bool only_proxy;
  final bool no_cache;
  final bool no_upload;
  final bool need_ms;
  final String default_root;
  final String alert;
}

enum DriverInfoItemType {
  string,
  text,
  number,
  float,
  select,
  bool;

  static DriverInfoItemType fromString(String str) {
    return DriverInfoItemType.values.firstWhere((element) => element.name == str);
  }
}

class DriverInfoItem {
  const DriverInfoItem({
    required this.name,
    required this.type,
    this.default_,
    required this.options,
    required this.required,
    this.help,
  });

  DriverInfoItem.fromJson(Json json)
    : name = json['name'],
      type = DriverInfoItemType.fromString(json['type']),
      default_ = json['default'].isEmpty ? null : json['default'],
      options = json['options'].split(','),
      required = json['required'],
      help = json['help'].isEmpty ? null : json['help'];

  final String name;
  final DriverInfoItemType type;
  final String? default_;
  final List<String> options;
  final bool required;
  final String? help;

  DriverInfoItem copyWith({String? default_, List<String>? options, bool? required, String? help}) {
    return DriverInfoItem(
      name: name,
      type: type,
      default_: default_ ?? this.default_,
      options: options ?? this.options,
      required: required ?? this.required,
      help: help ?? this.help,
    );
  }
}

class StorageInfo {
  StorageInfo.fromJson(Json json)
    : id = json['id'],
      mount_path = json['mount_path'],
      order = json['order'],
      driver = json['driver'],
      cache_expiration = json['cache_expiration'],
      status = json['status'],
      addition = jsonDecode(json['addition']),
      remark = json['remark'],
      modified = json['modified'],
      disabled = json['disabled'],
      enable_sign = json['enable_sign'],
      order_by = json['order_by'],
      order_direction = json['order_direction'],
      extract_folder = json['extract_folder'],
      web_proxy = json['web_proxy'],
      webdav_policy = json['webdav_policy'],
      down_proxy_url = json['down_proxy_url'],
      _rawData = json;
  final int id;
  final String mount_path;
  final int order;
  final String driver;
  final int cache_expiration;
  final String status;
  final dynamic addition;
  final String remark;
  final String modified;
  final bool disabled;
  final bool enable_sign;
  final String order_by;
  final String order_direction;
  final String extract_folder;
  final bool web_proxy;
  final String webdav_policy;
  final String down_proxy_url;
  final dynamic _rawData;

  dynamic get(String key) {
    return _rawData[key];
  }

  dynamic getAddition(String key) {
    return addition[key];
  }
}
