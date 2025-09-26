import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/async_image.dart';
import '../../../components/error_message.dart';
import '../../../components/gap.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../../validators/validators.dart';

class ScraperDialog<T extends MediaBase> extends StatefulWidget {
  const ScraperDialog({super.key, required this.item});

  final T item;

  @override
  State<ScraperDialog<T>> createState() => _ScraperDialogState<T>();
}

class _ScraperDialogState<T extends MediaBase> extends State<ScraperDialog<T>> {
  late final _controller1 = TextEditingController(text: widget.item.title);
  late final _controller2 = TextEditingController(text: widget.item.airDate?.year.toString());
  final _formKey = GlobalKey<FormState>();
  List<SearchResult> items = [];
  late String languageCode = Localizations.localeOf(context).toLanguageTag();
  bool loading = false;
  Object? error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(_search);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.buttonScraperMediaInfo),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller1,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.title),
                border: const UnderlineInputBorder(),
                filled: true,
                isDense: true,
                labelText: AppLocalizations.of(context)!.formLabelTitle,
              ),
              validator: (value) => requiredValidator(context, value),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            TextFormField(
              controller: _controller2,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_month_outlined),
                border: const UnderlineInputBorder(),
                filled: true,
                isDense: true,
                labelText: AppLocalizations.of(context)!.formLabelYear,
              ),
              validator: (value) => yearValidator(context, value),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
            ),
            DropdownButtonFormField(
              value: languageCode,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.language_rounded),
                border: const UnderlineInputBorder(),
                filled: true,
                isDense: true,
                labelText: AppLocalizations.of(context)!.formLabelLanguage,
              ),
              items:
                  AppLocalizations.supportedLocales
                      .map(
                        (locale) =>
                            DropdownMenuItem(value: locale.toLanguageTag(), child: Text(locale.toLanguageTag())),
                      )
                      .toList(),
              onChanged: (code) {
                if (code == null) return;
                setState(() {
                  languageCode = code;
                });
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              onPressed: _search,
              child: Text(AppLocalizations.of(context)!.buttonConfirm),
            ),
            if (loading) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: LinearProgressIndicator()),
            if (error != null) ErrorMessage(error: error),
            ...items.map(
              (item) => _SearchResultItem(
                item: item,
                onTap: () {
                  Navigator.of(context).pop((item.id, item.type, languageCode));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _search() async {
    if (_formKey.currentState!.validate()) {
      items = [];
      error = null;
      setState(() => loading = true);
      try {
        final data = switch (widget.item) {
          TVSeries _ => await Api.tvSeriesScraperSearch(
            widget.item.id,
            _controller1.text,
            year: _controller2.text,
            language: languageCode,
          ),
          Movie _ => await Api.movieScraperSearch(
            widget.item.id,
            _controller1.text,
            year: _controller2.text,
            language: languageCode,
          ),
          _ => throw UnimplementedError(),
        };
        items = data;
      } catch (err) {
        error = err;
      }
      if (mounted) setState(() => loading = false);
    }
  }
}

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({required this.item, this.onTap});

  final SearchResult item;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              spacing: 4,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                      if (item.originalTitle != null)
                        Text(
                          item.originalTitle!,
                          style: Theme.of(context).textTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (item.airDate != null) Text(item.airDate!.format(), style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            Gap.vSM,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Flexible(
                  flex: 2,
                  child: SizedBox(
                    width: 120,
                    height: 180,
                    child:
                        item.poster != null
                            ? AsyncImage(item.poster!, radius: BorderRadius.circular(4))
                            : Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withAlpha(0x11),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 42,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                            ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Text(
                    item.overview ?? ' ',
                    maxLines: 11,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
