import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'filled_button.dart';

class TimePicker extends StatefulWidget {
  final Duration value;

  const TimePicker({super.key, required this.value});

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
                  _NumberPicker(
                    autofocus: true,
                    value: _minutes,
                    minValue: 0,
                    maxValue: 59,
                    onChanged: (value) => setState(() => _minutes = value),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(':'),
                  ),
                  _NumberPicker(
                    value: _seconds,
                    minValue: 0,
                    maxValue: 59,
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
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _minutes = 0;
                        _seconds = 0;
                      });
                    },
                    child: Text(AppLocalizations.of(context)!.buttonReset),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class _NumberPicker extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int value;
  final bool autofocus;
  final int minValue;
  final int maxValue;

  const _NumberPicker({
    required this.onChanged,
    required this.value,
    this.autofocus = false,
    required this.minValue,
    required this.maxValue,
  });

  @override
  State<_NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<_NumberPicker> {
  late int value = widget.value;
  late final count = widget.maxValue - widget.minValue + 1;
  FixedExtentScrollController _scrollController = FixedExtentScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              update(max(widget.minValue, min(widget.maxValue, value - 1)));
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowDown:
              update(max(widget.minValue, min(widget.maxValue, value + 1)));
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      onFocusChange: (f) {
        setState(() {
          if (_focusNode.hasFocus) {
            _scrollController.dispose();
            _scrollController = FixedExtentScrollController(initialItem: value);
          }
        });
      },
      child: _focusNode.hasFocus
          ? SizedBox(
              width: 36,
              child: ListWheelScrollView.useDelegate(
                controller: _scrollController,
                itemExtent: 60,
                diameterRatio: 1.4,
                physics: const FixedExtentScrollPhysics(),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: count,
                  builder: (context, index) => Center(child: Text(index.toString())),
                ),
                onSelectedItemChanged: (index) {
                  value = index;
                  widget.onChanged(value);
                },
              ),
            )
          : GestureDetector(
              onTap: _focusNode.requestFocus,
              child: SizedBox(width: 36, child: Text(value.toString(), textAlign: TextAlign.center)),
            ),
    );
  }

  update(int value) {
    if (this.value != value) {
      this.value = value;
      _scrollController.animateToItem(value, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      widget.onChanged(value);
    }
  }
}
