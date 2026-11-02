import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../l10n/app_localizations.dart';
import '../../menus/library.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';
import '../providers/function.dart';
import '../view_models/view_models.dart';

class SettingsLibraryPage extends StatelessWidget {
  const SettingsLibraryPage({super.key, required this.type});

  final LibraryType type;

  @override
  Widget build(BuildContext context) {
    final FunctionConfig function = context.watch<FunctionConfig>();
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    return SettingPage(
      title: Text(switch (type) {
        LibraryType.tv => localizations.settingsItemTV,
        LibraryType.movie => localizations.settingsItemMovie,
      }),
      actions: [
        if (function.settingsLibraryAdd)
          IconButton(onPressed: () => _addLibrary(context), icon: const Icon(Icons.add_rounded)),
      ],
      child: ListViewModelConsumer<LibraryListViewModel, Library>(
        builder: (context, items, _) => ListView.builder(
          padding: SettingPageTheme.of(context).contentPadding,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final Library item = items.elementAt(index);
            final tile = Material(
              type: .transparency,
              child: ActionListTile(
                autofocus: index == 0,
                title: Text(item.filename),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: item.poster == null
                        ? Ink(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              borderRadius: const BorderRadius.all(Radius.circular(6)),
                            ),
                            child: const Icon(Icons.image_outlined, size: 24),
                          )
                        : AsyncImage(item.poster!, radius: BorderRadius.circular(6), ink: true),
                  ),
                ),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(localizations.driverType(item.driverType.name)),
                    Text(item.driverName, overflow: TextOverflow.ellipsis),
                  ],
                ),
                actions: LibraryMenu(item),
              ),
            );
            return Opacity(opacity: item.disabled ? 0.3 : 1, child: tile);
          },
        ),
      ),
    );
  }

  Future<void> _addLibrary(BuildContext context) async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final SupportedLanguages language = switch (Localizations.localeOf(context).toLanguageTag()) {
      'zh' => SupportedLanguages.zhCn,
      'en' => SupportedLanguages.enUs,
      _ => SupportedLanguages.auto,
    };
    final (int, DriverFile)? res = await showDriverFilePicker(context, switch (type) {
      LibraryType.tv => localizations.pageTitleCreateTVLibrary,
      LibraryType.movie => localizations.pageTitleCreateMovieLibrary,
    }, selectableType: FileType.folder);
    if (res != null && context.mounted) {
      final (int driverId, DriverFile file) = res;
      await showNotification<bool>(
        context,
        Future(() async {
          final dynamic id = await Api.libraryInsert(
            type: type,
            driverId: driverId,
            id: file.id,
            parentId: file.parentId,
            filename: file.name,
          );
          await Api.libraryRefreshById(id, language);
          return true;
        }),
      );
    }
  }
}

class LibraryListViewModel extends ListViewModelBase<Library> {
  LibraryListViewModel({required this.type}) {
    _subscription = EventDispatcher.where(type: .library).listen((_) => load());
  }

  final LibraryType type;

  StreamSubscription<EventData>? _subscription;

  @override
  AsyncSnapshot<List<Library>> snapshot = const AsyncSnapshot.waiting();

  @override
  Future<void> load() async {
    try {
      final List<Library> data = await Api.libraryQueryAll(type);
      snapshot = AsyncSnapshot.withData(.done, data);
    } catch (e) {
      snapshot = AsyncSnapshot.withError(.done, e);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build() {
    return ChangeNotifierProvider(
      create: (_) => this,
      child: SettingsLibraryPage(type: type),
    );
  }
}
