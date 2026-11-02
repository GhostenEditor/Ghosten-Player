import 'package:flutter/material.dart';
import 'package:video_player/player.dart';

import '../../../l10n/app_localizations.dart';
import '_focusable.dart';
import 'setting_page.dart';

const _subtitleStyles = [
  SubtitleSettings(
    foregroundColor: Colors.white,
    backgroundColor: Colors.black,
    windowColor: Colors.transparent,
    edgeColor: Colors.transparent,
  ),
  SubtitleSettings(
    foregroundColor: Colors.black,
    backgroundColor: Colors.white,
    windowColor: Colors.transparent,
    edgeColor: Colors.transparent,
  ),
  SubtitleSettings(
    foregroundColor: Colors.black,
    backgroundColor: Colors.transparent,
    windowColor: Colors.transparent,
    edgeColor: Colors.white,
  ),
  SubtitleSettings(
    foregroundColor: Colors.white,
    backgroundColor: Colors.transparent,
    windowColor: Colors.transparent,
    edgeColor: Colors.black,
  ),
];

class PlayerSubtitleSetting extends StatelessWidget {
  const PlayerSubtitleSetting({super.key, required this.subtitleSettings});

  final SubtitleSettings subtitleSettings;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return SettingPage.list(
      title: Text(localizations.subtitleSetting),
      children: _subtitleStyles
          .map(
            (style) => Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Focusable(
                height: 140,
                onTap: () => Navigator.of(context).pop(style.toJson()),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Ink(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/subtitle-bg.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.9),
                      child: Stack(
                        children: [
                          Text(
                            localizations.subtitleSettingExample,
                            style: TextStyle(
                              fontSize: 18,
                              backgroundColor: style.backgroundColor,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = style.edgeColor,
                            ),
                          ),
                          Text(
                            localizations.subtitleSettingExample,
                            style: TextStyle(fontSize: 18, color: style.foregroundColor),
                          ),
                        ],
                      ),
                    ),
                    if (subtitleSettings == style)
                      Align(
                        alignment: const Alignment(0.9, -0.9),
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.check_rounded),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
