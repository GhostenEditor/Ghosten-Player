import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/user_config.dart';
import '../../utils/utils.dart';
import '../utils/notification.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsItemOthers),
      ),
      body: ListView(
        children: [
          ListTile(title: Text(AppLocalizations.of(context)!.settingsItemPlayerSettings), dense: true),
          SwitchListTile(
            value: userConfig.autoPlay,
            title: Text(AppLocalizations.of(context)!.settingsItemAutoPlay),
            onChanged: userConfig.setAutoPlay,
          ),
          const Divider(),
          ListTile(title: Text(AppLocalizations.of(context)!.settingsItemDisplaySettings), dense: true),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsItemDisplaySize),
            leading: const Icon(Icons.abc_rounded),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
                value: userConfig.displayScale,
                min: 0.75,
                max: 1.25,
                divisions: 10,
                label: '${userConfig.displayScale}x',
                onChanged: (s) {
                  userConfig.setDisplayScale(s);
                  setState(() {});
                }),
          ),
          _buildPopupMenuItem(
            title: AppLocalizations.of(context)!.settingsItemLanguage,
            icon: Icons.language,
            trailing: AppLocalizations.of(context)!.systemLanguage(userConfig.language.name),
            onSelected: userConfig.setLanguage,
            itemBuilder: (BuildContext context) => SystemLanguage.values
                .map((language) => CheckedPopupMenuItem(
                      value: language,
                      checked: userConfig.language == language,
                      child: Text(AppLocalizations.of(context)!.systemLanguage(language.name)),
                    ))
                .toList(),
          ),
          _buildPopupMenuItem(
            title: AppLocalizations.of(context)!.settingsItemTheme,
            icon: Icons.light_mode_outlined,
            trailing: AppLocalizations.of(context)!.systemTheme(userConfig.themeMode.name),
            onSelected: userConfig.setTheme,
            itemBuilder: (BuildContext context) => ThemeMode.values
                .map((theme) => CheckedPopupMenuItem(
                      value: theme,
                      checked: userConfig.themeMode == theme,
                      child: Text(AppLocalizations.of(context)!.systemTheme(theme.name)),
                    ))
                .toList(),
          ),
          const Divider(),
          ListTile(title: Text(AppLocalizations.of(context)!.settingsItemScraperSettings), dense: true),
          _buildPopupMenuItem(
            title: AppLocalizations.of(context)!.settingsItemScraperBehavior,
            subtitle: AppLocalizations.of(context)!.settingsItemScraperBehaviorDescription,
            icon: Icons.light_mode_outlined,
            trailing: AppLocalizations.of(context)!.scraperBehavior(_ScraperBehavior.fromString(userConfig.scraperBehavior).name),
            onSelected: (behavior) {
              userConfig.setScraperBehavior(behavior);
              setState(() {});
            },
            itemBuilder: (BuildContext context) => _ScraperBehavior.values
                .map((behavior) => CheckedPopupMenuItem(
                      value: behavior.name,
                      checked: userConfig.scraperBehavior == behavior.name,
                      child: Text(AppLocalizations.of(context)!.scraperBehavior(behavior.name)),
                    ))
                .toList(),
          ),
          const Divider(),
          ListTile(title: Text(AppLocalizations.of(context)!.settingsItemDataSettings), dense: true),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsItemDataSync),
            leading: const Icon(Icons.sync),
            onTap: () => navigateTo(context, const SettingsSyncPage()),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsItemDataReset),
            leading: const Icon(Icons.restart_alt),
            onTap: () async {
              final flag = await showConfirm(context, AppLocalizations.of(context)!.confirmTextResetData);
              if ((flag ?? false) && context.mounted) {
                await showNotification(context, Api.resetData(), successText: AppLocalizations.of(context)!.modalNotificationResetSuccessText);
              }
            },
          ),
          const Divider(),
          ListTile(title: Text(AppLocalizations.of(context)!.settingsItemProxySettings), dense: true),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsItemDNS),
            leading: const Icon(Icons.dns_outlined),
            onTap: () => navigateTo(context, const SystemSettingsDNS()),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenuItem<T>({
    required String title,
    String? subtitle,
    required String trailing,
    IconData? icon,
    PopupMenuItemSelected<T>? onSelected,
    required PopupMenuItemBuilder<T> itemBuilder,
  }) {
    return PopupMenuButton<T>(
      offset: const Offset(1, 0),
      tooltip: '',
      onSelected: onSelected,
      itemBuilder: itemBuilder,
      child: ListTile(
        leading: Icon(icon),
        trailing: Text(trailing),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
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
