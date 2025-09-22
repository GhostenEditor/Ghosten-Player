import 'package:api/api.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:readmore/readmore.dart';

import '../../components/error_message.dart';
import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';

class SettingsLogPage extends StatefulWidget {
  const SettingsLogPage({super.key});

  @override
  State<SettingsLogPage> createState() => _SettingsLogPageState();
}

class _SettingsLogPageState extends State<SettingsLogPage> {
  final _scrollController = ScrollController();
  DateTimeRange? _dateTimeRange;

  PagingState<int, Log> _state = PagingState();

  Future<void> _fetchNextPage() async {
    if (_state.isLoading) return;

    await Future.value();

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final newKey = (_state.keys?.last ?? -1) + 1;
      final data = await Api.logQueryPage(
        30,
        newKey * 30,
        _dateTimeRange != null
            ? (
              _dateTimeRange!.start.millisecondsSinceEpoch,
              _dateTimeRange!.end.add(const Duration(days: 1)).millisecondsSinceEpoch,
            )
            : null,
      );

      final hasNextPage = data.offset + data.limit < data.count;

      setState(() {
        _state = _state.copyWith(
          pages: [...?_state.pages, data.data],
          keys: [...?_state.keys, newKey],
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
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () async {
              _dateTimeRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
                initialDateRange: _dateTimeRange,
                initialEntryMode: DatePickerEntryMode.calendarOnly,
              );
              setState(() => _state = PagingState());
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
                    title: ReadMoreText(
                      item.message,
                      trimLines: 8,
                      colorClickableText: Theme.of(context).colorScheme.primary,
                    ),
                    subtitle: Text(
                      formatDate(item.time, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS]),
                    ),
                    leading: Badge(
                      label: SizedBox(
                        width: 40,
                        child: Text(item.level.name.toUpperCase(), textAlign: TextAlign.center),
                      ),
                      textColor: Theme.of(context).colorScheme.surface,
                      backgroundColor: switch (item.level) {
                        LogLevel.error => null,
                        LogLevel.warn => const Color(0xffffab32),
                        LogLevel.info => Theme.of(context).colorScheme.primary,
                        LogLevel.debug => Theme.of(context).colorScheme.secondary,
                        LogLevel.trace => Theme.of(context).colorScheme.secondary,
                      },
                    ),
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: item.toString()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.tipsForCopiedSuccessfully,
                            textAlign: TextAlign.center,
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
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
