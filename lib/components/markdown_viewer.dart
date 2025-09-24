import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';

import 'html_support.dart';

class MarkdownViewer extends StatelessWidget {
  const MarkdownViewer({super.key, required this.data, this.padding});

  final String data;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return MarkdownWidget(
      padding: padding,
      data: data,
      config: switch (Theme.of(context).brightness) {
        Brightness.dark => MarkdownConfig.darkConfig.copy(configs: [const PConfig(textStyle: TextStyle(fontSize: 14))]),
        Brightness.light => MarkdownConfig(configs: [const PConfig(textStyle: TextStyle(fontSize: 14))]),
      },
      markdownGenerator: MarkdownGenerator(
        textGenerator: (node, config, visitor) => CustomTextNode(node.textContent, config, visitor),
      ),
    );
  }
}

class CustomTextNode extends ElementNode {
  CustomTextNode(this.text, this.config, this.visitor);

  final String text;
  final MarkdownConfig config;
  final WidgetVisitor visitor;
  bool isTable = false;

  @override
  InlineSpan build() {
    if (isTable) {
      return WidgetSpan(child: HtmlWidget(text));
    } else {
      return super.build();
    }
  }

  @override
  void onAccepted(SpanNode parent) {
    final textStyle = config.p.textStyle.merge(parentStyle);
    children.clear();
    if (!text.contains(htmlRep)) {
      accept(TextNode(text: text, style: textStyle));
      return;
    }
    if (text.contains(tableRep)) {
      isTable = true;
      accept(parent);
      return;
    }

    final spans = parseHtml(
      m.Text(text),
      visitor: WidgetVisitor(
        config: visitor.config,
        generators: visitor.generators,
        richTextBuilder: visitor.richTextBuilder,
      ),
      parentStyle: parentStyle,
    );
    for (final element in spans) {
      isTable = false;
      accept(element);
    }
  }
}
