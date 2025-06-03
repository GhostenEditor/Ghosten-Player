import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/error_message.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../../validators/validators.dart';
import '../../components/focusable_image.dart';
import '../../components/text_field_focus.dart';

class SearchResultSelect<T extends MediaBase> extends StatefulWidget {
  const SearchResultSelect({super.key, required this.item});

  final T item;

  @override
  State<SearchResultSelect> createState() => _SearchResultSelectState();
}

class _SearchResultSelectState extends State<SearchResultSelect> {
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
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/tv/images/bg-stripe.png'), repeat: ImageRepeat.repeat),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withAlpha(0xaa),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: const [0.2, 0.5],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Flexible(
                  child:
                      loading
                          ? const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: LinearProgressIndicator())
                          : error != null
                          ? ErrorMessage(error: error)
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 12,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: Theme.of(context).textTheme.titleMedium,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (item.originalTitle != null)
                                                Text(
                                                  item.originalTitle!,
                                                  style: Theme.of(context).textTheme.labelSmall,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (item.airDate != null)
                                          Text(item.airDate!.format(), style: Theme.of(context).textTheme.labelMedium),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 16,
                                      children: [
                                        FocusableImage(
                                          autofocus: index == 0,
                                          width: 120,
                                          height: 180,
                                          poster: item.poster,
                                          onTap: () => Navigator.of(context).pop((item.id, item.type, languageCode)),
                                        ),
                                        Expanded(
                                          child: Text(
                                            item.overview ?? ' ',
                                            maxLines: 8,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: items.length,
                          ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Align(
                    alignment: const Alignment(0, -0.5),
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFieldFocus(
                              child: TextFormField(
                                controller: _controller1,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.title),
                                  border: const UnderlineInputBorder(),
                                  isDense: true,
                                  labelText: AppLocalizations.of(context)!.formLabelTitle,
                                ),
                                validator: (value) => requiredValidator(context, value),
                                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                              ),
                            ),
                            TextFieldFocus(
                              child: TextFormField(
                                controller: _controller2,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.calendar_month_outlined),
                                  border: const UnderlineInputBorder(),
                                  isDense: true,
                                  labelText: AppLocalizations.of(context)!.formLabelYear,
                                ),
                                validator: (value) => yearValidator(context, value),
                                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                              ),
                            ),
                            DropdownButtonFormField(
                              value: languageCode,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.language_rounded),
                                border: const UnderlineInputBorder(),
                                isDense: true,
                                labelText: AppLocalizations.of(context)!.formLabelLanguage,
                              ),
                              items:
                                  AppLocalizations.supportedLocales
                                      .map(
                                        (locale) => DropdownMenuItem(
                                          value: locale.toLanguageTag(),
                                          child: Text(locale.toLanguageTag()),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (code) {
                                if (code == null) return;
                                setState(() {
                                  languageCode = code;
                                });
                              },
                            ),
                            ElevatedButton(
                              onPressed: _search,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 64),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              child: Text(AppLocalizations.of(context)!.buttonConfirm),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
