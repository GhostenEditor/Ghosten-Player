import 'dart:math';

import 'package:flutter/material.dart';

enum DropCapMode {
  inside,
  upwards,
  aside,
  baseline
}

enum DropCapPosition {
  start,
  end,
}

class DropCap extends StatelessWidget {
  final Widget child;
  final double width, height;

  const DropCap({
    super.key,
    required this.child,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height, child: child);
  }
}

class DropCapText extends StatelessWidget {
  final String data;
  final DropCapMode mode;
  final TextStyle? style, dropCapStyle;
  final TextAlign textAlign;
  final DropCap? dropCap;
  final EdgeInsets dropCapPadding;
  final Offset indentation;
  final bool forceNoDescent, parseInlineMarkdown;
  final TextDirection textDirection;
  final DropCapPosition? dropCapPosition;
  final int dropCapChars;
  final int? maxLines;
  final TextOverflow overflow;

  const DropCapText(this.data,
      {super.key,
      this.mode = DropCapMode.inside,
      this.style,
      this.dropCapStyle,
      this.textAlign = TextAlign.start,
      this.dropCap,
      this.dropCapPadding = EdgeInsets.zero,
      this.indentation = Offset.zero,
      this.dropCapChars = 1,
      this.forceNoDescent = false,
      this.parseInlineMarkdown = false,
      this.textDirection = TextDirection.ltr,
      this.overflow = TextOverflow.clip,
      this.maxLines,
      this.dropCapPosition});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 14,
      height: 1,
      fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
    ).merge(style);

    if (data == '') return Text(data, style: textStyle);

    TextStyle capStyle = TextStyle(
      color: textStyle.color,
      fontSize: textStyle.fontSize! * 5.5,
      fontFamily: textStyle.fontFamily,
      fontWeight: textStyle.fontWeight,
      fontStyle: textStyle.fontStyle,
      height: 1,
    ).merge(dropCapStyle);

    double capWidth, capHeight;
    int dropCapChars = dropCap != null ? 0 : this.dropCapChars;
    CrossAxisAlignment sideCrossAxisAlignment = CrossAxisAlignment.start;
    MarkdownParser? mdData = parseInlineMarkdown ? MarkdownParser(data) : null;
    final String dropCapStr = (mdData?.plainText ?? data).substring(0, dropCapChars);

    if (mode == DropCapMode.baseline && dropCap == null) return _buildBaseline(context, textStyle, capStyle);

    if (dropCap != null) {
      capWidth = dropCap!.width;
      capHeight = dropCap!.height;
    } else {
      TextPainter capPainter = TextPainter(
        text: TextSpan(
          text: dropCapStr,
          style: capStyle,
        ),
        textDirection: textDirection,
      );
      capPainter.layout();
      capWidth = capPainter.width;
      capHeight = capPainter.height;
      if (forceNoDescent) {
        List<LineMetrics> ls = capPainter.computeLineMetrics();
        capHeight -= ls.isNotEmpty ? ls[0].descent * 0.95 : capPainter.height * 0.2;
      }
    }

    capWidth += dropCapPadding.left + dropCapPadding.right;
    capHeight += dropCapPadding.top + dropCapPadding.bottom;

    MarkdownParser? mdRest = parseInlineMarkdown ? mdData!.subchars(dropCapChars) : null;
    String restData = data.substring(dropCapChars);

    TextSpan textSpan = TextSpan(
      text: parseInlineMarkdown ? null : restData,
      children: parseInlineMarkdown ? mdRest!.toTextSpanList() : null,
      style: textStyle.apply(fontSizeFactor: MediaQuery.of(context).textScaleFactor),
    );

    TextPainter textPainter = TextPainter(textDirection: textDirection, text: textSpan, textAlign: textAlign);
    double lineHeight = textPainter.preferredLineHeight;

    int rows = ((capHeight - indentation.dy) / lineHeight).ceil();

    if (mode == DropCapMode.upwards) {
      rows = 1;
      sideCrossAxisAlignment = CrossAxisAlignment.end;
    }

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      double boundsWidth = constraints.maxWidth - capWidth;
      if (boundsWidth < 1) boundsWidth = 1;

      int charIndexEnd = data.length;

      if (rows > 0) {
        textPainter.layout(maxWidth: boundsWidth);
        double yPos = rows * lineHeight;
        int charIndex = textPainter.getPositionForOffset(Offset(0, yPos)).offset;
        textPainter.maxLines = rows;
        textPainter.layout(maxWidth: boundsWidth);
        if (textPainter.didExceedMaxLines) charIndexEnd = charIndex;
      } else {
        charIndexEnd = dropCapChars;
      }

      if (mode == DropCapMode.aside) charIndexEnd = data.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            textDirection: dropCapPosition == null || dropCapPosition == DropCapPosition.start
                ? textDirection
                : (textDirection == TextDirection.ltr ? TextDirection.rtl : TextDirection.ltr),
            crossAxisAlignment: sideCrossAxisAlignment,
            children: <Widget>[
              dropCap != null
                  ? Padding(padding: dropCapPadding, child: dropCap)
                  : Container(
                      width: capWidth,
                      height: capHeight,
                      padding: dropCapPadding,
                      child: RichText(
                        textDirection: textDirection,
                        textAlign: textAlign,
                        text: TextSpan(
                          text: dropCapStr,
                          style: capStyle,
                        ),
                      ),
                    ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(top: indentation.dy),
                  width: boundsWidth,
                  height: mode != DropCapMode.aside ? (lineHeight * min(maxLines ?? rows, rows)) + indentation.dy : null,
                  child: RichText(
                    overflow: (maxLines == null || (maxLines! > rows && overflow == TextOverflow.fade)) ? TextOverflow.clip : overflow,
                    maxLines: maxLines,
                    textDirection: textDirection,
                    textAlign: textAlign,
                    text: textSpan,
                  ),
                ),
              ),
            ],
          ),
          if (maxLines == null || maxLines! > rows && !parseInlineMarkdown && charIndexEnd < restData.length)
            Padding(
              padding: EdgeInsets.only(left: indentation.dx),
              child: RichText(
                overflow: overflow,
                maxLines: maxLines != null && maxLines! > rows ? maxLines! - rows : null,
                textAlign: textAlign,
                textDirection: textDirection,
                text: TextSpan(
                  text: parseInlineMarkdown ? null : restData.substring(min(charIndexEnd, restData.length)),
                  children: parseInlineMarkdown ? mdRest!.subchars(charIndexEnd).toTextSpanList() : null,
                  style: textStyle.apply(fontSizeFactor: MediaQuery.of(context).textScaleFactor),
                ),
              ),
            ),
        ],
      );
    });
  }

  _buildBaseline(BuildContext context, TextStyle textStyle, TextStyle capStyle) {
    MarkdownParser mdData = MarkdownParser(data);

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: textStyle,
        children: <TextSpan>[
          TextSpan(
            text: mdData.plainText.substring(0, dropCapChars),
            style: capStyle.merge(const TextStyle(height: 0)),
          ),
          TextSpan(
            children: mdData.subchars(dropCapChars).toTextSpanList(),
            style: textStyle.apply(fontSizeFactor: MediaQuery.of(context).textScaleFactor),
          ),
        ],
      ),
    );
  }
}

