import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsItemOthers)),
      body: ListView(
        children: [
          ListTile(title: Text(AppLocalizations.of(context)!.settingsItemPlayerSettings), dense: true),
          SwitchListTile(
            value: userConfig.autoPlay,
            title: Text(AppLocalizations.of(context)!.settingsItemAutoPlay),
            onChanged: userConfig.setAutoPlay,
          ),
          SwitchListTile(
            value: userConfig.autoForceLandscape,
            title: Text(AppLocalizations.of(context)!.settingsItemAutoForceLandscape),
            onChanged: userConfig.setAutoForceLandscape,
          ),
          SwitchListTile(
            value: userConfig.autoPip,
            title: Text(AppLocalizations.of(context)!.settingsItemAutoPip),
            subtitle: Text(AppLocalizations.of(context)!.settingsItemAutoPipTip),
            onChanged: userConfig.setAutoPip,
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
              },
            ),
          ),
          _buildPopupMenuItem(
            title: AppLocalizations.of(context)!.settingsItemLanguage,
            icon: Icons.language,
            trailing: AppLocalizations.of(context)!.systemLanguage(userConfig.language.name),
            onSelected: userConfig.setLanguage,
            itemBuilder:
                (BuildContext context) =>
                    SystemLanguage.values
                        .map(
                          (language) => CheckedPopupMenuItem(
                            value: language,
                            checked: userConfig.language == language,
                            child: Text(AppLocalizations.of(context)!.systemLanguage(language.name)),
                          ),
                        )
                        .toList(),
          ),
          _buildPopupMenuItem(
            title: AppLocalizations.of(context)!.settingsItemTheme,
            icon: Icons.light_mode_outlined,
            trailing: AppLocalizations.of(context)!.systemTheme(userConfig.themeMode.name),
            onSelected: userConfig.setTheme,
            itemBuilder:
                (BuildContext context) =>
                    ThemeMode.values
                        .map(
                          (theme) => CheckedPopupMenuItem(
                            value: theme,
                            checked: userConfig.themeMode == theme,
                            child: Text(AppLocalizations.of(context)!.systemTheme(theme.name)),
                          ),
                        )
                        .toList(),
          ),
          const Divider(),
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
                await showNotification(
                  context,
                  Api.resetData(),
                  successText: AppLocalizations.of(context)!.modalNotificationResetSuccessText,
                );
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
        _buildPopupMenuItem(
          title: AppLocalizations.of(context)!.settingsItemScraperBehavior,
          subtitle: AppLocalizations.of(context)!.settingsItemScraperBehaviorDescription,
          icon: Icons.light_mode_outlined,
          trailing: AppLocalizations.of(context)!.scraperBehavior(widget.settingScraper.behavior.name),
          onSelected: (behavior) {
            widget.onChanged(widget.settingScraper.copyWith(behavior: behavior));
          },
          itemBuilder:
              (BuildContext context) =>
                  ScraperBehavior.values
                      .map(
                        (behavior) => CheckedPopupMenuItem(
                          value: behavior,
                          checked: widget.settingScraper.behavior == behavior,
                          child: Text(AppLocalizations.of(context)!.scraperBehavior(behavior.name)),
                        ),
                      )
                      .toList(),
        ),
        SwitchListTile(
          title: Badge(label: const Text('Alpha'), child: Text(AppLocalizations.of(context)!.settingsItemNfoEnabled)),
          value: widget.settingScraper.nfoEnabled,
          onChanged: (nfoEnabled) {
            widget.onChanged(widget.settingScraper.copyWith(nfoEnabled: nfoEnabled));
          },
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)!.settingsItemTmdbEnabled),
          value: widget.settingScraper.tmdbEnabled,
          onChanged: (tmdbEnabled) {
            widget.onChanged(widget.settingScraper.copyWith(tmdbEnabled: tmdbEnabled));
          },
        ),
        ListTile(
          title: const Text('TMDB Max Cast Members'),
          trailing: SizedBox(
            width: 50,
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
              onTapOutside: _onTapOutside,
            ),
          ),
        ),
        ListTile(
          title: const Text('TMDB Max Crew Members'),
          trailing: SizedBox(
            width: 50,
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
              onTapOutside: _onTapOutside,
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  void _onTapOutside(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
    final tmdbMaxCast = int.tryParse(_controller1.text);
    final tmdbMaxCrew = int.tryParse(_controller2.text);
    widget.onChanged(widget.settingScraper.copyWith(tmdbMaxCast: tmdbMaxCast, tmdbMaxCrew: tmdbMaxCrew));
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
