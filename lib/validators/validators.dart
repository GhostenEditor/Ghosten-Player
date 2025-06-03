import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

String? yearValidator(BuildContext context, String? value) {
  if (value != null && value.isNotEmpty) {
    final year = int.tryParse(value);
    if (year == null || year < 1900 || year > 2100) {
      return AppLocalizations.of(context)!.formValidatorYear;
    }
  }
  return null;
}

String? requiredValidator(BuildContext context, String? value) {
  if (value == null || value.isEmpty) {
    return AppLocalizations.of(context)!.formValidatorRequired;
  }
  return null;
}

String? urlValidator(BuildContext context, String? value, [bool required = false]) {
  if (required && (value == null || value.isEmpty)) {
    return AppLocalizations.of(context)!.formValidatorRequired;
  } else {
    if (RegExp(r'^https?://[a-zA-Z0-9\-.]+\.[a-zA-Z0-9\-.]{2,}(:[0-9]{1,5})?(/\S*)?$').hasMatch(value!)) {
      return null;
    } else if (RegExp(r'^driver?://(\d{1,3})(/\S*)?$').hasMatch(value)) {
      return null;
    } else {
      return AppLocalizations.of(context)!.formValidatorUrl;
    }
  }
}
