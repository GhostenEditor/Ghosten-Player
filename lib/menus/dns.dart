import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/utils.dart';
import 'abstract.dart';

class DNSMenu extends Menu {
  const DNSMenu(this.item);

  final DNSOverride item;

  @override
  List<Widget> build(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(Icons.edit_outlined),
        title: Text(AppLocalizations.of(context)!.buttonEdit),
        onTap: () => context.pushNamed(.settingsDnsEdit, arguments: item),
      ),
      buildDeleteAction(context, () => showNotification(context, Api.dnsOverrideDeleteById(item.id))),
    ];
  }
}
