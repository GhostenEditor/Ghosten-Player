import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';
import 'package:readmore/readmore.dart';

import '../../components/error_message.dart';
import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';

class SettingsLogPage extends StatefulWidget {
  const SettingsLogPage({super.key});

  @override
  State<SettingsLogPage> createState() => _SettingsLogPageState();
}

class _SettingsLogPageState extends State<SettingsLogPage> {
  final _scrollController = ScrollController();

  PagingState<(int, String), Log> _state = PagingState();

  Future<void> _fetchNextPage() async {
    if (_state.isLoading) return;

    await Future.value();

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final key = _state.keys?.last;
      final data = await Logger.logQueryPage(30, key?.$1, key?.$2);

      final hasNextPage = !data.isEnd;

      setState(() {
        _state = _state.copyWith(
          pages: [...?_state.pages, data.data],
          keys: [...?_state.keys, (data.cursor, data.filename)],
          hasNextPage: hasNextPage,
          isLoading: false,
        );
      });
    } catch (error) {
      setState(() {
        _state = _state.copyWith(error: error, isLoading: false);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsItemLog),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              if (_state.items == null) return;
              Clipboard.setData(ClipboardData(text: _state.items!.map((el) => el.raw).join('\n')));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.tipsForCopiedSuccessfully, textAlign: TextAlign.center),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _scrollController,
        builder: (BuildContext context, Widget? child) {
          return _scrollController.offset > screenHeight ? child! : const SizedBox();
        },
        child: IconButton.filled(
          icon: const Icon(Icons.vertical_align_top),
          onPressed: () {
            _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
          },
        ),
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: RefreshIndicator(
          onRefresh:
              () async => setState(() {
                _state = PagingState();
              }),
          child: PagedListView.separated(
            state: _state,
            fetchNextPage: _fetchNextPage,
            scrollController: _scrollController,
            builderDelegate: PagedChildBuilderDelegate<Log>(
              itemBuilder:
                  (context, item, index) => ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 8,
                      children: [
                        if (item.tag != null) Text(item.tag!),
                        if (item.time != null)
                          Text(item.time!.formatLog(), style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    subtitle: ReadMoreText(
                      item.message,
                      trimLines: 8,
                      colorClickableText: Theme.of(context).colorScheme.primary,
                    ),
                    leading: Badge(
                      label: Text(item.level.name.substring(0, 1).toUpperCase(), textAlign: TextAlign.center),
                      textColor: Theme.of(context).colorScheme.surface,
                      backgroundColor: switch (item.level) {
                        LogLevel.error => null,
                        LogLevel.warn => const Color(0xffffab32),
                        LogLevel.info => Theme.of(context).colorScheme.primary,
                        LogLevel.debug => Theme.of(context).colorScheme.secondary,
                        LogLevel.trace => Theme.of(context).colorScheme.tertiary,
                      },
                    ),
                  ),
              firstPageErrorIndicatorBuilder: (_) => ErrorMessage(error: _state.error),
              newPageErrorIndicatorBuilder: (_) => ErrorMessage(error: _state.error),
              noItemsFoundIndicatorBuilder: (_) => const NoData(),
              noMoreItemsIndicatorBuilder:
                  (_) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('END', style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
                  ),
            ),
            separatorBuilder:
                (BuildContext context, int index) => const Divider(indent: 18, endIndent: 12, thickness: 0.5),
          ),
        ),
      ),
    );
  }
}
