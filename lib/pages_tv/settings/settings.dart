import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../const.dart';
import '../../pages/settings/settings_server.dart';
import '../../providers/user_config.dart';
import '../../utils/utils.dart';
import '../components/setting.dart';
import '../utils/notification.dart';
import '../utils/utils.dart';
import 'settings_about.dart';
import 'settings_account.dart';
import 'settings_diagnotics.dart';
import 'settings_dns.dart';
import 'settings_downloader.dart';
import 'settings_library.dart';
import 'settings_log.dart';
import 'settings_player.dart';
import 'settings_player_history.dart';
import 'settings_sync.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userConfig = Provider.of<UserConfig>(context, listen: true);

    return SettingPage(
      title: AppLocalizations.of(context)!.settingsTitle,
      child: ListView(padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32), children: [
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemAccount),
          leading: const Icon(Icons.account_box_outlined),
          autofocus: true,
          onTap: () => navigateToSlideLeft(context, const SettingsAccountPage()),
        ),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemTV),
          leading: const Icon(Icons.tv),
          onTap: () => navigateToSlideLeft(context, LibraryManage(title: AppLocalizations.of(context)!.settingsItemTV, type: LibraryType.tv)),
        ),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemMovie),
          leading: const Icon(Icons.movie_creation_outlined),
          onTap: () => navigateToSlideLeft(context, LibraryManage(title: AppLocalizations.of(context)!.settingsItemMovie, type: LibraryType.movie)),
        ),
        const DividerSettingItem(),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemPlayerHistory),
          leading: const Icon(Icons.history_rounded),
          onTap: () => navigateToSlideLeft(context, const SystemSettingsPlayerHistory()),
        ),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemPlayerSettings),
          leading: const Icon(Icons.play_circle_outline),
          onTap: () => navigateToSlideLeft(context, const SystemSettingsPlayer()),
        ),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemDownload),
          leading: const Icon(Icons.download_outlined),
          onTap: () => navigateToSlideLeft(context, const SystemSettingsDownloader()),
        ),
        const DividerSettingItem(),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemLanguage),
          leading: const Icon(Icons.language),
          trailing: Text(AppLocalizations.of(context)!.systemLanguage(userConfig.language.name)),
          onTap: () => navigateToSlideLeft(context, const SettingsLanguagePage()),
        ),
        const DividerSettingItem(),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemDNS),
          leading: const Icon(Icons.dns_outlined),
          onTap: () => navigateToSlideLeft(context, const SystemSettingsDNS()),
        ),
        if (alphaVersion)
          ButtonSettingItem(
            title: Text(AppLocalizations.of(context)!.settingsItemServer),
            leading: const Icon(Icons.storage_outlined),
            trailing: const Badge(label: Text('Alpha')),
            onTap: () => navigateToSlideLeft(context, const SystemSettingsServer()),
          ),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemDataSync),
          leading: const Icon(Icons.sync),
          onTap: () => navigateTo(navigatorKey.currentContext!, const SettingsSyncPage()),
        ),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemDataReset),
          leading: const Icon(Icons.restart_alt),
          onTap: () async {
            final confirmed = await showConfirm(context, AppLocalizations.of(context)!.confirmTextResetData);
            if (confirmed == true && context.mounted) {
              await showNotification(context, Api.resetData(), successText: AppLocalizations.of(context)!.modalNotificationResetSuccessText);
            }
          },
        ),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemLog),
          leading: const Icon(Icons.article_outlined),
          onTap: () => navigateToSlideLeft(context, const SettingsLogPage()),
        ),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemNetworkDiagnotics),
          leading: const Icon(Icons.rule_rounded),
          onTap: () => navigateToSlideLeft(context, const SettingsDiagnotics()),
        ),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemInfo),
          leading: const Icon(Icons.info_outline),
          onTap: () => navigateToSlideLeft(context, const SettingsAboutPage()),
        ),
      ]),
    );
  }
}

class SettingsLanguagePage extends StatelessWidget {
  const SettingsLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userConfig = Provider.of<UserConfig>(context, listen: true);

    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemLanguage,
      child: ListView(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
          children: SystemLanguage.values
              .map((language) => RadioSettingItem(
                    autofocus: language == userConfig.language,
                    value: language,
                    groupValue: userConfig.language,
                    title: Text(AppLocalizations.of(context)!.systemLanguage(language.name)),
                    onChanged: (language) {
                      if (language != null) userConfig.setLanguage(language);
                    },
                  ))
              .toList()),
    );
  }
}

class SettingsThemePage extends StatelessWidget {
  const SettingsThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userConfig = Provider.of<UserConfig>(context, listen: true);

    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemTheme,
      child: ListView(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
        children: ThemeMode.values
            .map((theme) => RadioSettingItem(
                  value: theme,
                  groupValue: userConfig.themeMode,
                  title: Text(AppLocalizations.of(context)!.systemTheme(theme.name)),
                  onChanged: (theme) {
                    if (theme != null) userConfig.setTheme(theme);
                  },
                ))
            .toList(),
      ),
    );
  }
}
