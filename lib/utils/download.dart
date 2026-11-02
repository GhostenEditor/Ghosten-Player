import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../platform_api.dart';
import 'utils.dart';

Future<File?> download({
  required String digest,
  required String url,
  required String directory,
  required String filename,
  CancelToken? cancelToken,
  required void Function(double) onProgress,
  required void Function(DioException) onError,
}) async {
  final downloadingPath = '$directory/$digest.downloading';
  final downloadedPath = '$directory/$filename';

  if (!File(downloadedPath).existsSync()) {
    final downloadingFile = File(downloadingPath);
    int downloadedBytes = downloadingFile.existsSync() ? downloadingFile.lengthSync() : 0;
    try {
      PlatformApi.progressNotification('progressCreate', id: 0, title: filename, content: '开始下载', progress: 1);
      final Response<ResponseBody> response = await cacheHttpClient.get<ResponseBody>(
        url,
        cancelToken: cancelToken,
        options: Options(
          headers: {if (downloadedBytes > 0) 'Range': 'bytes=$downloadedBytes-'},
          responseType: ResponseType.stream,
        ),
      );
      final int total = response.data?.contentLength ?? 0;
      final RandomAccessFile raf = await downloadingFile.open(mode: FileMode.append);
      await for (final Uint8List chunk in response.data!.stream) {
        await raf.writeFrom(chunk);
        downloadedBytes += chunk.length;
        if (total > 0) {
          final double progress = downloadedBytes / total;
          onProgress(progress);
          PlatformApi.progressNotification(
            'progressUpdate',
            id: 0,
            title: filename,
            content: '下载中: ${(progress * 100).toStringAsFixed(1)}%',
            progress: progress,
          );
        }
      }
      await raf.close();
      await File(downloadingPath).rename(downloadedPath);
    } on DioException catch (error) {
      PlatformApi.progressNotification('progressFail', id: 0, title: filename, content: '下载失败');
      onError(error);
    }
  }
  final file = File(downloadedPath);
  if (!file.existsSync()) {
    return null;
  }

  final Digest calculatedDigest = await sha256.bind(file.openRead()).first;

  if (digest == 'sha256:$calculatedDigest') {
    PlatformApi.progressNotification('progressComplete', id: 0, title: filename, content: '下载完成');
    return file;
  } else {
    await file.delete();
    PlatformApi.progressNotification('progressFail', id: 0, title: filename, content: '校验失败');
    return null;
  }
}
