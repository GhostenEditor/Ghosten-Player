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
              )),
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
          ListTile(
            title: Text(AppLocalizations.of(context)!.playerOpenFileWithParallelThreads),
            trailing: Switch(
              value: userConfig.playerConfig.enableParallel,
              onChanged: (value) => setState(() => userConfig.setPlayerEnableParallel(value)),
            ),
          ),
          if (userConfig.playerConfig.enableParallel)
            ListTile(
              title: Text(AppLocalizations.of(context)!.playerParallelsCount),
              trailing: Stepper(
                min: 2,
                max: 8,
                value: userConfig.playerConfig.parallels,
                onChange: (value) {
                  setState(() => userConfig.setPlayerParallels(value));
                },
              ),
            ),
          if (userConfig.playerConfig.enableParallel)
            ListTile(
              title: Text(AppLocalizations.of(context)!.playerSliceSize),
              trailing: Stepper(
                min: 1,
                max: 20,
                value: userConfig.playerConfig.sliceSize,
                onChange: (value) {
                  setState(() => userConfig.setPlayerSliceSize(value));
                },
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

class Stepper extends StatelessWidget {
  final int value;
  final int? max;
  final int? min;
  final int step;
  final Function(int) onChange;

  const Stepper({super.key, this.max, this.min, this.step = 1, required this.onChange, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(1000)),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: min == null || value > min! ? () => onChange(clamp(value - step)) : null,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.remove,
                size: 16,
                color: min == null || value > min! ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
          SizedBox(
            width: 20,
            child: Text(value.toString(), textAlign: TextAlign.center),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: max == null || value < max! ? () => onChange(clamp(value + step)) : null,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.add,
                size: 16,
                color: max == null || value < max! ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int clamp(int v) {
    if (max != null) {
      v = v < max! ? v : max!;
    }
    if (min != null) {
      v = v > min! ? v : min!;
    }
    return v;
  }
}
