import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef TextMapper = String Function(String numberText);

class NumberPicker extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> onChanged;
  final int itemCount;
  final int step;
  final double itemHeight;
  final double itemWidth;
  final Axis axis;
  final TextStyle? textStyle;
  final TextStyle? selectedTextStyle;
  final TextMapper? textMapper;
  final bool zeroPad;
  final bool autofocused;
  final Decoration? decoration;

  const NumberPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
    this.autofocused = false,
    this.itemCount = 5,
    this.step = 1,
    this.itemHeight = 40,
    this.itemWidth = 100,
    this.axis = Axis.vertical,
    this.textStyle,
    this.selectedTextStyle,
    this.decoration,
    this.zeroPad = false,
    this.textMapper,
  })  : assert(minValue <= value),
        assert(value <= maxValue);

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late ScrollController _scrollController;
  late bool _focused = widget.autofocused;

  @override
  void initState() {
    super.initState();
    final initialOffset = (widget.value - widget.minValue) ~/ widget.step * itemExtent;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    var indexOfMiddleElement = (_scrollController.offset / itemExtent).round();
    indexOfMiddleElement = indexOfMiddleElement.clamp(0, itemCount - 1);
    final intValueInTheMiddle = _intValueFromIndex(indexOfMiddleElement + additionalItemsOnEachSide);

    if (widget.value != intValueInTheMiddle) {
      widget.onChanged(intValueInTheMiddle);
    }
    Future.delayed(
      const Duration(milliseconds: 100),
      () => _maybeCenterValue(),
    );
  }

  @override
  void didUpdateWidget(NumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _maybeCenterValue();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get isScrolling => _scrollController.position.isScrollingNotifier.value;

  double get itemExtent => widget.axis == Axis.vertical ? widget.itemHeight : widget.itemWidth;

  int get itemCount => (widget.maxValue - widget.minValue) ~/ widget.step + 1;

  int get listItemsCount => itemCount + 2 * additionalItemsOnEachSide;

  int get additionalItemsOnEachSide => (widget.itemCount - 1) ~/ 2;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: _focused,
      onFocusChange: (focused) => setState(() {
        _focused = focused;
      }),
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              _scrollController.animateTo(_scrollController.offset - widget.itemHeight, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowDown:
              _scrollController.animateTo(_scrollController.offset + widget.itemHeight, duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowLeft:
              FocusScope.of(context).previousFocus();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight:
            case LogicalKeyboardKey.select:
              FocusScope.of(context).nextFocus();
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        width: widget.axis == Axis.vertical ? widget.itemWidth : widget.itemCount * widget.itemWidth,
        height: widget.axis == Axis.vertical ? widget.itemCount * widget.itemHeight : widget.itemHeight,
        child: NotificationListener<ScrollEndNotification>(
          onNotification: (not) {
            if (not.dragDetails?.primaryVelocity == 0) {
              Future.microtask(() => _maybeCenterValue());
            }
            return true;
          },
          child: Stack(
            children: [
              ListView.builder(
                itemCount: listItemsCount,
                scrollDirection: widget.axis,
                controller: _scrollController,
                itemExtent: itemExtent,
                itemBuilder: _itemBuilder,
                padding: EdgeInsets.zero,
              ),
              _NumberPickerSelectedItemDecoration(
                axis: widget.axis,
                itemExtent: itemExtent,
                decoration: _focused
                    ? BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(0x22),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          width: 4,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withAlpha(0x22),
                        borderRadius: BorderRadius.circular(4),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final themeData = Theme.of(context);
    final defaultStyle = widget.textStyle ?? themeData.textTheme.bodyMedium;
    final selectedStyle = widget.selectedTextStyle ?? themeData.textTheme.headlineSmall?.copyWith(color: themeData.colorScheme.secondary);

    final value = _intValueFromIndex(index % itemCount);
    final isExtra = (index < additionalItemsOnEachSide || index >= listItemsCount - additionalItemsOnEachSide);
    final itemStyle = value == widget.value ? selectedStyle : defaultStyle;

    final child = isExtra
        ? const SizedBox.shrink()
        : Text(
            _getDisplayedValue(value),
            style: itemStyle,
          );

    return Container(
      width: widget.itemWidth,
      height: widget.itemHeight,
      alignment: Alignment.center,
      child: child,
    );
  }

  String _getDisplayedValue(int value) {
    final text = widget.zeroPad ? value.toString().padLeft(widget.maxValue.toString().length, '0') : value.toString();
    if (widget.textMapper != null) {
      return widget.textMapper!(text);
    } else {
      return text;
    }
  }

  int _intValueFromIndex(int index) {
    index -= additionalItemsOnEachSide;
    index %= itemCount;
    return widget.minValue + index * widget.step;
  }

  void _maybeCenterValue() {
    if (_scrollController.hasClients && !isScrolling) {
      int diff = widget.value - widget.minValue;
      int index = diff ~/ widget.step;
      _scrollController.animateTo(
        index * itemExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

class _NumberPickerSelectedItemDecoration extends StatelessWidget {
  final Axis axis;
  final double itemExtent;
  final Decoration? decoration;

  const _NumberPickerSelectedItemDecoration({
    required this.axis,
    required this.itemExtent,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IgnorePointer(
        child: Container(
          width: isVertical ? double.infinity : itemExtent,
          height: isVertical ? itemExtent : double.infinity,
          decoration: decoration,
        ),
      ),
    );
  }

  bool get isVertical => axis == Axis.vertical;
}
