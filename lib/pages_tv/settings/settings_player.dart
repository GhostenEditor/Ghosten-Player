import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/user_config.dart';
import '../components/setting.dart';
import '../utils/utils.dart';

class SystemSettingsPlayer extends StatefulWidget {
  const SystemSettingsPlayer({super.key});

  @override
  State<SystemSettingsPlayer> createState() => SystemSettingsPlayerState();
}

class SystemSettingsPlayerState extends State<SystemSettingsPlayer> {
  late final userConfig = Provider.of<UserConfig>(context, listen: true);

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemPlayerSettings,
      child: ListView(padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32), children: [
        ButtonSettingItem(
          autofocus: true,
          title: Text(AppLocalizations.of(context)!.audioDecoderLabel),
          subtitle:
              Text(AppLocalizations.of(context)!.audioDecoder(_ExtensionRendererMode.values.firstWhere((e) => e.value == userConfig.playerConfig.mode).name)),
          onTap: () async {
            await navigateToSlideLeft(context, const _SettingsAudioDecoderPage());
            if (context.mounted) setState(() {});
          },
        ),
        SwitchSettingItem(
          title: Text(AppLocalizations.of(context)!.playerEnableDecoderFallback),
          value: userConfig.playerConfig.enableDecoderFallback,
          onChanged: (value) => setState(() => userConfig.setPlayerEnableDecoderFallback(value)),
        ),
        SwitchSettingItem(
          title: Badge(
            label: const Text('Beta'),
            alignment: Alignment.centerRight,
            offset: const Offset(-10, 0),
            child: Text(AppLocalizations.of(context)!.playerShowThumbnails),
          ),
          value: userConfig.playerConfig.showThumbnails ?? false,
          onChanged: (value) => setState(() => userConfig.setPlayerShowThumbnails(value)),
        ),
      ]),
    );
  }
}

enum _ExtensionRendererMode {
  off(0),
  on(1),
  prefer(2);

  final int value;

  const _ExtensionRendererMode(this.value);
}

class _SettingsAudioDecoderPage extends StatefulWidget {
  const _SettingsAudioDecoderPage();

  @override
  State<_SettingsAudioDecoderPage> createState() => _SettingsAudioDecoderPageState();
}

class _SettingsAudioDecoderPageState extends State<_SettingsAudioDecoderPage> {
  late final userConfig = Provider.of<UserConfig>(context, listen: true);
  late var extensionRendererMode = _ExtensionRendererMode.values.firstWhere((e) => e.value == userConfig.playerConfig.mode);

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: AppLocalizations.of(context)!.audioDecoderLabel,
      child: ListView(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
          children: _ExtensionRendererMode.values
              .map((e) => RadioSettingItem(
                  autofocus: e == extensionRendererMode,
                  value: e,
                  groupValue: extensionRendererMode,
                  title: Text(AppLocalizations.of(context)!.audioDecoder(e.name)),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      extensionRendererMode = value;
                      userConfig.setPlayerRendererMode(value.value);
                    });
                  }))
              .toList()),
    );
  }
}
