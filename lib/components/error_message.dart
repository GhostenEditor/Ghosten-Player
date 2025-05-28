import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    super.key,
    required this.error,
    this.leading,
    this.safeArea = true,
    this.padding,
    this.minHeight,
  });

  final Object? error;
  final Widget? leading;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final exception = _toCommonException(context);
    final child = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (leading != null) Padding(padding: const EdgeInsets.all(8.0), child: leading),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyMedium!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Text(exception.code, style: Theme.of(context).textTheme.titleMedium),
                  if (kDebugMode && (exception.details?.toString().isNotEmpty ?? false))
                    Text(exception.details.toString()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (safeArea) {
      if (padding != null) {
        return SingleChildScrollView(child: SafeArea(child: Padding(padding: padding!, child: child)));
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

  CommonException _toCommonException(BuildContext context) {
    return switch (error) {
      final PlatformException error => CommonException(
        code: AppLocalizations.of(context)!.errorCode(error.code, error.message as Object? ?? ''),
        message: error.message,
        details: AppLocalizations.of(context)!.errorDetails(error.code, error.message as Object? ?? ''),
        stackTrace: error.stacktrace == null ? null : StackTrace.fromString(error.stacktrace!),
      ),
      _ => CommonException(code: error.toString()),
    };
  }
}

class CommonException implements Exception {
  const CommonException({required this.code, this.message, this.details, this.stackTrace});

  final String code;
  final String? message;
  final dynamic details;
  final StackTrace? stackTrace;
}
