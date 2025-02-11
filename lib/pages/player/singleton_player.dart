import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:video_player/player.dart';

import '../../providers/user_config.dart';

class SingletonPlayer extends StatefulWidget {
  final String url;
  final bool isTV;

  const SingletonPlayer({super.key, required this.url, required this.isTV});

  @override
  State<SingletonPlayer> createState() => _SingletonPlayerState();
}

class _SingletonPlayerState extends State<SingletonPlayer> {
  late final userConfig = context.read<UserConfig>();
  late final PlayerController controller = PlayerController([
    PlaylistItem(
      url: Uri.parse(widget.url),
      sourceType: PlaylistItemSourceType.local,
    ),
  ], 0, Api.log);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlayerControls(
      localizations: PlayerLocalizations(
        settingsTitle: AppLocalizations.of(context)!.settingsTitle,
        videoSettingsVideo: AppLocalizations.of(context)!.videoSettingsVideo,
        videoSettingsAudio: AppLocalizations.of(context)!.videoSettingsAudio,
        videoSettingsSubtitle: AppLocalizations.of(context)!.videoSettingsSubtitle,
        videoSettingsSpeeding: AppLocalizations.of(context)!.videoSettingsSpeeding,
        videoSize: AppLocalizations.of(context)!.videoSize,
        videoSettingsNone: AppLocalizations.of(context)!.none,
        tagUnknown: AppLocalizations.of(context)!.tagUnknown,
        willSkipEnding: AppLocalizations.of(context)!.willSkipEnding,
      ),
      options: userConfig.playerConfig.config,
      showThumbnails: true,
      controller: controller,
      isTV: widget.isTV,
    );
  }
}
