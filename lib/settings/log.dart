import 'package:flutter/material.dart' hide ListTile, Scrollbar;
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:logger/logger.dart';
import 'package:readmore/readmore.dart';

import '../../components/components.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';

class SettingsLogPage extends StatefulWidget {
  const SettingsLogPage({super.key});

  @override
  State<SettingsLogPage> createState() => _SettingsLogPageState();
}

class _SettingsLogPageState extends State<SettingsLogPage> {
  final _scrollController = ScrollController();

  PagingState<(int, String), Log> _state = PagingState();

  Future<void> _fetchNextPage() async {
    if (_state.isLoading) {
      return;
    }

    await Future.value();

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    try {
      final (int, String)? key = _state.keys?.last;
      final LogPage data = await Logger.logQueryPage(30, key?.$1, key?.$2);

      final bool hasNextPage = !data.isEnd;

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
    final double screenHeight = MediaQuery.sizeOf(context).height;
    return SettingPage(
      title: Text(AppLocalizations.of(context)!.settingsItemLog),
      actions: [
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () async {
            if (_state.items == null) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.tipsForCopiedSuccessfully, textAlign: TextAlign.center),
                duration: const Duration(seconds: 1),
              ),
            );
            await Clipboard.setData(ClipboardData(text: _state.items!.map((el) => el.raw).join('\n')));
          },
        ),
      ],
      floatingActionButton: ListenableBuilder(
        listenable: _scrollController,
        builder: (context, child) => _scrollController.offset > screenHeight ? child! : const SizedBox(),
        child: IconButton.filled(
          icon: const Icon(Icons.vertical_align_top),
          onPressed: () =>
              _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
        ),
      ),
      child: Scrollbar(
        controller: _scrollController,
        child: RefreshIndicator(
          onRefresh: () async => setState(() => _state = PagingState()),
          child: PagedListView.separated(
            state: _state,
            padding: SettingPageTheme.of(context).contentPadding,
            fetchNextPage: _fetchNextPage,
            scrollController: _scrollController,
            builderDelegate: PagedChildBuilderDelegate<Log>(
              itemBuilder: (context, item, index) => ListTile(
                dense: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 8,
                  children: [
                    if (item.tag != null) Text(item.tag!),
                    if (item.time != null) Text(item.time!.formatLog(), style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                subtitle: ReadMoreText(
                  item.message,
                  trimLines: 8,
                  colorClickableText: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {},
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
              noMoreItemsIndicatorBuilder: (_) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('END', style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
              ),
            ),
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(indent: 18, endIndent: 12, thickness: 0.5),
          ),
        ),
      ),
    );
  }
}
