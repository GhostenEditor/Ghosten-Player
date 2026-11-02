import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:video_player/player.dart';

import '../../../l10n/app_localizations.dart';
import 'setting_page.dart';

class PlayerSubtitleSetting extends StatefulWidget {
  const PlayerSubtitleSetting({super.key, required this.subtitleSettings});

  final SubtitleSettings subtitleSettings;

  @override
  State<PlayerSubtitleSetting> createState() => _PlayerSubtitleSettingState();
}

class _PlayerSubtitleSettingState extends State<PlayerSubtitleSetting> {
  late Color _foregroundColor = widget.subtitleSettings.foregroundColor;
  late Color _backgroundColor = widget.subtitleSettings.backgroundColor;
  late Color _windowColor = widget.subtitleSettings.windowColor;
  late Color _edgeColor = widget.subtitleSettings.edgeColor;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Theme(
      data: Theme.of(context).copyWith(scaffoldBackgroundColor: Theme.of(context).colorScheme.surfaceContainerLow),
      child: ListTileTheme(
        data: ListTileTheme.of(context).copyWith(dense: true),
        child: SettingPage.list(
          title: Text(localizations.subtitleSetting),
          actions: [
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: () {
                final style = SubtitleSettings(
                  foregroundColor: _foregroundColor,
                  backgroundColor: _backgroundColor,
                  windowColor: _windowColor,
                  edgeColor: _edgeColor,
                );
                Navigator.of(context).pop(style.toJson());
              },
            ),
          ],
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(image: AssetImage('assets/images/subtitle-bg.jpg'), fit: BoxFit.cover),
              ),
              margin: const EdgeInsets.all(16),
              child: Align(
                alignment: const Alignment(0, 0.9),
                child: Stack(
                  children: [
                    Text(
                      localizations.subtitleSettingExample,
                      style: TextStyle(
                        fontSize: 24,
                        backgroundColor: _backgroundColor,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = _edgeColor,
                      ),
                    ),
                    Text(localizations.subtitleSettingExample, style: TextStyle(fontSize: 24, color: _foregroundColor)),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text(localizations.subtitleSettingForegroundColor),
              trailing: _buildTrailing(_foregroundColor),
              onTap: () async {
                final Color? color = await _showColorPicker(context, _foregroundColor);
                if (color != null && context.mounted) {
                  setState(() => _foregroundColor = color);
                }
              },
            ),
            ListTile(
              title: Text(localizations.subtitleSettingBackgroundColor),
              trailing: _buildTrailing(_backgroundColor),
              onTap: () async {
                final Color? color = await _showColorPicker(context, _backgroundColor);
                if (color != null && context.mounted) {
                  setState(() => _backgroundColor = color);
                }
              },
            ),
            ListTile(
              title: Text(localizations.subtitleSettingEdgeColor),
              trailing: _buildTrailing(_edgeColor),
              onTap: () async {
                final Color? color = await _showColorPicker(context, _edgeColor);
                if (color != null && context.mounted) {
                  setState(() => _edgeColor = color);
                }
              },
            ),
            ListTile(
              title: Text(localizations.subtitleSettingWindowColor),
              trailing: _buildTrailing(_windowColor),
              onTap: () async {
                final Color? color = await _showColorPicker(context, _windowColor);
                if (color != null && context.mounted) {
                  setState(() => _windowColor = color);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(Color color) {
    return ColorIndicator(HSVColor.fromColor(color), width: 16, height: 16);
  }

  Future<Color?> _showColorPicker(BuildContext context, Color color) async {
    return showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          titlePadding: const EdgeInsets.all(16),
          content: SingleChildScrollView(
            child: ColorPicker(pickerColor: color, paletteType: PaletteType.hsl, onColorChanged: (c) => color = c),
          ),
          contentPadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
          actions: <Widget>[
            IconButton.filledTonal(
              icon: const Icon(Icons.check_rounded),
              onPressed: () => Navigator.of(context).pop(color),
            ),
          ],
        );
      },
    );
  }
}
