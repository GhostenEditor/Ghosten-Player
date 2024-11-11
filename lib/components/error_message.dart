import 'package:api/api.dart';
import 'package:bluetooth/bluetooth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'gap.dart';

class ErrorMessage<T> extends StatelessWidget {
  final AsyncSnapshot<T> snapshot;
  final Widget? leading;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;

  const ErrorMessage({super.key, required this.snapshot, this.leading, this.safeArea = true, this.padding});

  @override
  Widget build(BuildContext context) {
    final exception = _toCommonException(context, snapshot.error!);
    final child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leading != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: leading!,
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(exception.message, style: Theme.of(context).textTheme.titleMedium),
                if (kDebugMode && exception.detail?.isNotEmpty == true) ...[Gap.vLG, Text(exception.detail!)],
                if (kDebugMode && exception.error?.toString().isNotEmpty == true) ...[Gap.vLG, if (exception.error != null) Text(exception.error.toString())],
              ],
            ),
          ),
        ),
      ],
    );
    if (safeArea) {
      if (padding != null) {
        return SingleChildScrollView(
          child: SafeArea(child: Padding(padding: padding!, child: child)),
        );
      } else {
        return SingleChildScrollView(child: SafeArea(child: child));
      }
    } else {
      if (padding != null) {
        return SingleChildScrollView(child: Padding(padding: padding!, child: child));
      } else {
        return SingleChildScrollView(child: child);
      }
    }
  }

  CommonException _toCommonException(BuildContext context, Object error) {
    return switch (snapshot.error) {
      _ when error is DioException => switch (error.type) {
          DioExceptionType.connectionTimeout || DioExceptionType.sendTimeout || DioExceptionType.receiveTimeout => CommonException(
              message: 'HTTP Request Timeout',
              detail: 'URL: ${error.requestOptions.path}',
            ),
          DioExceptionType.badCertificate => CommonException(
              message: 'HTTP Bad Certificate',
              detail: 'URL: ${error.requestOptions.path}',
            ),
          DioExceptionType.cancel => CommonException(
              message: 'HTTP Has Been Canceled',
              detail: 'URL: ${error.requestOptions.path}',
            ),
          DioExceptionType.connectionError => CommonException(
              message: 'HTTP Connection Error',
              detail: 'URL: ${error.requestOptions.path}',
            ),
          DioExceptionType.badResponse || DioExceptionType.unknown => CommonException(
              message: 'HTTP ${error.response?.statusCode}',
              detail: 'URL: ${error.requestOptions.path}',
              error: error.response?.data,
            ),
        },
      _ when error is ApiException => CommonException(
          message: error.message ?? '',
          detail: error.details,
        ),
      _ when error is BluetoothException => switch (error.type) {
          BluetoothExceptionType.connectTimeout => CommonException(
              message: AppLocalizations.of(context)!.errorTextConnectTimeout,
              detail: AppLocalizations.of(context)!.errorTextConnectTimeoutHelper,
            ),
          BluetoothExceptionType.nonAdaptor => CommonException(
              message: AppLocalizations.of(context)!.errorTextNoBluetoothAdaptor,
            ),
        },
      _ when error is RollbackDataException => CommonException(
          message: AppLocalizations.of(context)!.errorTextNoDataToRollback,
        ),
      _ when error is StoragePermissionException => CommonException(
          message: AppLocalizations.of(context)!.errorTextNoStoragePermission,
        ),
      _ => CommonException(message: error.toString(), error: snapshot.stackTrace.toString())
    };
  }
}

class CommonException implements Exception {
  final String message;
  final String? detail;
  final dynamic error;

  const CommonException({required this.message, this.detail, this.error});
}
