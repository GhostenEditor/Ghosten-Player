import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_config.dart';
import '../../utils/utils.dart';
import '../components/setting.dart';
import '../utils/utils.dart';
import 'settings_update.dart';

class SettingsAboutPage extends StatefulWidget {
  const SettingsAboutPage({super.key});

  @override
  State<SettingsAboutPage> createState() => _SettingsAboutPageState();
}

class _SettingsAboutPageState extends State<SettingsAboutPage> {
  late final _userConfig = Provider.of<UserConfig>(context);

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemInfo,
      child: ListView(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
        children: [
          ButtonSettingItem(
            autofocus: true,
            title: Text(AppLocalizations.of(context)!.checkForUpdates),
            onTap: () => navigateTo(navigatorKey.currentContext!, const SettingsUpdate()),
          ),
          ButtonSettingItem(
            title: Text(AppLocalizations.of(context)!.autoCheckForUpdates),
            subtitle: Text(AppLocalizations.of(context)!.autoUpdateFrequency(_userConfig.autoUpdateFrequency.name)),
            onTap: () async {
              final flag = await navigateToSlideLeft<bool>(context, const SettingsAutoCheckForUpdatesPage());
              if ((flag ?? false) && context.mounted) setState(() {});
            },
          ),
          SwitchSettingItem(
            value: _userConfig.updatePrerelease,
            onChanged: (value) {
              _userConfig.setUpdatePrerelease(value);
              setState(() {});
            },
            title: Text(AppLocalizations.of(context)!.updatePrerelease),
          ),
          ButtonSettingItem(
            title: Text(AppLocalizations.of(context)!.githubProxy),
            subtitle: Text(
              _userConfig.githubProxy.isNotEmpty ? _userConfig.githubProxy : AppLocalizations.of(context)!.none,
            ),
            onTap: () async {
              final flag = await navigateToSlideLeft<bool>(context, const SettingsGithubProxy());
              if ((flag ?? false) && context.mounted) setState(() {});
            },
          ),
          ButtonSettingItem(
            title: const Text(appName),
            subtitle: const Text(appVersion),
            trailing: const Text(buildDate),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class SettingsAutoCheckForUpdatesPage extends StatefulWidget {
  const SettingsAutoCheckForUpdatesPage({super.key});

  @override
  State<SettingsAutoCheckForUpdatesPage> createState() => _SettingsAutoCheckForUpdatesPageState();
}

class _SettingsAutoCheckForUpdatesPageState extends State<SettingsAutoCheckForUpdatesPage> {
  bool refresh = false;

  @override
  Widget build(BuildContext context) {
    final userConfig = Provider.of<UserConfig>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(refresh);
      },
      child: SettingPage(
        title: AppLocalizations.of(context)!.autoCheckForUpdates,
        child: ListView(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
          children:
              AutoUpdateFrequency.values
                  .map(
                    (item) => RadioSettingItem(
                      autofocus: item == userConfig.autoUpdateFrequency,
                      value: item,
                      groupValue: userConfig.autoUpdateFrequency,
                      title: Text(AppLocalizations.of(context)!.autoUpdateFrequency(item.name)),
                      onChanged: (item) {
                        if (item != null) {
                          userConfig.setAutoUpdate(item);
                          refresh = true;
                          setState(() {});
                        }
                      },
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

class SettingsGithubProxy extends StatefulWidget {
  const SettingsGithubProxy({super.key});

  @override
  State<SettingsGithubProxy> createState() => _SettingsGithubProxyState();
}

class _SettingsGithubProxyState extends State<SettingsGithubProxy> {
  bool refresh = false;

  @override
  Widget build(BuildContext context) {
    final userConfig = Provider.of<UserConfig>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(refresh);
      },
      child: SettingPage(
        title: AppLocalizations.of(context)!.githubProxy,
        child: ListView(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
          children:
              ['', 'https://gh-proxy.com/']
                  .map(
                    (item) => RadioSettingItem(
                      autofocus: item == userConfig.githubProxy,
                      value: item,
                      groupValue: userConfig.githubProxy,
                      title: Text(item.isNotEmpty ? item : AppLocalizations.of(context)!.none),
                      onChanged: (item) {
                        if (item != null) {
                          userConfig.setGithubProxy(item);
                          refresh = true;
                          setState(() {});
                        }
                      },
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
