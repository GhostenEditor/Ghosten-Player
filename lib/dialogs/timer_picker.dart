import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../components/number_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../adaptive/adaptive.dart';

const colon = ':';

class TimerPickerDialog extends StatefulWidget {
  const TimerPickerDialog({super.key, required this.data});

  final SetSkipTimeData data;

  @override
  State<TimerPickerDialog> createState() => _TimerPickerDialogState();
}

class _TimerPickerDialogState extends State<TimerPickerDialog> {
  late int _minutes = (widget.data.value - Duration(hours: widget.data.value.inHours)).inMinutes;
  late int _seconds = (widget.data.value - Duration(minutes: widget.data.value.inMinutes)).inSeconds;

  @override
  Widget build(BuildContext context) {
    return EditPage(
      title: Text(switch (widget.data.skipTimeType) {
        SkipTimeType.intro => AppLocalizations.of(context)!.buttonSkipFromStart,
        SkipTimeType.ending => AppLocalizations.of(context)!.buttonSkipFromEnd,
      }),
      useAssistance: false,
      onResetButtonPressed: () => _submit(context),
      onConfirmButtonPressed: () => _submit(context, Duration(seconds: _seconds, minutes: _minutes)),
      child: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              child: SafeArea(
                child: SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Row(
                          spacing: 16,
                          children: [
                            Expanded(
                              child: NumberPicker(
                                value: _minutes,
                                autofocus: true,
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
                              padding: EdgeInsets.only(bottom: 6),
                              child: Text(colon, style: TextStyle(fontSize: 36)),
                            ),
                            Expanded(
                              child: NumberPicker(
                                value: _seconds,
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
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.titleMedium!,
                        child: Row(
                          spacing: 42,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(AppLocalizations.of(context)!.minute),
                            Text(AppLocalizations.of(context)!.second),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, [Duration time = Duration.zero]) async {
    await Api.setSkipTime(widget.data.skipTimeType, widget.data.mediaType, widget.data.id, time);
    if (context.mounted) {
      Navigator.of(context).pop(time);
    }
  }
}
