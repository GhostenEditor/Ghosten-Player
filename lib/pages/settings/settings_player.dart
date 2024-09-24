import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PopupMenuItem;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../components/gap.dart';
import '../../components/popup_menu.dart';
import '../../providers/user_config.dart';

class SystemSettingsPlayer extends StatefulWidget {
  const SystemSettingsPlayer({super.key});

  @override
  State<SystemSettingsPlayer> createState() => SystemSettingsPlayerState();
}

class SystemSettingsPlayerState extends State<SystemSettingsPlayer> {
  late final userConfig = Provider.of<UserConfig>(context, listen: true);
  late var extensionRendererMode = _ExtensionRendererMode.values.firstWhere((e) => e.value == userConfig.playerConfig.mode);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsItemPlayerSettings),
      ),
      body: ListView(
        children: [
          PopupMenuButton(
              offset: const Offset(1, 0),
              onSelected: (value) {
                setState(() {
                  extensionRendererMode = value;
                  userConfig.setPlayerRendererMode(value.value);
                });
              },
              itemBuilder: (context) => _ExtensionRendererMode.values
                  .map((e) => PopupMenuItem(
                        autofocus: kIsAndroidTV && e == extensionRendererMode,
                        value: e,
                        title: Text(AppLocalizations.of(context)!.audioDecoder(e.name)),
                        leading: Icon(e == extensionRendererMode ? Icons.done : null),
                      ))
                  .toList(),
              child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.audioDecoderLabel),
                      Gap.hMD,
                      Expanded(
                        child: Text(AppLocalizations.of(context)!.audioDecoder(extensionRendererMode.name),
                            textAlign: TextAlign.end, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right))),
          ListTile(
            title: Text(AppLocalizations.of(context)!.playerEnableDecoderFallback),
            trailing: Switch(
              value: userConfig.playerConfig.enableDecoderFallback,
              onChanged: (value) => setState(() => userConfig.setPlayerEnableDecoderFallback(value)),
            ),
          ),
          ListTile(
            title: Row(
              children: [
                Text(AppLocalizations.of(context)!.playerShowThumbnails),
                Gap.hSM,
                const Badge(label: Text('Beta')),
              ],
            ),
            trailing: Switch(
              value: userConfig.playerConfig.showThumbnails ?? false,
              onChanged: (value) => setState(() => userConfig.setPlayerShowThumbnails(value)),
            ),
          ),
          if (kIsAndroidTV)
            ListTile(
              title: Row(
                children: [
                  Text(AppLocalizations.of(context)!.playerFastForwardSpeed),
                  Expanded(
                    child: MediaQuery(
                        data: const MediaQueryData(navigationMode: NavigationMode.directional),
                        child: Slider(
                          value: userConfig.playerConfig.speed.toDouble(),
                          min: 5,
                          max: 100,
                          divisions: 19,
                          label: userConfig.playerConfig.speed.toString(),
                          onChanged: (double value) {
                            setState(() {
                              userConfig.setPlayerFastForwardSpeed(value.round());
                            });
                          },
                        )),
                  ),
                ],
              ),
            ),
        ],
      ),
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
