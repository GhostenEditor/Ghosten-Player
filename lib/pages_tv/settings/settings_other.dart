import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/user_config.dart';
import '../../utils/utils.dart';
import '../components/setting.dart';
import '../components/text_field_focus.dart';
import '../utils/notification.dart';
import '../utils/utils.dart';
import 'settings_dns.dart';
import 'settings_shortcut.dart';
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
          FutureBuilder(
            future: Api.settingScraperQuery(),
            builder: (context, snapshot) {
              final data = snapshot.data;
              return data != null
                  ? _ScraperSettingSection(
                    settingScraper: data,
                    onChanged: (SettingScraper value) async {
                      await Api.settingScraperUpdate(value);
                      if (context.mounted) setState(() {});
                    },
                  )
                  : const SizedBox();
            },
          ),
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
                await showNotification(
                  context,
                  Api.resetData(),
                  successText: AppLocalizations.of(context)!.modalNotificationResetSuccessText,
                );
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
          ListTile(title: Text(AppLocalizations.of(context)!.settingsItemShortcutSettings), dense: true),
          ButtonSettingItem(
            title: Text(AppLocalizations.of(context)!.settingsItemShortcuts),
            leading: const Icon(Icons.shortcut_rounded),
            onTap: () => navigateToSlideLeft(context, const SystemSettingsShortcut()),
          ),
        ],
      ),
    );
  }
}

class SettingsScraperBehaviorPage extends StatefulWidget {
  const SettingsScraperBehaviorPage({super.key, required this.behavior});

  final ScraperBehavior behavior;

  @override
  State<SettingsScraperBehaviorPage> createState() => _SettingsScraperBehaviorPageState();
}

class _SettingsScraperBehaviorPageState extends State<SettingsScraperBehaviorPage> {
  late ScraperBehavior behavior = widget.behavior;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(behavior);
        }
      },
      child: SettingPage(
        title: AppLocalizations.of(context)!.settingsItemScraperBehavior,
        child: ListView(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
          children:
              ScraperBehavior.values
                  .map(
                    (be) => RadioSettingItem(
                      autofocus: behavior == be,
                      value: be,
                      groupValue: behavior,
                      title: Text(AppLocalizations.of(context)!.scraperBehavior(be.name)),
                      onChanged: (be) {
                        if (be != null) {
                          behavior = be;
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

class SettingsLanguagePage extends StatelessWidget {
  const SettingsLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userConfig = Provider.of<UserConfig>(context);

    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemLanguage,
      child: ListView(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
        children:
            SystemLanguage.values
                .map(
                  (language) => RadioSettingItem(
                    autofocus: language == userConfig.language,
                    value: language,
                    groupValue: userConfig.language,
                    title: Text(AppLocalizations.of(context)!.systemLanguage(language.name)),
                    onChanged: (language) {
                      if (language != null) userConfig.setLanguage(language);
                    },
                  ),
                )
                .toList(),
      ),
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
        children:
            ThemeMode.values
                .map(
                  (theme) => RadioSettingItem(
                    value: theme,
                    groupValue: userConfig.themeMode,
                    title: Text(AppLocalizations.of(context)!.systemTheme(theme.name)),
                    onChanged: (theme) {
                      if (theme != null) userConfig.setTheme(theme);
                    },
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _ScraperSettingSection extends StatefulWidget {
  const _ScraperSettingSection({required this.settingScraper, required this.onChanged});

  final ValueChanged<SettingScraper> onChanged;

  final SettingScraper settingScraper;

  @override
  State<_ScraperSettingSection> createState() => _ScraperSettingSectionState();
}

class _ScraperSettingSectionState extends State<_ScraperSettingSection> {
  late final _controller1 = TextEditingController(text: widget.settingScraper.tmdbMaxCast.toString());
  late final _controller2 = TextEditingController(text: widget.settingScraper.tmdbMaxCrew.toString());

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(title: Text(AppLocalizations.of(context)!.settingsItemScraperSettings), dense: true),
        ButtonSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemScraperSettings),
          subtitle: Text(AppLocalizations.of(context)!.settingsItemScraperBehaviorDescription),
          trailing: Text(
            AppLocalizations.of(
              context,
            )!.scraperBehavior(ScraperBehavior.fromString(widget.settingScraper.behavior.name).name),
          ),
          onTap: () async {
            final behavior = await navigateToSlideLeft<ScraperBehavior>(
              context,
              SettingsScraperBehaviorPage(behavior: widget.settingScraper.behavior),
            );
            if (context.mounted && behavior != null) {
              widget.onChanged(widget.settingScraper.copyWith(behavior: behavior));
            }
          },
        ),
        SwitchSettingItem(
          title: Badge(label: const Text('Alpha'), child: Text(AppLocalizations.of(context)!.settingsItemNfoEnabled)),
          value: widget.settingScraper.nfoEnabled,
          onChanged: (nfoEnabled) {
            widget.onChanged(widget.settingScraper.copyWith(nfoEnabled: nfoEnabled));
          },
        ),
        SwitchSettingItem(
          title: Text(AppLocalizations.of(context)!.settingsItemTmdbEnabled),
          value: widget.settingScraper.tmdbEnabled,
          onChanged: (tmdbEnabled) {
            widget.onChanged(widget.settingScraper.copyWith(tmdbEnabled: tmdbEnabled));
          },
        ),
        ButtonSettingItem(
          title: const Text('TMDB Max Cast Members'),
          trailing: SizedBox(
            width: 50,
            child: TextFieldFocus(
              child: TextField(
                controller: _controller1,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ),
        ButtonSettingItem(
          title: const Text('TMDB Max Crew Members'),
          trailing: SizedBox(
            width: 50,
            child: TextFieldFocus(
              child: TextField(
                controller: _controller2,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ),
        const DividerSettingItem(),
      ],
    );
  }
}
