import 'package:flutter/material.dart' hide ListTile, SwitchListTile;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:video_player/player.dart';

import '../adaptive/adaptive.dart';
import '../l10n/app_localizations.dart';
import '../providers/function.dart';
import '../providers/player.dart';
import '../utils/native_locale_names.dart';
import '../utils/navigator.dart';

class SettingsPlayer extends StatelessWidget {
  const SettingsPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final FunctionConfig function = context.watch<FunctionConfig>();
    final PlayerConfig playerConfig = context.watch<PlayerConfig>();
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return SettingPage.list(
      title: Text(localizations.settingsItemPlayerSettings),
      children: [
        MenuListTile(
          title: Text(AppLocalizations.of(context)!.settingsItemTheme),
          leading: const Icon(Icons.light_mode_outlined),
          trailing: Text(AppLocalizations.of(context)!.systemTheme(playerConfig.themeMode.name)),
          initialValue: playerConfig.themeMode,
          onSelected: playerConfig.setTheme,
          itemBuilder: (context) => ThemeMode.values
              .map(
                (theme) => CheckedPopupMenuItem(
                  value: theme,
                  checked: playerConfig.themeMode == theme,
                  child: Text(AppLocalizations.of(context)!.systemTheme(theme.name)),
                ),
              )
              .toList(),
        ),
        if (function.settingsAutoForceLandscape)
          SwitchListTile(
            value: playerConfig.autoForceLandscape,
            title: Text(localizations.settingsItemAutoForceLandscape),
            onChanged: playerConfig.setAutoForceLandscape,
          ),
        if (function.settingsAutoPip)
          SwitchListTile(
            value: playerConfig.autoPip,
            title: Text(localizations.settingsItemAutoPip),
            subtitle: Text(localizations.settingsItemAutoPipTip),
            onChanged: playerConfig.setAutoPip,
          ),
        SwitchListTile(
          title: Text(localizations.playerShowLiteProgressbar),
          value: playerConfig.showLiteProgressbar,
          onChanged: playerConfig.setShowLiteProgressbar,
        ),
        ListTile(
          title: Text(localizations.settingsItemPlayerKernel),
          trailing: playerConfig.playerType == PlayerType.mpv
              ? Badge(
                  label: const Text('Alpha'),
                  offset: const Offset(0, -14),
                  child: Text(localizations.playerType(playerConfig.playerType.name)),
                )
              : Text(AppLocalizations.of(context)!.playerType(playerConfig.playerType.name)),
          onTap: () => context.pushNamed(.settingsPlayerKernel),
        ),
        if (playerConfig.playerType == PlayerType.media3) ...[
          const Divider(),
          const ListTile(title: Text('Media 3'), dense: true),
          MenuListTile(
            title: Text(localizations.extensionRendererModeLabel),
            trailing: Text(
              localizations.extensionRendererMode(playerConfig.extensionRendererMode.toString()),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
            itemBuilder: (context) => [0, 1, 2]
                .map(
                  (i) => CheckedPopupMenuItem(
                    value: i,
                    checked: playerConfig.extensionRendererMode == i,
                    child: Text(localizations.extensionRendererMode(i.toString())),
                  ),
                )
                .toList(),
            onSelected: playerConfig.setExtensionRendererMode,
          ),
          SwitchListTile(
            title: Text(localizations.playerEnableDecoderFallback),
            value: playerConfig.enableDecoderFallback,
            onChanged: playerConfig.setEnableDecoderFallback,
          ),
        ],
        const Divider(),
        const ListTile(title: Text('语言偏好'), dense: true),
        MenuListTile(
          title: const Text('字幕语言偏好'),
          onSelected: playerConfig.setPreferredSubtitleLanguage,
          initialValue: playerConfig.preferredSubtitleLanguage,
          trailing: Text(all_native_names[playerConfig.preferredSubtitleLanguage] ?? ''),
          itemBuilder: (context) => kMaterialSupportedLanguages
              .map(
                (language) =>
                    CheckedPopupMenuItem(value: language, child: Text(all_native_names[language] ?? language)),
              )
              .toList(),
        ),
        MenuListTile(
          title: const Text('音频语言偏好'),
          onSelected: playerConfig.setPreferredAudioLanguage,
          initialValue: playerConfig.preferredAudioLanguage,
          trailing: Text(all_native_names[playerConfig.preferredAudioLanguage] ?? ''),
          itemBuilder: (context) => kMaterialSupportedLanguages
              .map(
                (language) =>
                    CheckedPopupMenuItem(value: language, child: Text(all_native_names[language] ?? language)),
              )
              .toList(),
        ),
      ],
    );
  }
}
