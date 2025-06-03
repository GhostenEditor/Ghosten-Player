import 'package:flutter/material.dart';

import '../../components/number_picker.dart';
import '../../l10n/app_localizations.dart';
import 'filled_button.dart';
import 'text_button.dart';

class TimePicker extends StatefulWidget {
  const TimePicker({super.key, required this.value});

  final Duration value;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late int _minutes = (widget.value - Duration(hours: widget.value.inHours)).inMinutes;
  late int _seconds = (widget.value - Duration(minutes: widget.value.inMinutes)).inSeconds;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: const Alignment(-1, -0.32),
            child: SizedBox(
              height: 180,
              child: Row(
                children: [
                  NumberPicker(
                    autofocus: true,
                    value: _minutes,
                    minValue: 0,
                    maxValue: 59,
                    width: 24,
                    onChanged: (value) => setState(() => _minutes = value),
                  ),
                  const Padding(padding: EdgeInsets.all(8.0), child: Text(':')),
                  NumberPicker(
                    value: _seconds,
                    minValue: 0,
                    maxValue: 59,
                    width: 24,
                    onChanged: (value) => setState(() => _seconds = value),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TVFilledButton(
                  onPressed: () => Navigator.of(context).pop(Duration(seconds: _seconds, minutes: _minutes)),
                  child: Text(AppLocalizations.of(context)!.buttonConfirm),
                ),
                TVTextButton(
                  onPressed: () {
                    setState(() {
                      _minutes = 0;
                      _seconds = 0;
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.buttonReset),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
