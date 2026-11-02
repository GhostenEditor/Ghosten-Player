import 'dart:convert';

import 'package:flutter/material.dart' hide ListTile, Scrollbar;
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';
import '../components/components.dart ';
import '../view_models/view_models.dart';
import '../viewers/markdown_viewer.dart';

class SettingsHelp extends StatelessWidget {
  const SettingsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: Text(AppLocalizations.of(context)!.settingsItemHelp),
      child: ListViewModelConsumer<HelpListViewModel, WikiPage>(
        builder: (context, items, _) => ListView.builder(
          padding: SettingPageTheme.of(context).contentPadding,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final WikiPage item = items[index];
            if (item.subs != null) {
              return ExpansionTile(
                title: Text(item.title),
                childrenPadding: SettingPageTheme.of(context).contentPadding,
                children: item.subs!.map((it) => _buildItem(context, it)).toList(),
              );
            } else {
              return _buildItem(context, item);
            }
          },
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, WikiPage item) {
    return ListTile(
      title: Text(item.title),
      onTap: item.path != null ? () => context.pushNamed(.settingsHelpDetail, arguments: item) : null,
    );
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
    return SettingPage(
      title: Text(widget.page.title),
      child: Scrollbar(
        child: FutureBuilderHandler(
          loadingBuilder: (context, _) => const LinearProgressIndicator(),
          future: cacheHttpClient
              .get<String>('https://raw.githubusercontent.com/wiki/$repoAuthor/$repoName/${widget.page.path}')
              .then((resp) => resp.data),
          builder: (context, snapshot) => KeyboardScroll(
            autofocus: true,
            controller: _autoScrollController,
            child: MarkdownViewer(
              autoScrollController: _autoScrollController,
              padding: const .symmetric(horizontal: 16, vertical: 8),
              data: snapshot.requireData!,
            ),
          ),
        ),
      ),
    );
  }
}

class HelpListViewModel extends ListViewModelBase<WikiPage> {
  HelpListViewModel() : snapshot = const AsyncSnapshot.waiting();

  @override
  AsyncSnapshot<List<WikiPage>> snapshot;

  @override
  Future<void> load() async {
    try {
      final List<WikiPage> data = await cacheHttpClient
          .get(wikiUrl)
          .then((resp) => (jsonDecode(resp.data) as List<dynamic>).map(WikiPage.fromJson).toList());
      snapshot = AsyncSnapshot.withData(.done, data);
    } catch (e) {
      snapshot = AsyncSnapshot.withError(.done, e);
    }
    notifyListeners();
  }

  @override
  Widget build() {
    return ChangeNotifierProvider(create: (_) => this, child: const SettingsHelp());
  }
}
