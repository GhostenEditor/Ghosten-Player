import 'dart:convert';

import 'package:flutter/material.dart';

import '../../components/future_builder_handler.dart';
import '../../components/markdown_viewer.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';

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
        future: cacheHttpClient
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

// ignore_for_file: avoid_dynamic_calls
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
          future: cacheHttpClient
              .get<String>('https://raw.githubusercontent.com/wiki/$repoAuthor/$repoName/${page.path}')
              .then((resp) => resp.data),
          builder:
              (context, snapshot) => MarkdownViewer(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                data: snapshot.requireData!,
              ),
        ),
      ),
    );
  }
}
