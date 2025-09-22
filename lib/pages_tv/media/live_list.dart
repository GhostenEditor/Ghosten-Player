import 'package:api/api.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../components/async_image.dart';
import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../components/focusable_image.dart';
import '../components/future_builder_handler.dart';
import '../components/icon_button.dart';
import '../components/setting.dart';
import '../player/live_player.dart';
import '../utils/notification.dart';
import '../utils/utils.dart';
import 'live_edit.dart';

class LiveListPage extends StatefulWidget {
  const LiveListPage({super.key});

  @override
  State<LiveListPage> createState() => _LiveListPageState();
}

class _LiveListPageState extends State<LiveListPage> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _rootFocusNode = FocusNode();
  final _selectedPlaylistId = ValueNotifier<int?>(null);

  @override
  void dispose() {
    _rootFocusNode.dispose();
    _selectedPlaylistId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderHandler<List<Playlist>>(
      future: Api.playlistQueryAll(),
      builder: (context, snapshot) {
        _selectedPlaylistId.value = snapshot.requireData.firstOrNull?.id;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 2,
              child:
                  snapshot.requireData.isEmpty
                      ? NoData(
                        action: TVIconButton.filledTonal(
                          onPressed: _addPlaylist,
                          autofocus: true,
                          icon: const Icon(Icons.add),
                        ),
                      )
                      : Material(
                        type: MaterialType.transparency,
                        clipBehavior: Clip.hardEdge,
                        child: ListenableBuilder(
                          listenable: _selectedPlaylistId,
                          builder: (context, _) {
                            return ListView.separated(
                              itemCount: snapshot.requireData.length + 1,
                              padding: const EdgeInsets.only(left: 36, right: 12, top: 60, bottom: 60),
                              itemBuilder: (context, index) {
                                if (index < snapshot.requireData.length) {
                                  final item = snapshot.requireData[index];
                                  return SlidableSettingItem(
                                    selected: _selectedPlaylistId.value == item.id,
                                    autofocus: index == 0,
                                    title:
                                        item.title == null ? null : Text(item.title!, overflow: TextOverflow.ellipsis),
                                    subtitle: Text(item.url, overflow: TextOverflow.ellipsis),
                                    onTap: () async {
                                      if (_selectedPlaylistId.value == item.id) return;
                                      _selectedPlaylistId.value = item.id;
                                      _navigatorKey.currentState!.pushAndRemoveUntil(
                                        FadeInPageRoute(builder: (context) => _ChannelList(playlistId: item.id)),
                                        (_) => false,
                                      );
                                    },
                                    actionSide: ActionSide.start,
                                    actions: [
                                      TVIconButton(
                                        icon: const Icon(Icons.delete_outline_rounded),
                                        onPressed: () async {
                                          final confirm = await showConfirm(
                                            context,
                                            AppLocalizations.of(context)!.deleteConfirmText,
                                            AppLocalizations.of(context)!.deletePlaylistTip,
                                          );
                                          if (confirm != true) return;
                                          if (!context.mounted) return;
                                          await showNotification(context, Api.playlistDeleteById(item.id));
                                          if (context.mounted) setState(() {});
                                        },
                                      ),
                                      TVIconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () async {
                                          final flag = await navigateTo<bool>(context, LiveEdit(item: item));
                                          if ((flag ?? false) && context.mounted) setState(() {});
                                        },
                                      ),
                                      TVIconButton(
                                        icon: const Icon(Icons.sync),
                                        onPressed: () async {
                                          final resp = await showNotification(
                                            context,
                                            Api.playlistRefreshById(item.id),
                                          );
                                          if (resp?.error == null) setState(() {});
                                        },
                                      ),
                                    ],
                                  );
                                } else {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TVIconButton.filledTonal(
                                        onPressed: _addPlaylist,
                                        icon: const Icon(Icons.add),
                                      ),
                                    ),
                                  );
                                }
                              },
                              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 4),
                            );
                          },
                        ),
                      ),
            ),
            if (snapshot.requireData.isNotEmpty)
              Flexible(
                flex: 3,
                child: Actions(
                  actions: {
                    DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
                      onInvoke: (indent) {
                        final currentNode = FocusManager.instance.primaryFocus;
                        if (currentNode != null) {
                          final nearestScope = currentNode.nearestScope!;
                          final focusedChild = nearestScope.focusedChild;
                          if (focusedChild == null || !focusedChild.focusInDirection(indent.direction)) {
                            switch (indent.direction) {
                              case TraversalDirection.left:
                                nearestScope.parent?.focusInDirection(indent.direction);
                              default:
                            }
                          }
                        }
                        return null;
                      },
                    ),
                  },
                  child: Navigator(
                    key: _navigatorKey,
                    requestFocus: false,
                    onGenerateRoute:
                        (settings) => FadeInPageRoute(
                          builder: (context) => _ChannelList(playlistId: snapshot.requireData.first.id),
                          settings: settings,
                        ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Future<bool> didPopRoute() async {
    _navigatorKey.currentState!.pop();
    return true;
  }

  Future<void> _addPlaylist() async {
    final resp = await navigateTo<bool>(context, const LiveEdit());
    if ((resp ?? false) && context.mounted) setState(() {});
  }
}

class _ChannelList extends StatefulWidget {
  const _ChannelList({required this.playlistId});

  final int playlistId;

  @override
  State<_ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<_ChannelList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderHandler(
      future: Api.playlistChannelsQueryById(widget.playlistId),
      builder: (context, snapshot) {
        final playlist = snapshot.requireData;
        return playlist.isEmpty
            ? const NoData()
            : Scrollbar(
              controller: _scrollController,
              child: GridView.builder(
                controller: _scrollController,
                itemCount: playlist.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 198,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                padding: const EdgeInsets.only(left: 8, right: 48, top: 60, bottom: 60),
                itemBuilder: (context, index) {
                  final item = playlist[index];
                  return _ChannelGridItem(
                    key: ValueKey(item.hashCode),
                    item: item,
                    onTap:
                        () => navigateTo(
                          navigatorKey.currentContext!,
                          LivePlayerPage(playlist: playlist.map(FromMedia.fromChannel).toList(), index: index),
                        ),
                  );
                },
              ),
            );
      },
    );
  }
}

class _ChannelGridItem extends StatelessWidget {
  const _ChannelGridItem({super.key, required this.item, this.onTap});

  final Channel item;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FocusableImage(
          poster: item.image,
          fit: BoxFit.contain,
          padding: const EdgeInsets.all(36),
          httpHeaders: const {},
          onTap: onTap,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (item.title != null)
                Text(item.title!, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
              if (item.category != null)
                Text(item.category!, style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChannelListGrouped extends StatefulWidget {
  const _ChannelListGrouped({required this.playlistId});

  final int playlistId;

  @override
  State<_ChannelListGrouped> createState() => _ChannelListGroupedState();
}

class _ChannelListGroupedState extends State<_ChannelListGrouped> {
  final _groupName = ValueNotifier<String?>(null);
  final _playlist = ValueNotifier<List<Channel>>([]);

  @override
  void dispose() {
    _groupName.dispose();
    _playlist.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderHandler(
      future: Api.playlistChannelsQueryById(widget.playlistId),
      builder: (context, snapshot) {
        final playlist = snapshot.requireData;
        final groupedPlaylist = playlist.groupListsBy((channel) => channel.category);
        return playlist.isEmpty
            ? const NoData()
            : Row(
              children: [
                Flexible(
                  flex: 2,
                  child: ListenableBuilder(
                    listenable: _groupName,
                    builder: (context, _) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 8, right: 8, top: 60, bottom: 60),
                        itemCount: groupedPlaylist.keys.length,
                        itemBuilder: (context, index) {
                          final name =
                              groupedPlaylist.keys.elementAt(index) ?? AppLocalizations.of(context)!.tagUnknown;
                          return ButtonSettingItem(
                            selected: _groupName.value == name,
                            title: Text(name),
                            onTap: () {
                              _groupName.value = name;
                              _playlist.value = groupedPlaylist[name]!;
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const VerticalDivider(),
                Flexible(
                  flex: 3,
                  child: ListenableBuilder(
                    listenable: _playlist,
                    builder: (context, _) {
                      return _playlist.value.isNotEmpty
                          ? ListView.builder(
                            padding: const EdgeInsets.only(left: 8, right: 48, top: 60, bottom: 60),
                            itemCount: _playlist.value.length,
                            itemBuilder: (context, index) {
                              final item = _playlist.value.elementAt(index);
                              return ButtonSettingItem(
                                leading:
                                    item.image != null
                                        ? AsyncImage(item.image!, width: 40, showErrorWidget: false)
                                        : null,
                                title: Text(item.title ?? ''),
                                onTap:
                                    () => navigateTo(
                                      navigatorKey.currentContext!,
                                      LivePlayerPage(
                                        playlist: playlist.map(FromMedia.fromChannel).toList(),
                                        index: playlist.indexOf(item),
                                      ),
                                    ),
                              );
                            },
                          )
                          : const NoData();
                    },
                  ),
                ),
              ],
            );
      },
    );
  }
}
