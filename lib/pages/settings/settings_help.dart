import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';

import '../../components/future_builder_handler.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import 'html_support.dart';

class SettingsHelp extends StatefulWidget {
  const SettingsHelp({super.key});

  @override
  State<SettingsHelp> createState() => _SettingsHelpState();
}

class _SettingsHelpState extends State<SettingsHelp> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsItemHelp)),
      body: FutureBuilderHandler<List<WikiPage>>(
        future: Dio()
            .get('https://raw.githubusercontent.com/$repoAuthor/$repoName/refs/heads/wiki/wiki.json')
            .then((resp) => (jsonDecode(resp.data) as List<dynamic>).map(WikiPage.fromJson).toList()),
        builder:
            (context, snapshot) => Scrollbar(
              controller: _controller,
              child: ListView.builder(
                controller: _controller,
                itemCount: snapshot.requireData.length,
                itemBuilder: (context, index) {
                  final item = snapshot.requireData[index];
                  if (item.subs != null) {
                    return ExpansionTile(
                      title: Text(item.title),
                      children:
                          item.subs!
                              .map(
                                (it) => ListTile(
                                  title: Text(it.title),
                                  onTap: it.path != null ? () => _toDetail(it) : null,
                                ),
                              )
                              .toList(),
                    );
                  } else {
                    return ListTile(title: Text(item.title), onTap: item.path != null ? () => _toDetail(item) : null);
                  }
                },
              ),
            ),
      ),
    );
  }

  void _toDetail(WikiPage page) {
    navigateTo(context, HelperDetail(page: page));
  }
}

class WikiPage {
  WikiPage.fromJson(dynamic json)
    : title = json['title'],
      path = json['path'],
      subs = (json['subs'] as List<dynamic>?)?.map(WikiPage.fromJson).toList();
  final String title;
  final String? path;
  final List<WikiPage>? subs;
}

class HelperDetail extends StatelessWidget {
  const HelperDetail({super.key, required this.page});

  final WikiPage page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(page.title)),
      body: Scrollbar(
        child: FutureBuilderHandler(
          future: Dio()
              .get<String>('https://raw.githubusercontent.com/wiki/$repoAuthor/$repoName/${page.path}')
              .then((resp) => resp.data),
          builder: (context, snapshot) {
            return MarkdownWidget(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
              data: snapshot.requireData!,
              markdownGenerator: MarkdownGenerator(
                textGenerator: (node, config, visitor) => CustomTextNode(node.textContent, config, visitor),
              ),
            );
          },
        ),
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
