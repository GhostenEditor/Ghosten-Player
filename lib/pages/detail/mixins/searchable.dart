import 'dart:convert';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/async_image.dart';
import '../../../components/gap.dart';
import '../../../utils/utils.dart';
import '../dialogs/prompt_filename.dart';

mixin SearchableMixin {
  Future<bool> search(BuildContext context, Future<void> Function({required String title, int? year, int? index}) future,
      {required String title, int? year, int? index}) async {
    try {
      await future(title: title, year: year, index: index);
    } on PlatformException catch (e) {
      switch (e.code) {
        case '40401':
          if (!context.mounted) return false;
          final res =
              await showDialog<(String, int?)>(context: context, barrierDismissible: false, builder: (context) => PromptFilename(text: title, year: year));
          if (res != null) {
            if (!context.mounted) return false;
            return search(context, future, title: res.$1, year: res.$2);
          } else {
            rethrow;
          }
        case '30001':
          if (!context.mounted) return false;
          final data = (jsonDecode(e.message!) as List<dynamic>).map((e) => SearchResult.fromJson(e)).toList();
          final res = await showDialog<int>(context: context, barrierDismissible: false, builder: (context) => _SearchResultSelect(data));
          if (res != null) {
            if (!context.mounted) return false;
            return search(context, future, title: title, year: year, index: res);
          } else {
            rethrow;
          }
        default:
          rethrow;
      }
    }
    return true;
  }
}

class _SearchResultSelect extends StatefulWidget {
  const _SearchResultSelect(this.items);

  final List<SearchResult> items;

  @override
  State<_SearchResultSelect> createState() => _SearchResultSelectState();
}

class _SearchResultSelectState extends State<_SearchResultSelect> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.modalTitleNotification),
      content: SizedBox(
        width: 600,
        child: Scrollbar(
          child: ListView.separated(
            itemCount: widget.items.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return InkWell(
                onTap: () => Navigator.of(context).pop(index),
                customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                              if (item.originalTitle != null)
                                Text(item.originalTitle!, style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis),
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
                            child: item.poster != null
                                ? AsyncImage(
                                    item.poster!,
                                    radius: BorderRadius.circular(4),
                                  )
                                : Container(
                                    decoration:
                                        BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha(0x11), borderRadius: BorderRadius.circular(4)),
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
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
