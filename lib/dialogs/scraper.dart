import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../components/components.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../../validators/validators.dart';
import '../adaptive/adaptive.dart';

class ScraperDialog<T extends MediaBase> extends StatefulWidget {
  const ScraperDialog({super.key, required this.item});

  final T item;

  @override
  State<ScraperDialog<T>> createState() => _ScraperDialogState<T>();
}

class _ScraperDialogState<T extends MediaBase> extends State<ScraperDialog<T>> {
  final selected = ValueNotifier<SearchResult?>(null);
  late final _controller = FormGroupController([
    FormItem(
      'search',
      value: widget.item.title,
      prefixIcon: const Icon(Icons.title),
      labelText: AppLocalizations.of(context)!.formLabelTitle,
      validator: (value) => requiredValidator(context, value),
    ),
    IntFormItem(
      'year',
      value: widget.item.displayAirDate?.year,
      prefixIcon: const Icon(Icons.calendar_month_outlined),
      labelText: AppLocalizations.of(context)!.formLabelYear,
      validator: (value) => yearValidator(context, value),
    ),
    DropdownFormItem(
      'language',
      initialValue: switch (Localizations.localeOf(context).toLanguageTag()) {
        'zh' => SupportedLanguages.zhCn,
        'en' => SupportedLanguages.enUs,
        _ => SupportedLanguages.auto,
      },
      prefixIcon: const Icon(Icons.language_rounded),
      labelText: AppLocalizations.of(context)!.formLabelLanguage,
      items: SupportedLanguages.values
          .map(
            (locale) => DropdownMenuItem(
              value: locale,
              child: Text(AppLocalizations.of(context)!.supportedLanguage(locale.name)),
            ),
          )
          .toList(),
    ),
  ]);

  Future<List<SearchResult>> _future = Future.value([]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(_search);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationPage(
      title: Text(AppLocalizations.of(context)!.buttonScraperMediaInfo),
      actions: [
        ValueListenableBuilder(
          valueListenable: selected,
          builder: (context, value, _) => TextButton(
            onPressed: value != null
                ? () async {
                    final Future<void> _ = switch (widget.item) {
                      TVSeries _ => Api.tvSeriesScraperById(
                        widget.item.id,
                        value.id,
                        value.type,
                        _controller.data['language'],
                      ),
                      Movie _ => Api.movieScraperById(
                        widget.item.id,
                        value.id,
                        value.type,
                        _controller.data['language'],
                      ),
                      _ => throw UnimplementedError(),
                    };
                    Navigator.of(context).pop();
                  }
                : null,
            child: Text(
              AppLocalizations.of(context)!.buttonConfirm,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
      section1: Align(
        alignment: const Alignment(0, -0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: .min,
          // spacing: 4,
          children: [
            FormGroup(controller: _controller),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: FilledButton(
                style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                onPressed: _search,
                child: Text(AppLocalizations.of(context)!.search),
              ),
            ),
          ],
        ),
      ),
      section2: FutureBuilderSliverHandler(
        key: ValueKey(_future),
        future: _future,
        loadingBuilder: (context, _) => const SliverFillRemaining(hasScrollBody: false, child: Loading()),
        builder: (context, snapshot) => snapshot.requireData.isNotEmpty
            ? SliverPadding(
                padding: const .symmetric(vertical: 12, horizontal: 6),
                sliver: _SearchResultList(items: snapshot.requireData, onChanged: (data) => selected.value = data),
              )
            : const SliverFillRemaining(hasScrollBody: false, child: NoData()),
      ),
    );
  }

  void _search() {
    if (_controller.validate()) {
      selected.value = null;
      _future = switch (widget.item) {
        TVSeries _ => Api.tvSeriesScraperSearch(
          widget.item.id,
          _controller.data['search'],
          year: _controller.data['year'],
          language: _controller.data['language'],
        ),
        Movie _ => Api.movieScraperSearch(
          widget.item.id,
          _controller.data['search'],
          year: _controller.data['year'],
          language: _controller.data['language'],
        ),
        _ => throw UnimplementedError(),
      };
      setState(() {});
    }
  }
}

class _SearchResultList extends StatefulWidget {
  const _SearchResultList({required this.items, required this.onChanged});

  final List<SearchResult> items;
  final ValueChanged<SearchResult?> onChanged;

  @override
  State<_SearchResultList> createState() => _SearchResultListState();
}

class _SearchResultListState extends State<_SearchResultList> {
  SearchResult? selected;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final SearchResult item = widget.items[index];
        return _SearchResultItem(
          key: ValueKey(item),
          item: item,
          selected: selected == item,
          onTap: () {
            selected = selected != item ? item : null;
            widget.onChanged(selected);
            setState(() {});
          },
        );
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({super.key, required this.item, this.onTap, this.selected = false});

  final SearchResult item;
  final GestureTapCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: selected ? .canvas : .transparency,
      color: selected ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ImageCard(
          src: item.poster,
          width: 120,
          height: 180,
          direction: .horizontal,
          title: Text(
            item.title == item.originalTitle ? item.title : '${item.title} (${item.originalTitle})',
            maxLines: 3,
          ),
          subtitle: Column(
            crossAxisAlignment: .stretch,
            spacing: 8,
            children: [
              Text(item.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
              Text(item.overview ?? ' ', maxLines: 5, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
