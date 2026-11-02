import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:provider/provider.dart';

import '../adaptive/adaptive.dart';
import '../l10n/app_localizations.dart';
import '../providers/function.dart';
import '../utils/utils.dart';
import 'abstract.dart';

class LibraryMenu extends Menu {
  const LibraryMenu(this.item);

  final Library item;

  @override
  List<Widget> build(BuildContext context) {
    final FunctionConfig function = context.read<FunctionConfig>();
    return [
      if (function.settingsLibrarySync)
        ListTile(
          leading: const Icon(Icons.sync),
          title: Text(AppLocalizations.of(context)!.buttonSyncLibrary),
          enabled: !item.disabled,
          onTap: () => showNotification(
            context,
            Api.libraryRefreshById(item.id, switch (Localizations.localeOf(context).toLanguageTag()) {
              'zh' => SupportedLanguages.zhCn,
              'en' => SupportedLanguages.enUs,
              _ => SupportedLanguages.auto,
            }),
          ),
        ),
      if (function.settingsLibraryDisable)
        if (item.disabled)
          ListTile(
            leading: const Icon(Icons.check_circle_outline_rounded),
            title: const Text('Enable'),
            onTap: () => Api.libraryEnableById(item.id),
          )
        else
          ListTile(
            leading: const Icon(Icons.block_rounded),
            title: const Text('Disable'),
            onTap: () => Api.libraryDisableById(item.id),
          ),
      if (function.settingsLibraryDelete)
        ListTile(
          leading: const Icon(Icons.delete_outline_rounded),
          title: Text(AppLocalizations.of(context)!.buttonDelete),
          onTap: () async {
            final bool? confirmed = await showConfirm(
              context,
              AppLocalizations.of(context)!.deleteConfirmText,
              AppLocalizations.of(context)!.deleteMediaGroupConfirmText,
            );
            if (confirmed == true && context.mounted) {
              await showNotification(context, Api.libraryDeleteById(item.id));
            }
          },
        ),
    ];
  }
}
