import 'dart:async';

import 'package:api/api.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

Future<T?> navigateTo<T extends Object?>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(MaterialPageRoute(builder: (context) => page));
}

Future<T?> navigateToNoTransition<T extends Object?>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    ),
  );
}

extension DateTimeExtension on DateTime {
  String format() {
    return formatDate(this, [yyyy, '-', mm, '-', dd]);
  }

  String formatFull() {
    return formatDate(this, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  }

  String formatFullWithoutSec() {
    return formatDate(this, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]);
  }

  Duration fromNow() {
    return Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - millisecondsSinceEpoch);
  }

  bool operator >=(DateTime other) {
    return microsecondsSinceEpoch >= other.microsecondsSinceEpoch;
  }

  bool operator >(DateTime other) {
    return microsecondsSinceEpoch > other.microsecondsSinceEpoch;
  }

  bool operator <=(DateTime other) {
    return microsecondsSinceEpoch <= other.microsecondsSinceEpoch;
  }

  bool operator <(DateTime other) {
    return microsecondsSinceEpoch < other.microsecondsSinceEpoch;
  }
}

extension IntExtension on int {
  String toSizeDisplay() {
    return switch (this) {
      < 1 << 10 => '$this B',
      < 1 << 20 => '${double.parse((this / (1 << 10)).toStringAsFixed(2))} KB',
      < 1 << 30 => '${double.parse((this / (1 << 20)).toStringAsFixed(2))} MB',
      _ => '${double.parse((this / (1 << 30)).toStringAsFixed(2))} GB',
    };
  }

  String toNetworkSpeed() {
    return '${toSizeDisplay()}/s';
  }
}

extension DurationExtension on Duration {
  String fromNowFormat(BuildContext context) {
    if (isNegative) {
      return '-${(this * -1).fromNowFormat(context)}';
    }
    if (inDays > 0) {
      final inYears = (inDays / 365).floor();
      final inMonths = (inDays / 30).floor();
      if (inYears > 0) {
        return AppLocalizations.of(context)!.unitYear(inYears);
      } else if (inMonths > 0) {
        return AppLocalizations.of(context)!.unitMonth(inMonths);
      } else {
        return AppLocalizations.of(context)!.unitDay(inDays);
      }
    } else if (inHours > 0) {
      return AppLocalizations.of(context)!.unitHour(inHours);
    } else if (inMinutes > 0) {
      return AppLocalizations.of(context)!.unitMinute(inMinutes);
    } else {
      return AppLocalizations.of(context)!.unitSecond(inSeconds);
    }
  }

  String toDisplay() {
    if (inHours > 0) {
      return '$inHours:${inMinutes.remainder(60).toString().padLeft(2, '0')}:${inSeconds.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return '${inMinutes.remainder(60).toString().padLeft(2, '0')}:${inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
  }
}

extension UriExtension on Uri {
  Uri normalize() {
    if (scheme.toLowerCase() == 'file') {
      return this;
    } else {
      return replace(
        scheme: scheme.isEmpty ? Api.baseUrl.scheme : null,
        host: host.isEmpty ? Api.baseUrl.host : null,
        port: port == 0 ? Api.baseUrl.port : null,
      );
    }
  }
}
