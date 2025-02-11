import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                Text(exception.code, style: Theme.of(context).textTheme.titleMedium),
                if (kDebugMode && exception.details?.toString().isNotEmpty == true) ...[
                  Gap.vLG,
                  if (exception.details != null) Text(exception.details.toString())
                ],
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
      _ when error is PlatformException => CommonException(
          code: AppLocalizations.of(context)!.errorCode(error.code, error.message as Object? ?? ''),
          message: error.message,
          details: AppLocalizations.of(context)!.errorDetails(error.code, error.message as Object? ?? ''),
          stackTrace: error.stacktrace == null ? null : StackTrace.fromString(error.stacktrace!),
        ),
      _ => CommonException(code: '0', message: error.toString())
    };
  }
}

class CommonException implements Exception {
  final String code;
  final String? message;
  final dynamic details;
  final StackTrace? stackTrace;

  const CommonException({
    required this.code,
    this.message,
    this.details,
    this.stackTrace,
  });
}
