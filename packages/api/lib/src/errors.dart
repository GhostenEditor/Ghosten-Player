import 'dart:async';

import 'package:flutter/services.dart';

class RollbackDataException implements Exception {}

class StoragePermissionException implements Exception {}

enum ApiExceptionType {
  multiChoices,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  timeout,
  internalError,
  unknown;

  static ApiExceptionType fromCode(String code) {
    return switch (code) {
      '300' => ApiExceptionType.multiChoices,
      '400' => ApiExceptionType.badRequest,
      '401' => ApiExceptionType.unauthorized,
      '403' => ApiExceptionType.forbidden,
      '404' => ApiExceptionType.notFound,
      '408' => ApiExceptionType.timeout,
      '500' => ApiExceptionType.internalError,
      _ => ApiExceptionType.unknown,
    };
  }
}

class ApiException implements Exception {
  final ApiExceptionType type;
  final String? message;
  final dynamic details;
  final StackTrace? stackTrace;

  const ApiException({
    required this.type,
    required this.message,
    required this.details,
    this.stackTrace,
  });

  ApiException.fromPlatformException(PlatformException exception)
      : type = ApiExceptionType.fromCode(exception.code),
        message = exception.message,
        details = exception.details,
        stackTrace = exception.stacktrace == null ? null : StackTrace.fromString(exception.stacktrace!);

  ApiException.fromTimeoutException(TimeoutException exception)
      : type = ApiExceptionType.timeout,
        message = 'Timeout',
        details = exception.message,
        stackTrace = null;
}
