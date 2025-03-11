import 'package:api/api.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../components/error_message.dart';
import '../../components/no_data.dart';
import '../components/setting.dart';

class SettingsLogPage extends StatefulWidget {
  const SettingsLogPage({super.key});

  @override
  State<SettingsLogPage> createState() => _SettingsLogPageState();
}

class _SettingsLogPageState extends State<SettingsLogPage> {
  final _controller = PagingController<int, Log>(firstPageKey: 0);
  DateTimeRange? _dateTimeRange;

  final _scrollController = ScrollController();

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

  @override
  void initState() {
    super.initState();
    _controller.addPageRequestListener(_query);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingPage(
        title: AppLocalizations.of(context)!.settingsItemLog,
        child: Scrollbar(
          controller: _scrollController,
          child: RefreshIndicator(
            onRefresh: () async => _controller.refresh(),
            child: PagedListView.separated(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
              pagingController: _controller,
              scrollController: _scrollController,
              builderDelegate: PagedChildBuilderDelegate<Log>(
                itemBuilder: (context, item, index) => ButtonSettingItem(
                  title: Text(item.message),
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
                  onTap: () {},
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
        ));
  }
}
