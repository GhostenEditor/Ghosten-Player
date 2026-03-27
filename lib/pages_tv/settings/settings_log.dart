import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';

import '../../components/error_message.dart';
import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../components/setting.dart';

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
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemLog,
      child: Scrollbar(
        controller: _scrollController,
        child: RefreshIndicator(
          onRefresh: () async => setState(() => _state = PagingState()),
          child: PagedListView(
            state: _state,
            fetchNextPage: _fetchNextPage,
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
            scrollController: _scrollController,
            builderDelegate: PagedChildBuilderDelegate<Log>(
              itemBuilder:
                  (context, item, index) => Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                    ),
                    child: ButtonSettingItem(
                      dense: true,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (item.tag != null) Text(item.tag!),
                          if (item.message.isNotEmpty) Text(item.message),
                        ],
                      ),
                      subtitle: item.time != null ? Text(item.time!.formatLog()) : null,
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
                      onTap: () {},
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
          ),
        ),
      ),
    );
  }
}