class MarkdownParser {
  final String data;
  late List<MarkdownSpan> spans;
  String plainText = '';

  List<TextSpan> toTextSpanList() {
    return spans.map((s) => s.toTextSpan()).toList();
  }

  MarkdownParser subchars(int startIndex, [int? endIndex]) {
    final List<MarkdownSpan> subspans = [];
    int skip = startIndex;
    for (int s = 0; s < spans.length; s++) {
      MarkdownSpan span = spans[s];
      if (skip <= 0) {
        subspans.add(span);
      } else if (span.text.length < skip) {
        skip -= span.text.length;
      } else {
        subspans.add(
          MarkdownSpan(
            style: span.style,
            markups: span.markups,
            text: span.text.substring(skip, span.text.length),
          ),
        );
        skip = 0;
      }
    }

    return MarkdownParser(
      subspans
          .asMap()
          .map((int index, MarkdownSpan span) {
            String markup = index > 0 ? (span.markups.isNotEmpty ? span.markups[0].code : '') : span.markups.map((m) => m.isActive ? m.code : '').join();
            return MapEntry(index, '$markup${span.text}');
          })
          .values
          .toList()
          .join(),
    );
  }

  MarkdownParser(this.data) {
    plainText = '';
    spans = [MarkdownSpan(text: '', markups: [], style: const TextStyle())];

    bool bold = false;
    bool italic = false;
    bool underline = false;

    const String markupBold = '**';
    const String markupItalic = '_';
    const String markupUnderline = '++';

    addSpan(String markup, bool isOpening) {
      final List<Markup> markups = [Markup(markup, isOpening)];

      if (bold && markup != markupBold) markups.add(Markup(markupBold, true));
      if (italic && markup != markupItalic) markups.add(Markup(markupItalic, true));
      if (underline && markup != markupUnderline) markups.add(Markup(markupUnderline, true));

      spans.add(
        MarkdownSpan(
          text: '',
          markups: markups,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : null,
            fontStyle: italic ? FontStyle.italic : null,
            decoration: underline ? TextDecoration.underline : null,
          ),
        ),
      );
    }

    bool checkMarkup(int i, String markup) {
      return data.substring(i, min(i + markup.length, data.length)) == markup;
    }

    for (int c = 0; c < data.length; c++) {
      if (checkMarkup(c, markupBold)) {
        bold = !bold;
        addSpan(markupBold, bold);
        c += markupBold.length - 1;
      } else if (checkMarkup(c, markupItalic)) {
        italic = !italic;
        addSpan(markupItalic, italic);
        c += markupItalic.length - 1;
      } else if (checkMarkup(c, markupUnderline)) {
        underline = !underline;
        addSpan(markupUnderline, underline);
        c += markupUnderline.length - 1;
      } else {
        spans[spans.length - 1].text += data[c];
        plainText += data[c];
      }
    }
  }
}

class MarkdownSpan {
  final TextStyle style;
  final List<Markup> markups;
  String text;

  TextSpan toTextSpan() => TextSpan(text: text, style: style);

  MarkdownSpan({
    required this.text,
    required this.style,
    required this.markups,
  });
}

class Markup {
  final String code;
  final bool isActive;

  Markup(this.code, this.isActive);
}
