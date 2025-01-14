import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../const.dart';
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
  late final userConfig = Provider.of<UserConfig>(context, listen: true);

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemInfo,
      child: ListView(padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32), children: [
        ButtonSettingItem(
          autofocus: true,
          title: Text(AppLocalizations.of(context)!.checkForUpdates),
          onTap: () => navigateTo(navigatorKey.currentContext!, const SettingsUpdate()),
        ),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.autoCheckForUpdates),
          subtitle: Text(AppLocalizations.of(context)!.autoUpdateFrequency(userConfig.autoUpdateFrequency.name)),
          onTap: () async {
            final flag = await navigateToSlideLeft<bool>(context, const SettingsAutoCheckForUpdatesPage());
            if (flag == true && context.mounted) setState(() {});
          },
        ),
        ButtonSettingItem(
          title: const Text(appName),
          subtitle: const Text(appVersion),
          trailing: const Text(buildDate),
          onTap: () {},
        ),
      ]),
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
    final userConfig = Provider.of<UserConfig>(context, listen: true);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pop(refresh);
      },
      child: SettingPage(
        title: AppLocalizations.of(context)!.settingsItemTheme,
        child: ListView(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
          children: AutoUpdateFrequency.values
              .map((item) => RadioSettingItem(
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
                  ))
              .toList(),
        ),
      ),
    );
  }
}
