import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/user_config.dart';
import '../../utils/utils.dart';
import '../components/setting.dart';
import '../utils/notification.dart';
import '../utils/utils.dart';
import 'settings_dns.dart';
import 'settings_sync.dart';

class SystemSettingsOther extends StatefulWidget {
  const SystemSettingsOther({super.key});

  @override
  State<SystemSettingsOther> createState() => _SystemSettingsOtherState();
}

class _SystemSettingsOtherState extends State<SystemSettingsOther> {
  late final userConfig = Provider.of<UserConfig>(context);

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemOthers,
      child: ListView(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
        children: [
          ListTile(title: Text(AppLocalizations.of(context)!.settingsItemDisplaySettings), dense: true),
          ButtonSettingItem(
            title: Text(AppLocalizations.of(context)!.settingsItemLanguage),
            leading: const Icon(Icons.language),
            trailing: Text(AppLocalizations.of(context)!.systemLanguage(userConfig.language.name)),
            onTap: () => navigateToSlideLeft(context, const SettingsLanguagePage()),
          ),
          ButtonSettingItem(
            title: Text(AppLocalizations.of(context)!.settingsItemTheme),
            leading: const Icon(Icons.light_mode_outlined),
            trailing: Text(AppLocalizations.of(context)!.systemTheme(userConfig.themeMode.name)),
            onTap: () => navigateToSlideLeft(context, const SettingsThemePage()),
          ),
          const DividerSettingItem(),
          ListTile(title: Text(AppLocalizations.of(context)!.settingsItemScraperSettings), dense: true),
          ButtonSettingItem(
            title: Text(AppLocalizations.of(context)!.settingsItemScraperSettings),
            subtitle: Text(AppLocalizations.of(context)!.settingsItemScraperBehaviorDescription),
            leading: const Icon(Icons.light_mode_outlined),
            trailing: Text(AppLocalizations.of(context)!.scraperBehavior(_ScraperBehavior.fromString(userConfig.scraperBehavior).name)),
            onTap: () async {
              await navigateToSlideLeft(context, const SettingsScraperBehaviorPage());
              if (context.mounted) setState(() {});
            },
          ),
          const DividerSettingItem(),
          ListTile(title: Text(AppLocalizations.of(context)!.settingsItemDataSettings), dense: true),
          ButtonSettingItem(
            title: Text(AppLocalizations.of(context)!.settingsItemDataSync),
            leading: const Icon(Icons.sync),
            onTap: () => navigateTo(navigatorKey.currentContext!, const SettingsSyncPage()),
          ),
          ButtonSettingItem(
            title: Text(AppLocalizations.of(context)!.settingsItemDataReset),
            leading: const Icon(Icons.restart_alt),
            onTap: () async {
              final flag = await showConfirm(context, AppLocalizations.of(context)!.confirmTextResetData);
              if ((flag ?? false) && context.mounted) {
                await showNotification(context, Api.resetData(), successText: AppLocalizations.of(context)!.modalNotificationResetSuccessText);
              }
            },
          ),
          const DividerSettingItem(),
          ListTile(title: Text(AppLocalizations.of(context)!.settingsItemProxySettings), dense: true),
          ButtonSettingItem(
            title: Text(AppLocalizations.of(context)!.settingsItemDNS),
            leading: const Icon(Icons.dns_outlined),
            onTap: () => navigateToSlideLeft(context, const SystemSettingsDNS()),
          ),
        ],
      ),
    );
  }
}

enum _ScraperBehavior {
  skip,
  chooseFirst,
  exact;

  static _ScraperBehavior fromString(String s) {
    return _ScraperBehavior.values.firstWhere((e) => e.name == s);
  }
}

class SettingsScraperBehaviorPage extends StatefulWidget {
  const SettingsScraperBehaviorPage({super.key});

  @override
  State<SettingsScraperBehaviorPage> createState() => _SettingsScraperBehaviorPageState();
}

class _SettingsScraperBehaviorPageState extends State<SettingsScraperBehaviorPage> {
  @override
  Widget build(BuildContext context) {
    final userConfig = Provider.of<UserConfig>(context);

    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemScraperBehavior,
      child: ListView(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
          children: _ScraperBehavior.values
              .map((behavior) => RadioSettingItem(
                    autofocus: behavior == _ScraperBehavior.fromString(userConfig.scraperBehavior),
                    value: behavior,
                    groupValue: _ScraperBehavior.fromString(userConfig.scraperBehavior),
                    title: Text(AppLocalizations.of(context)!.scraperBehavior(behavior.name)),
                    onChanged: (behavior) {
                      if (behavior != null) {
                        userConfig.setScraperBehavior(behavior.name);
                        setState(() {});
                      }
                    },
                  ))
              .toList()),
    );
  }
}

class SettingsLanguagePage extends StatelessWidget {
  const SettingsLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userConfig = Provider.of<UserConfig>(context);

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
    final userConfig = Provider.of<UserConfig>(context);

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
