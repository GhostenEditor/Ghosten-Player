import 'package:flutter/material.dart';
import 'package:video_player/player.dart';

import '../l10n/app_localizations.dart';

class PlayerI18nAdaptor extends StatelessWidget {
  const PlayerI18nAdaptor({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PlayerLocalizations(
      settingsTitle: AppLocalizations.of(context)!.settingsTitle,
      videoSettingsVideo: AppLocalizations.of(context)!.videoSettingsVideo,
      videoSettingsAudio: AppLocalizations.of(context)!.videoSettingsAudio,
      videoSettingsSubtitle: AppLocalizations.of(context)!.videoSettingsSubtitle,
      videoSettingsSpeeding: AppLocalizations.of(context)!.videoSettingsSpeeding,
      videoSize: AppLocalizations.of(context)!.videoSize,
      videoSettingsNone: AppLocalizations.of(context)!.none,
      tagUnknown: AppLocalizations.of(context)!.tagUnknown,
      willSkipEnding: AppLocalizations.of(context)!.willSkipEnding,
      playerEnableDecoderFallback: AppLocalizations.of(context)!.playerEnableDecoderFallback,
      extensionRendererMode: AppLocalizations.of(context)!.audioDecoder,
      extensionRendererModeLabel: AppLocalizations.of(context)!.audioDecoderLabel,
      playerShowThumbnails: AppLocalizations.of(context)!.playerShowThumbnails,
      subtitleSetting: AppLocalizations.of(context)!.subtitleSetting,
      subtitleSettingExample: AppLocalizations.of(context)!.subtitleSettingExample,
      subtitleSettingForegroundColor: AppLocalizations.of(context)!.subtitleSettingForegroundColor,
      subtitleSettingBackgroundColor: AppLocalizations.of(context)!.subtitleSettingBackgroundColor,
      subtitleSettingEdgeColor: AppLocalizations.of(context)!.subtitleSettingEdgeColor,
      subtitleSettingWindowColor: AppLocalizations.of(context)!.subtitleSettingWindowColor,
      buttonReset: AppLocalizations.of(context)!.buttonReset,
      child: child,
    );
  }
}
