import 'dart:convert';

import 'package:api/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/gap.dart';
import '../../../utils/utils.dart';
import '../../components/focusable_image.dart';
import '../dialogs/search_no_result.dart';

mixin SearchableMixin {
  Future<bool> search(
    BuildContext context,
    Future<void> Function({required String title, int? year, int? index}) future, {
    required String title,
    int? year,
    int? index,
  }) async {
    try {
      await future(title: title, year: year, index: index);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.badResponse:
          switch (e.response?.statusCode) {
            case 404:
              if (!context.mounted) return false;
              final res = await navigateTo<(String, int?)>(navigatorKey.currentContext!, SearchNoResult(text: title, year: year));
              if (res != null) {
                if (!context.mounted) return false;
                return search(context, future, title: res.$1, year: res.$2);
              } else {
                rethrow;
              }
            case 300:
              if (!context.mounted) return false;
              final data = (e.response?.data! as List<dynamic>).map((e) => SearchResult.fromJson(e)).toList();
              final res = await navigateTo<int>(
                  navigatorKey.currentContext!,
                  _SearchResultSelect(
                    items: data,
                    title: title,
                    year: year,
                  ));
              if (!context.mounted) return false;
              if (res != null) {
                return search(context, future, title: title, year: year, index: res);
              } else {
                rethrow;
              }
            default:
              rethrow;
          }
        default:
          rethrow;
      }
    } on PlatformException catch (e) {
      switch (e.code) {
        case '40401':
          if (!context.mounted) return false;
          final res = await navigateTo<(String, int?)>(navigatorKey.currentContext!, SearchNoResult(text: title, year: year));
          if (res != null) {
            if (!context.mounted) return false;
            return search(context, future, title: res.$1, year: res.$2);
          } else {
            rethrow;
          }
        case '30001':
          if (!context.mounted) return false;
          final data = (jsonDecode(e.message!) as List<dynamic>).map((e) => SearchResult.fromJson(e)).toList();
          final res = await navigateTo<int>(
              navigatorKey.currentContext!,
              _SearchResultSelect(
                items: data,
                title: title,
                year: year,
              ));
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
  final String title;
  final int? year;
  final List<SearchResult> items;

  const _SearchResultSelect({required this.items, required this.title, this.year});

  @override
  State<_SearchResultSelect> createState() => _SearchResultSelectState();
}

class _SearchResultSelectState extends State<_SearchResultSelect> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg-stripe.png'),
              repeat: ImageRepeat.repeat,
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black38,
                Colors.black,
              ],
              stops: [0.2, 0.5],
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
                      fit: FlexFit.tight,
                      child: Align(
                        alignment: const Alignment(-1, -0.2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.title, style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold)),
                              Text(widget.year?.toString() ?? '', style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.grey)),
                              Gap.vLG,
                              Text(AppLocalizations.of(context)!.searchMultiResultTip, style: Theme.of(context).textTheme.labelLarge),
                            ],
                          ),
                        ),
                      )),
                  Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                      itemBuilder: (context, index) {
                        final item = widget.items[index];

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                              Gap.vMD,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FocusableImage(
                                    autofocus: index == 0,
                                    width: 120,
                                    height: 180,
                                    poster: item.poster,
                                    onTap: () => Navigator.of(context).pop(index),
                                  ),
                                  Gap.hLG,
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
                      itemCount: widget.items.length,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
