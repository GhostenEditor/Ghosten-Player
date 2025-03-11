import 'package:api/api.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:readmore/readmore.dart';

import '../../components/error_message.dart';
import '../../components/no_data.dart';

class SettingsLogPage extends StatefulWidget {
  const SettingsLogPage({super.key});

  @override
  State<SettingsLogPage> createState() => _SettingsLogPageState();
}

class _SettingsLogPageState extends State<SettingsLogPage> {
  final _controller = PagingController<int, Log>(firstPageKey: 0);
  final _scrollController = ScrollController();
  DateTimeRange? _dateTimeRange;

  @override
  void initState() {
    super.initState();
    _controller.addPageRequestListener(_query);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
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
              _controller.refresh();
            },
          )
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
          onRefresh: () async => _controller.refresh(),
          child: PagedListView.separated(
            pagingController: _controller,
            scrollController: _scrollController,
            builderDelegate: PagedChildBuilderDelegate<Log>(
              itemBuilder: (context, item, index) => ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                title: ReadMoreText(item.message, trimLines: 8, colorClickableText: Theme.of(context).colorScheme.primary),
                subtitle: Text(formatDate(item.time, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS])),
                leading: Badge(
                  label: SizedBox(width: 40, child: Text(item.level.name.toUpperCase(), textAlign: TextAlign.center)),
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
                      content: Text(AppLocalizations.of(context)!.tipsForCopiedSuccessfully, textAlign: TextAlign.center),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              firstPageErrorIndicatorBuilder: (_) => ErrorMessage(error: _controller.error),
              newPageErrorIndicatorBuilder: (_) => ErrorMessage(error: _controller.error),
              noItemsFoundIndicatorBuilder: (_) => const NoData(),
              noMoreItemsIndicatorBuilder: (_) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('END', style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
              ),
            ),
            separatorBuilder: (BuildContext context, int index) => const Divider(indent: 18, endIndent: 12, thickness: 0.5),
          ),
        ),
      ),
    );
  }

  Future<void> _query(int index) async {
    try {
      final data = await Api.logQueryPage(
        30,
        index * 30,
        _dateTimeRange != null ? (_dateTimeRange!.start.millisecondsSinceEpoch, _dateTimeRange!.end.add(const Duration(days: 1)).millisecondsSinceEpoch) : null,
      );

      if (data.offset + data.limit >= data.count) {
        _controller.appendLastPage(data.data);
      } else {
        _controller.appendPage(data.data, index + 1);
      }
    } catch (error) {
      _controller.error = error;
    }
  }
}
