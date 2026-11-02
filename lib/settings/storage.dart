import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../components/components.dart';
import '../../l10n/app_localizations.dart';
import '../../menus/storage.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';
import '../view_models/view_models.dart';

class SettingsStoragePage extends StatelessWidget {
  const SettingsStoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: Text(AppLocalizations.of(context)!.pageTitleAccount),
      actions: [
        IconButton(onPressed: () => context.pushNamed(.settingsStorageAdd), icon: const Icon(Icons.add_rounded)),
      ],
      child: ListViewModelConsumer<StorageListViewModel, Storage>(
        builder: (context, items, _) => ListView.builder(
          itemCount: items.length,
          padding: SettingPageTheme.of(context).contentPadding,
          itemBuilder: (context, index) {
            final Storage item = items.elementAt(index);
            return Material(
              type: .transparency,
              child: ActionListTile(
                autofocus: index == 0,
                title: Text(item.name),
                subtitle: Text(AppLocalizations.of(context)!.driverType(item.type.name)),
                leading: AspectRatio(
                  aspectRatio: 1,
                  child: item.avatar == null
                      ? AspectRatio(
                          aspectRatio: 1,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              borderRadius: const BorderRadius.all(Radius.circular(6)),
                            ),
                            child: const Icon(Icons.person_rounded, size: 36),
                          ),
                        )
                      : AsyncImage(item.avatar!, radius: BorderRadius.circular(6), ink: true),
                ),
                actions: StorageMenu(item),
              ),
            );
          },
        ),
      ),
    );
  }
}

class StorageListViewModel extends ListViewModelBase<Storage> {
  StorageListViewModel() : snapshot = const AsyncSnapshot.waiting() {
    _subscription = MergeStream([
      EventDispatcher.where(type: .storage, subType: .add),
      EventDispatcher.where(type: .storage, subType: .delete),
    ]).listen((_) => load());
  }

  StreamSubscription<EventData>? _subscription;

  @override
  AsyncSnapshot<List<Storage>> snapshot;

  @override
  Future<void> load() async {
    try {
      final List<Storage> data = await Api.storageQueryAll();
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
    return ChangeNotifierProvider(create: (_) => this, child: const SettingsStoragePage());
  }
}
