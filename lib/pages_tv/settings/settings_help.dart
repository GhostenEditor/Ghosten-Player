import 'dart:convert';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../components/future_builder_handler.dart';
import '../../components/markdown_viewer.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../components/keyboard_scroll.dart';
import '../components/setting.dart';

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
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemHelp,
      child: FutureBuilderHandler<List<WikiPage>>(
        future: cacheHttpClient
            .get('https://raw.githubusercontent.com/$repoAuthor/$repoName/refs/heads/wiki/wiki.json')
            .then((resp) => (jsonDecode(resp.data) as List<dynamic>).map(WikiPage.fromJson).toList()),
        builder: (context, snapshot) => Scrollbar(
          controller: _controller,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
            controller: _controller,
            itemCount: snapshot.requireData.length,
            itemBuilder: (context, index) {
              final item = snapshot.requireData[index];
              if (item.subs != null) {
                return ExpansionTile(
                  title: Text(item.title),
                  childrenPadding: const EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 12),
                  children: item.subs!
                      .map(
                        (it) => ButtonSettingItem(
                          title: Text(it.title),
                          onTap: it.path != null ? () => _toDetail(it) : null,
                        ),
                      )
                      .toList(),
                );
              } else {
                return ButtonSettingItem(
                  title: Text(item.title),
                  onTap: item.path != null ? () => _toDetail(item) : null,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _toDetail(WikiPage page) {
    navigateTo(navigatorKey.currentContext!, HelperDetail(page: page));
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

class HelperDetail extends StatefulWidget {
  const HelperDetail({super.key, required this.page});

  final WikiPage page;

  @override
  State<HelperDetail> createState() => _HelperDetailState();
}

class _HelperDetailState extends State<HelperDetail> {
  final _autoScrollController = AutoScrollController();

  @override
  void dispose() {
    _autoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.page.title)),
      body: Scrollbar(
        child: FutureBuilderHandler(
          future: cacheHttpClient
              .get<String>('https://raw.githubusercontent.com/wiki/$repoAuthor/$repoName/${widget.page.path}')
              .then((resp) => resp.data),
          builder: (context, snapshot) => KeyboardScroll(
            autofocus: true,
            controller: _autoScrollController,
            child: MarkdownViewer(
              autoScrollController: _autoScrollController,
              padding: const EdgeInsets.only(left: 72, right: 72, bottom: 32),
              data: snapshot.requireData!,
            ),
          ),
        ),
      ),
    );
  }
}
