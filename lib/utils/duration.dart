import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

extension DurationExtension on Duration {
  String fromNowFormat(BuildContext context) {
    if (isNegative) {
      return '-${(this * -1).fromNowFormat(context)}';
    }
    if (inDays > 0) {
      final int inYears = (inDays / 365).floor();
      final int inMonths = (inDays / 30).floor();
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

  String toDisplay({bool showHour = false}) {
    if (showHour) {
      return '$inHours:${inMinutes.remainder(60).toString().padLeft(2, '0')}:${inSeconds.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return '${inMinutes.remainder(60).toString().padLeft(2, '0')}:${inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
  }
}
