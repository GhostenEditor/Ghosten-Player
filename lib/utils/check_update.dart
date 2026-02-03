import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../const.dart';
import '../platform_api.dart';

final currentVersion = Version.fromString(appVersion);

Future<UpdateData?> checkUpdate(bool prerelease) async {
  if (!Platform.isAndroid) {
    return null;
  }
  final res = await Dio(BaseOptions(connectTimeout: const Duration(seconds: 30))).get(updateUrl);
  final Iterable<UpdateResp> data = (res.data as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(UpdateResp.fromJson)
      .where((el) => prerelease || !el.prerelease);

  final latest = data.first;
  final suffix = switch (appFlavor) {
    'tv' => '-tv',
    _ => '',
  };
  final arch = await PlatformApi.arch();
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

class Version {
  const Version(this.major, this.minor, this.patch, {this.alpha, this.beta});

  Version.unknown() : major = 0, minor = 0, patch = 0, alpha = null, beta = null;

  factory Version.fromString(String s) {
    final arr = s.split('-');
    final pre = arr.elementAtOrNull(0);
    final suf = arr.elementAtOrNull(1);
    if (pre == null) {
      return Version.unknown();
    } else {
      final list = pre.split('.');
      if (list.length != 3) {
        return Version.unknown();
      }
      final major = int.tryParse(list[0]);
      final minor = int.tryParse(list[1]);
      final patch = int.tryParse(list[2]);
      if (major == null || minor == null || patch == null) {
        return Version.unknown();
      }
      int? a;
      int? b;
      if (suf != null) {
        if (suf.startsWith('alpha.')) {
          a = int.tryParse(suf.substring(6));
        }
        if (suf.startsWith('beta.')) {
          b = int.tryParse(suf.substring(5));
        }
      }
      return Version(major, minor, patch, alpha: a, beta: b);
    }
  }

  final int major;
  final int minor;
  final int patch;
  final int? alpha;
  final int? beta;

  @override
  String toString() {
    if (alpha != null) {
      return '$major.$minor.$patch-alpha.$alpha';
    }
    if (beta != null) {
      return '$major.$minor.$patch-beta.$beta';
    }
    return '$major.$minor.$patch';
  }

  bool isPrerelease() {
    return alpha != null || beta != null;
  }

  double toDouble() {
    double d = patch + minor * 1000.0 + major * 1000000.0;
    if (alpha != null || beta != null) {
      d -= 1;
    }
    if (alpha != null) {
      d += (alpha! + 1) / 1000000.0;
    }
    if (beta != null) {
      d += (beta! + 1) / 1000.0;
    }
    return d;
  }

  bool operator >(Version other) {
    return toDouble() > other.toDouble();
  }

  bool operator <(Version other) {
    return toDouble() < other.toDouble();
  }
}

class UpdateData {
  const UpdateData({required this.url, required this.version, required this.comment, this.createAt});

  final DateTime? createAt;
  final Version version;
  final String comment;
  final String url;
}

class UpdateResp {
  UpdateResp.fromJson(Map<String, dynamic> json)
    : assets = List.generate(
        (json['assets'] as List).length,
        (index) => UpdateRespAsset.fromJson((json['assets'] as List).elementAt(index)),
      ),
      version = Version.fromString((json['tag_name'] as String).substring(1)),
      tagName = json['tag_name'],
      comment = json['body'],
      prerelease = json['prerelease'],
      createAt = DateTime.tryParse(json['published_at'] as String);
  final List<UpdateRespAsset> assets;
  final DateTime? createAt;
  final Version version;
  final String tagName;
  final String comment;
  final bool prerelease;
}

class UpdateRespAsset {
  UpdateRespAsset.fromJson(Map<String, dynamic> json) : name = json['name'], url = json['browser_download_url'];
  final String name;
  final String url;
}
