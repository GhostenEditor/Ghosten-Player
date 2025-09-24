import 'package:flutter/material.dart';
import 'package:html/dom.dart' as h;
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';

///see this issue: https://github.com/dart-lang/markdown/issues/284#event-3216258013
///use [htmlToMarkdown] to convert HTML in [m.Text] to [m.Node]
void htmlToMarkdown(h.Node? node, int deep, List<m.Node> mNodes) {
  if (node == null) return;
  if (node is h.Text) {
    mNodes.add(m.Text(node.text));
  } else if (node is h.Element) {
    final tag = node.localName;
    final children = <m.Node>[];
    for (final e in node.children) {
      htmlToMarkdown(e, deep + 1, children);
    }
    m.Element element;
    if (tag == MarkdownTag.img.name || tag == 'video') {
      element = HtmlElement(tag!, children, node.text);
      element.attributes.addAll(node.attributes.cast());
    } else {
      element = HtmlElement(tag!, children, node.text);
      element.attributes.addAll(node.attributes.cast());
    }
    mNodes.add(element);
  }
}

final RegExp tableRep = RegExp(r'<table[^>]*>', multiLine: true);

final RegExp htmlRep = RegExp(r'<[^>]*>', multiLine: true);

///parse [m.Node] to [h.Node]
List<SpanNode> parseHtml(
  m.Text node, {
  ValueCallback<dynamic>? onError,
  WidgetVisitor? visitor,
  TextStyle? parentStyle,
}) {
  try {
    final text = node.textContent.replaceAll(visitor?.splitRegExp ?? WidgetVisitor.defaultSplitRegExp, '');
    if (!text.contains(htmlRep)) return [TextNode(text: node.text)];
    final document = parseFragment(text);
    return HtmlToSpanVisitor(visitor: visitor, parentStyle: parentStyle).toVisit(document.nodes.toList());
  } catch (e) {
    onError?.call(e);
    return [TextNode(text: node.text)];
  }
}

class HtmlElement extends m.Element {
  HtmlElement(super.tag, super.children, this.textContent);

  @override
  final String textContent;
}

class HtmlToSpanVisitor extends TreeVisitor {
  HtmlToSpanVisitor({WidgetVisitor? visitor, TextStyle? parentStyle})
    : visitor = visitor ?? WidgetVisitor(),
      parentStyle = parentStyle ?? const TextStyle();
  final List<SpanNode> _spans = [];
  final List<SpanNode> _spansStack = [];
  final WidgetVisitor visitor;
  final TextStyle parentStyle;

  List<SpanNode> toVisit(List<h.Node> nodes) {
    _spans.clear();
    for (final node in nodes) {
      final emptyNode = ConcreteElementNode(style: parentStyle);
      _spans.add(emptyNode);
      _spansStack.add(emptyNode);
      visit(node);
      _spansStack.removeLast();
    }
    final result = List.of(_spans);
    _spans.clear();
    _spansStack.clear();
    return result;
  }

  @override
  void visitText(h.Text node) {
    final last = _spansStack.last;
    if (last is ElementNode) {
      final textNode = TextNode(text: node.text);
      last.accept(textNode);
    }
  }

  @override
  void visitElement(h.Element node) {
    final localName = node.localName ?? '';
    final mdElement = m.Element(localName, []);
    mdElement.attributes.addAll(node.attributes.cast());
    SpanNode spanNode = visitor.getNodeByElement(mdElement, visitor.config);
    if (spanNode is! ElementNode) {
      final n = ConcreteElementNode(tag: localName, style: parentStyle);
      n.accept(spanNode);
      spanNode = n;
    }
    final last = _spansStack.last;
    if (last is ElementNode) {
      last.accept(spanNode);
    }
    _spansStack.add(spanNode);
    for (final child in node.nodes.toList(growable: false)) {
      visit(child);
    }
    _spansStack.removeLast();
  }
}
