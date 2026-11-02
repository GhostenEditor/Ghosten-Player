import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile, SwitchListTile;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_config.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';
import '../providers/function.dart';

class SystemSettingsOther extends StatefulWidget {
  const SystemSettingsOther({super.key});

  @override
  State<SystemSettingsOther> createState() => _SystemSettingsOtherState();
}

class _SystemSettingsOtherState extends State<SystemSettingsOther> {
  @override
  Widget build(BuildContext context) {
    final UserConfig userConfig = context.watch<UserConfig>();
    final FunctionConfig function = context.watch<FunctionConfig>();
    return SettingPage.list(
      title: Text(AppLocalizations.of(context)!.settingsItemOthers),
      children: [
        ListTile(title: Text(AppLocalizations.of(context)!.settingsGroupDisplaySettings), dense: true),
        if (function.settingsDisplaySize)
          ListTile(
            isThreeLine: true,
            title: Text(AppLocalizations.of(context)!.settingsItemDisplaySize),
            subtitle: Slider(
              value: userConfig.displayScale,
              min: 0.75,
              max: 1.25,
              divisions: 10,
              label: '${userConfig.displayScale}x',
              padding: const .symmetric(vertical: 16),
              onChanged: (s) {
                userConfig.setDisplayScale(s);
                setState(() {});
              },
            ),
            leading: const Icon(Icons.abc_rounded),
          ),
        MenuListTile(
          title: Text(AppLocalizations.of(context)!.settingsItemLanguage),
          leading: const Icon(Icons.language),
          trailing: Text(AppLocalizations.of(context)!.supportedLanguage(userConfig.language.name)),
          initialValue: userConfig.language,
          onSelected: userConfig.setLanguage,
          itemBuilder: (context) => SupportedLanguages.values
              .map(
                (language) => CheckedPopupMenuItem(
                  value: language,
                  checked: userConfig.language == language,
                  child: Text(AppLocalizations.of(context)!.supportedLanguage(language.name)),
                ),
              )
              .toList(),
        ),
        MenuListTile(
          title: Text(AppLocalizations.of(context)!.settingsItemTheme),
          leading: const Icon(Icons.light_mode_outlined),
          trailing: Text(AppLocalizations.of(context)!.systemTheme(userConfig.themeMode.name)),
          initialValue: userConfig.themeMode,
          onSelected: userConfig.setTheme,
          itemBuilder: (context) => ThemeMode.values
              .map(
                (theme) => CheckedPopupMenuItem(
                  value: theme,
                  checked: userConfig.themeMode == theme,
                  child: Text(AppLocalizations.of(context)!.systemTheme(theme.name)),
                ),
              )
              .toList(),
        ),
        ListTile(
          title: const Text('主题色'),
          leading: const Icon(Icons.palette_outlined),
          trailing: Container(
            key: ValueKey(userConfig.themeColor),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: CustomPaint(painter: IndicatorPainter(Color(userConfig.themeColor))),
            ),
          ),
          onTap: () async {
            final Color? color = await showModalBottomSheet<Color>(
              context: context,
              useSafeArea: true,
              isScrollControlled: true,
              builder: (context) {
                var color = Color(userConfig.themeColor);
                return EditPage(
                  title: const Text('主题色'),
                  onConfirmButtonPressed: () => Navigator.of(context).pop(color),
                  child: ColorPicker(
                    pickerColor: Color(userConfig.themeColor),
                    paletteType: PaletteType.hsl,
                    onColorChanged: (c) => color = c,
                  ),
                );
              },
            );
            if (color != null) {
              userConfig.setThemeColor(color.toARGB32());
            }
          },
        ),
        const Divider(),
        if (function.menuScrape)
          FutureBuilder(
            future: Api.settingScraperQuery(),
            builder: (context, snapshot) {
              final SettingScraper? data = snapshot.data;
              return data != null
                  ? _ScraperSettingSection(
                      settingScraper: data,
                      onChanged: (SettingScraper value) async {
                        await Api.settingScraperUpdate(value);
                        if (context.mounted) {
                          setState(() {});
                        }
                      },
                    )
                  : const SizedBox();
            },
          ),
        ListTile(title: Text(AppLocalizations.of(context)!.settingsGroupDataSettings), dense: true),
        ListTile(
          title: Text(AppLocalizations.of(context)!.settingsItemDataSync),
          leading: const Icon(Icons.sync),
          onTap: () => context.pushNamed(.settingsSync),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.settingsItemDataReset),
          leading: const Icon(Icons.restart_alt),
          onTap: () async {
            final bool? flag = await showConfirm(context, AppLocalizations.of(context)!.confirmTextResetData);
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
        if (function.settingsDns) ...[
          ListTile(title: Text(AppLocalizations.of(context)!.settingsGroupProxySettings), dense: true),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsItemDNS),
            leading: const Icon(Icons.dns_outlined),
            onTap: () => context.pushNamed(.settingsDns),
          ),
          const Divider(),
        ],
        // MenuListTile(
        //   title: Text(AppLocalizations.of(context)!.githubProxy),
        //   trailing: Text(
        //     userConfig.githubProxy.isNotEmpty ? userConfig.githubProxy : AppLocalizations.of(context)!.none,
        //   ),
        //   onSelected: (value) {
        //     userConfig.setGithubProxy(value);
        //     setState(() {});
        //   },
        //   initialValue: userConfig.githubProxy,
        //   itemBuilder: (BuildContext context) => ['', 'https://gh-proxy.com/']
        //       .map(
        //         (item) => CheckedPopupMenuItem(
        //           checked: item == userConfig.githubProxy,
        //           value: item,
        //           child: Text(item.isNotEmpty ? item : AppLocalizations.of(context)!.none),
        //         ),
        //       )
        //       .toList(),
        // ),
        if (function.settingsShortcuts) ...[
          ListTile(title: Text(AppLocalizations.of(context)!.settingsGroupShortcutSettings), dense: true),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settingsItemShortcuts),
            leading: const Icon(Icons.shortcut_rounded),
            onTap: () => context.pushNamed(.settingsShortcut),
          ),
          const Divider(),
        ],
        SwitchListTile(
          title: const Text('Show Performance Overlay'),
          value: userConfig.showPerformanceOverlay,
          onChanged: (value) {
            userConfig.setShowPerformanceOverlay(value);
            if (context.mounted) {
              setState(() {});
            }
          },
        ),
      ],
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
  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(title: Text(AppLocalizations.of(context)!.settingsItemScraperSettings), dense: true),
        MenuListTile(
          title: Text(AppLocalizations.of(context)!.settingsItemScraperBehavior),
          subtitle: Text(AppLocalizations.of(context)!.settingsItemScraperBehaviorDescription),
          trailing: Text(AppLocalizations.of(context)!.scraperBehavior(widget.settingScraper.behavior.name)),
          initialValue: widget.settingScraper.behavior,
          onSelected: (behavior) => widget.onChanged(widget.settingScraper.copyWith(behavior: behavior)),
          itemBuilder: (BuildContext context) => ScraperBehavior.values
              .map(
                (behavior) => CheckedPopupMenuItem(
                  value: behavior,
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
          onChanged: (tmdbEnabled) => widget.onChanged(widget.settingScraper.copyWith(tmdbEnabled: tmdbEnabled)),
        ),
        ListTile(
          title: const Text('TMDB Max Cast Members'),
          onTap: () => _focusNode1.requestFocus(),
          trailing: SizedBox(
            width: 50,
            child: TextFieldFocus(
              child: TextField(
                controller: _controller1,
                focusNode: _focusNode1,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onTapOutside: _onTapOutside,
              ),
            ),
          ),
        ),
        ListTile(
          title: const Text('TMDB Max Crew Members'),
          onTap: () => _focusNode2.requestFocus(),
          trailing: SizedBox(
            width: 50,
            child: TextFieldFocus(
              child: TextField(
                controller: _controller2,
                focusNode: _focusNode2,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onTapOutside: _onTapOutside,
              ),
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  void _onTapOutside(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
    final int? tmdbMaxCast = int.tryParse(_controller1.text);
    final int? tmdbMaxCrew = int.tryParse(_controller2.text);
    widget.onChanged(widget.settingScraper.copyWith(tmdbMaxCast: tmdbMaxCast, tmdbMaxCrew: tmdbMaxCrew));
  }
}
