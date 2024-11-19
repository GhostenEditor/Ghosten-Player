import 'dart:io';

import 'package:api/api.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../utils/utils.dart';

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
    _controller.addPageRequestListener(query);
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
          child: PagedListView(
              pagingController: _controller,
              scrollController: _scrollController,
              builderDelegate: PagedChildBuilderDelegate<Log>(
                itemBuilder: (context, item, index) => switch (item.type) {
                  LogType.divider => const Divider(),
                  LogType.end => const ListTile(
                      title: Text('END', textAlign: TextAlign.center),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                  _ => ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(item.text!),
                      subtitle: Text(formatDate(item.dateTime!, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS, uuu])),
                      leading: Badge(
                        label: SizedBox(width: 40, child: Text(item.type.name.toUpperCase(), textAlign: TextAlign.center)),
                        backgroundColor: switch (item.type) {
                          LogType.error => null,
                          LogType.warn => const Color(0xffffab32),
                          LogType.info => Theme.of(context).colorScheme.primary,
                          LogType.debug => Theme.of(context).colorScheme.secondary,
                          _ => throw UnimplementedError(),
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
                    )
                },
              )),
        ),
      ),
    );
  }

  Future<void> query(int index) async {
    final logPath = await Api.logPath();
    final list = await Directory(logPath!).list().toList();
    final filteredList = list.reversed.where((entity) {
      if (_dateTimeRange != null) {
        final filename = entity.path.split('/').removeLast();
        final dataTime = DateTime(
          int.parse(filename.substring(0, 4)),
          int.parse(filename.substring(5, 7)),
          int.parse(filename.substring(8, 10)),
          int.parse(filename.substring(11, 13)),
          int.parse(filename.substring(14, 16)),
          int.parse(filename.substring(17, 19)),
        );
        return _dateTimeRange!.start <= dataTime && _dateTimeRange!.end.add(const Duration(days: 1)) > dataTime;
      } else {
        return true;
      }
    });
    if (index >= filteredList.length) {
      _controller.appendLastPage([Log.divider, Log.end]);
    } else {
      final file = File(filteredList.elementAt(index).path);
      final data = await file.readAsLines();

      List<Log> list = [];
      String cache = '';
      for (final line in data.reversed) {
        try {
          final log = Log.fromString(cache + line);
          cache = '';
          list.add(log);
        } catch (e) {
          cache = line + cache;
        }
      }

      if (index == filteredList.length - 1) {
        _controller.appendLastPage([...list, Log.divider, Log.end]);
      } else {
        _controller.appendPage([...list, Log.divider], index + 1);
      }
    }
  }
}

enum LogType {
  error,
  warn,
  info,
  debug,
  divider,
  end;

  static LogType fromString(String s) => switch (s) {
        'ERROR' => LogType.error,
        'WARN' => LogType.warn,
        'INFO' => LogType.info,
        'DEBUG' => LogType.debug,
        _ => throw Exception(),
      };
}

class Log {
  final LogType type;
  final DateTime? dateTime;
  final String? text;

  const Log({required this.type, this.dateTime, this.text});

  static const divider = Log(type: LogType.divider);
  static const end = Log(type: LogType.end);

  Log.fromString(String s)
      : type = LogType.fromString(s.substring(28, 33).trimRight()),
        dateTime = DateTime.parse(s.substring(0, 26).trimRight()),
        text = s.substring(36);

  @override
  String toString() {
    return '${formatDate(dateTime!, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, '.', SSS, uuu])} ${type.name.toUpperCase()}: $text';
  }
}
