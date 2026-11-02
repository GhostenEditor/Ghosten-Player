import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';
import '../view_models/view_models.dart';

class SystemSettingsPlayerHistory extends StatefulWidget {
  const SystemSettingsPlayerHistory({super.key});

  @override
  State<SystemSettingsPlayerHistory> createState() => _SystemSettingsPlayerHistoryState();
}

class _SystemSettingsPlayerHistoryState extends State<SystemSettingsPlayerHistory> {
  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: Text(AppLocalizations.of(context)!.settingsItemPlayerHistory),
      child: ListViewModelConsumer<PlayerHistoryListViewModel, PlayerHistory>(
        builder: (context, items, child) => ListView.builder(
          padding: SettingPageTheme.of(context).contentPadding,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final PlayerHistory item = items[index];
            return ListTile(
              leading: item.poster != null
                  ? AsyncImage(item.poster!, width: 48, radius: const BorderRadius.all(Radius.circular(4)))
                  : child,
              title: Text(item.title, overflow: TextOverflow.ellipsis, maxLines: 2),
              trailing: item.duration > Duration.zero
                  ? SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        value: item.lastPlayedPosition.inMilliseconds / item.duration.inMilliseconds,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    )
                  : null,
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.labelSmall,
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)!
                                .timeAgo(item.lastPlayedTime.fromNow().fromNowFormat(context)),
                          ),
                          const WidgetSpan(child: Gap.hLG),
                          TextSpan(text: item.lastPlayedPosition.toDisplay()),
                          const TextSpan(text: ' / '),
                          TextSpan(text: item.duration.toDisplay()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () => toMediaPlayer(context, item.mediaType, item.id),
            );
          },
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            child: Icon(Icons.image_outlined, color: Theme.of(context).colorScheme.surfaceContainerHighest, size: 32),
          ),
        ),
      ),
    );
  }
}

class PlayerHistoryListViewModel extends ListViewModelBase<PlayerHistory> {
  PlayerHistoryListViewModel() : snapshot = const AsyncSnapshot.waiting();

  @override
  AsyncSnapshot<List<PlayerHistory>> snapshot;

  @override
  Future<void> load() async {
    try {
      final List<PlayerHistory> data = await Api.playerHistory();
      snapshot = AsyncSnapshot.withData(.done, data);
    } catch (e) {
      snapshot = AsyncSnapshot.withError(.done, e);
    }
    notifyListeners();
  }

  @override
  Widget build() {
    return ChangeNotifierProvider(create: (_) => this, child: const SystemSettingsPlayerHistory());
  }
}
