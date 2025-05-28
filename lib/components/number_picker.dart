import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberPicker extends StatefulWidget {
  const NumberPicker({
    super.key,
    required this.onChanged,
    required this.value,
    this.autofocus = false,
    this.alwaysShow = false,
    this.width,
    this.height = 60,
    required this.minValue,
    required this.maxValue,
    this.overAndUnderCenterOpacity = 1.0,
    this.decoration,
  });

  final ValueChanged<int> onChanged;
  final int value;
  final bool autofocus;
  final bool alwaysShow;
  final int minValue;
  final int maxValue;
  final double? width;
  final double height;
  final double overAndUnderCenterOpacity;
  final Decoration? decoration;

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late int _value = widget.value;
  late final _count = widget.maxValue - widget.minValue + 1;
  late FixedExtentScrollController _scrollController = FixedExtentScrollController(initialItem: _value);
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
              _update(max(widget.minValue, min(widget.maxValue, _value - 1)));
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowDown:
              _update(max(widget.minValue, min(widget.maxValue, _value + 1)));
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      onFocusChange: (f) {
        setState(() {
          if (!widget.alwaysShow && _focusNode.hasFocus) {
            _scrollController.dispose();
            _scrollController = FixedExtentScrollController(initialItem: _value);
          }
        });
      },
      child:
          (_focusNode.hasFocus || widget.alwaysShow)
              ? Stack(
                children: [
                  if (widget.decoration != null)
                    Center(child: Container(decoration: widget.decoration, height: widget.height)),
                  SizedBox(
                    width: widget.width,
                    child: ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      itemExtent: widget.height,
                      diameterRatio: 1.4,
                      overAndUnderCenterOpacity: widget.overAndUnderCenterOpacity,
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _count,
                        builder: (context, index) => Center(child: Text(index.toString())),
                      ),
                      onSelectedItemChanged: (index) {
                        _value = index;
                        widget.onChanged(_value);
                      },
                    ),
                  ),
                ],
              )
              : GestureDetector(
                onTap: _focusNode.requestFocus,
                child: SizedBox(width: widget.width, child: Text(_value.toString(), textAlign: TextAlign.center)),
              ),
    );
  }

  void _update(int value) {
    if (_value != value) {
      _value = value;
      _scrollController.animateToItem(value, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      widget.onChanged(value);
    }
  }
}
