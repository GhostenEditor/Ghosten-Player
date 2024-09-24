import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PopupMenuItem;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../../components/popup_menu.dart';
import '../../../components/search_button.dart';
import '../../../providers/user_config.dart';
import '../../../utils/utils.dart';
import '../../library.dart';

enum _Category {
  all,
  favorite,
  exceptFavorite,
  watched,
  unwatched,
  nameAsc,
  nameDesc,
  airDateAsc,
  airDateDesc,
  lastPlayTimeAsc,
  lastPlayTimeDesc,
}

mixin MediaListMixin<T extends StatefulWidget> on State<T> {
  late LibraryType mediaType;
  late SortConfig _sort = switch (mediaType) {
    LibraryType.tv => userConfig.tvList,
    LibraryType.movie => userConfig.movieList,
  };
  StreamController<MediaSearchQuery> categoryStream = BehaviorSubject();
  late final UserConfig userConfig = Provider.of(context, listen: false);
  String? search;

  @override
  void initState() {
    categoryStream.add(MediaSearchQuery(sort: _sort, search: search));
    super.initState();
  }

  @override
  void dispose() {
    categoryStream.close();
    super.dispose();
  }

  Widget buildActionButton() {
    return PopupMenuButton(
        onSelected: (c) {
          switch (c) {
            case _Category.all:
              _sort = _sort.copyWith(filter: FilterType.all);
            case _Category.favorite:
              _sort = _sort.copyWith(filter: FilterType.favorite);
            case _Category.exceptFavorite:
              _sort = _sort.copyWith(filter: FilterType.exceptFavorite);
            case _Category.watched:
              _sort = _sort.copyWith(filter: FilterType.watched);
            case _Category.unwatched:
              _sort = _sort.copyWith(filter: FilterType.unwatched);
            case _Category.nameAsc:
              _sort = _sort.copyWith(type: SortType.title, direction: SortDirection.asc);
            case _Category.nameDesc:
              _sort = _sort.copyWith(type: SortType.title, direction: SortDirection.desc);
            case _Category.airDateAsc:
              _sort = _sort.copyWith(type: SortType.airDate, direction: SortDirection.asc);
            case _Category.airDateDesc:
              _sort = _sort.copyWith(type: SortType.airDate, direction: SortDirection.desc);
            case _Category.lastPlayTimeAsc:
              _sort = _sort.copyWith(type: SortType.lastPlayedTime, direction: SortDirection.asc);
            case _Category.lastPlayTimeDesc:
              _sort = _sort.copyWith(type: SortType.lastPlayedTime, direction: SortDirection.desc);
          }

          categoryStream.add(MediaSearchQuery(sort: _sort, search: search));
          userConfig.setMediaList(mediaType, _sort);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<_Category>>[
              PopupMenuItem(
                autofocus: kIsAndroidTV,
                onTap: () async {
                  final refresh = await navigateTo<bool>(context, LibraryManage(title: _getMediaTitle(mediaType), type: mediaType));
                  if (refresh == true) {
                    setState(() {});
                  }
                },
                leading: const Icon(Icons.folder_open_rounded),
                title: Text(_getMediaTitle(mediaType).padRight(8, ' ')),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _sort.type == SortType.title && _sort.direction == SortDirection.asc ? _Category.nameDesc : _Category.nameAsc,
                leading: const Icon(Icons.abc),
                title: Text(AppLocalizations.of(context)!.buttonName),
                trailing: Icon(_sort.type == SortType.title && _sort.direction == SortDirection.asc
                    ? Icons.arrow_upward_rounded
                    : _sort.type == SortType.title && _sort.direction == SortDirection.desc
                        ? Icons.arrow_downward_rounded
                        : null),
              ),
              PopupMenuItem(
                value: _sort.type == SortType.airDate && _sort.direction == SortDirection.desc ? _Category.airDateAsc : _Category.airDateDesc,
                leading: const Icon(Icons.access_time_rounded),
                title: Text(AppLocalizations.of(context)!.buttonAirDate),
                trailing: Icon(_sort.type == SortType.airDate && _sort.direction == SortDirection.asc
                    ? Icons.arrow_upward
                    : _sort.type == SortType.airDate && _sort.direction == SortDirection.desc
                        ? Icons.arrow_downward
                        : null),
              ),
              PopupMenuItem(
                value: _sort.type == SortType.lastPlayedTime && _sort.direction == SortDirection.desc ? _Category.lastPlayTimeAsc : _Category.lastPlayTimeDesc,
                leading: const Icon(Icons.remove_red_eye_outlined),
                title: Text(AppLocalizations.of(context)!.buttonLastWatchedTime),
                trailing: Icon(_sort.type == SortType.lastPlayedTime && _sort.direction == SortDirection.asc
                    ? Icons.arrow_upward
                    : _sort.type == SortType.lastPlayedTime && _sort.direction == SortDirection.desc
                        ? Icons.arrow_downward
                        : null),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                leading: const Icon(Icons.format_list_bulleted_rounded),
                title: Text(AppLocalizations.of(context)!.buttonAll),
                trailing: Icon(_sort.filter == FilterType.all ? Icons.done : null),
                value: _Category.all,
              ),
              PopupMenuItem(
                leading: Icon(_sort.filter == FilterType.watched ? Icons.check_circle : Icons.check_circle_outline),
                title: Text(_sort.filter == FilterType.watched ? AppLocalizations.of(context)!.buttonWatched : AppLocalizations.of(context)!.buttonUnwatched),
                trailing: Icon(_sort.filter == FilterType.watched || _sort.filter == FilterType.unwatched ? Icons.check_rounded : null),
                value: _sort.filter == FilterType.unwatched ? _Category.watched : _Category.unwatched,
              ),
              PopupMenuItem(
                leading: Icon(_sort.filter == FilterType.exceptFavorite ? Icons.favorite_outline_rounded : Icons.favorite_rounded),
                title: Text(_sort.filter == FilterType.exceptFavorite
                    ? AppLocalizations.of(context)!.buttonExpectFavorite
                    : AppLocalizations.of(context)!.buttonFavorite),
                trailing: Icon(_sort.filter == FilterType.favorite || _sort.filter == FilterType.exceptFavorite ? Icons.check_rounded : null),
                value: _sort.filter == FilterType.favorite ? _Category.exceptFavorite : _Category.favorite,
              ),
            ]);
  }

  Widget buildSearchBox() {
    return SearchButton(onSearch: (res) {
      if (search != res) {
        search = res;
        categoryStream.add(MediaSearchQuery(sort: _sort, search: search));
      }
    });
  }

  String _getMediaTitle(LibraryType mediaType) {
    return switch (mediaType) {
      LibraryType.tv => AppLocalizations.of(context)!.settingsItemTV,
      LibraryType.movie => AppLocalizations.of(context)!.settingsItemMovie,
    };
  }
}
