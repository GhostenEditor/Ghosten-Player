import 'package:flutter/material.dart';

import '../../components/number_picker.dart';
import '../../l10n/app_localizations.dart';

const colon = ':';

class TimerPickerDialog extends StatefulWidget {
  const TimerPickerDialog({super.key, required this.value, required this.title});

  final Duration value;
  final String title;

  @override
  State<TimerPickerDialog> createState() => _TimerPickerDialogState();
}

class _TimerPickerDialogState extends State<TimerPickerDialog> {
  late int _minutes = (widget.value - Duration(hours: widget.value.inHours)).inMinutes;
  late int _seconds = (widget.value - Duration(minutes: widget.value.inMinutes)).inSeconds;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  child: NumberPicker(
                    value: _minutes,
                    alwaysShow: true,
                    minValue: 0,
                    maxValue: 59,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(0x22),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) => setState(() => _minutes = value),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(colon, style: TextStyle(fontSize: 48)),
                ),
                Expanded(
                  child: NumberPicker(
                    value: _seconds,
                    alwaysShow: true,
                    minValue: 0,
                    maxValue: 59,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(0x22),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) => setState(() => _seconds = value),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(child: Center(child: Text(AppLocalizations.of(context)!.minute))),
              const SizedBox(width: 30),
              Expanded(child: Center(child: Text(AppLocalizations.of(context)!.second))),
            ],
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(Duration(seconds: _seconds, minutes: _minutes)),
          child: Text(AppLocalizations.of(context)!.buttonConfirm),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(Duration.zero),
          child: Text(AppLocalizations.of(context)!.buttonReset),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.buttonCancel),
        ),
      ],
    );
  }
}
