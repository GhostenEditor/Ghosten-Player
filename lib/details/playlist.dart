import 'package:api/api.dart';
import 'package:collection/collection.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart' hide ListTile;

import '../../components/components.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';
import '../extensions/extensions.dart';

class PlaylistChannelsPage extends StatelessWidget {
  const PlaylistChannelsPage({super.key, required this.item});

  final Playlist item;

  @override
  Widget build(BuildContext context) {
    final Widget child = FutureBuilderHandler(
      future: Api.playlistChannelsQueryById(item.id),
      builder: (context, snapshot) => ChannelsPage(
        items: snapshot.requireData,
        onTap: (index) => context.pushNamed(
          .livePlayer,
          arguments: PlaylistData(
            playlist: snapshot.requireData.map(FromMedia.fromChannel).toList(),
            activeIndex: index,
          ),
        ),
      ),
    );
    return DeviceOrientationBuilder(
      builder: (context, orientation) => Scaffold(
        appBar: orientation == .portrait
            ? AppBar(
                title: Column(
                  crossAxisAlignment: .start,
                  children: [
                    if (item.title != null) Text(item.title!),
                    Text(item.url, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              )
            : null,
        body: child,
      ),
    );
  }
}

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key, required this.items, required this.onTap, this.activeIndex, this.showEpg = false});

  final List<Channel> items;
  final Function(int) onTap;
  final int? activeIndex;
  final bool showEpg;

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  final _groupItems = ValueNotifier<List<Channel>>([]);
  final _groupName = ValueNotifier<String?>(null);
  final _epg = ValueNotifier<List<ChannelEpgItem>?>([]);
  late Map<String?, List<Channel>> _groupedPlaylist = widget.items.groupListsBy((channel) => channel.category);
  late final _activeIndex = ValueNotifier<int?>(widget.activeIndex);

  @override
  void initState() {
    super.initState();
    final int? index = widget.activeIndex;
    if (index != null) {
      _groupName.value = widget.items[index].category;
      _groupItems.value = _groupedPlaylist[_groupName.value]!;
      if (widget.showEpg) {
        _updateEpg(widget.items[index].id);
      }
    }
  }

  @override
  void didUpdateWidget(covariant ChannelsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _groupedPlaylist = widget.items.groupListsBy((channel) => channel.category);
      _groupItems.value = _groupedPlaylist[_groupName.value] ?? [];
    }
    if (widget.activeIndex != oldWidget.activeIndex) {
      _activeIndex.value = widget.activeIndex;
    }
  }

  @override
  void dispose() {
    _groupName.dispose();
    _groupItems.dispose();
    _epg.dispose();
    _activeIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Theme.of(context).extension<AppTheme>()!;
    final List<Channel> playlist = widget.items;
    return playlist.isEmpty
        ? const NoData()
        : ListTileTheme(
            data: ListTileTheme.of(context).copyWith(
              dense: true,
              selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
              selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                  child: ListenableBuilder(
                    listenable: _groupName,
                    builder: (context, _) {
                      return ListView.builder(
                        padding: theme.channelsListViewPadding.add(MediaQuery.of(context).padding),
                        itemCount: _groupedPlaylist.keys.length,
                        itemBuilder: (context, index) {
                          final String? name = _groupedPlaylist.keys.elementAt(index);
                          return ListTile(
                            selected: _groupName.value == name,
                            title: Text(name ?? AppLocalizations.of(context)!.tagUnknown),
                            trailing: Text('${_groupedPlaylist[name]?.length ?? 0}'),
                            onTap: () {
                              _groupName.value = name;
                              _groupItems.value = _groupedPlaylist[name]!;
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 1, indent: 0, endIndent: 0),
                Flexible(
                  flex: 3,
                  child: ListenableBuilder(
                    listenable: Listenable.merge([_groupItems, _activeIndex]),
                    builder: (context, _) {
                      return _groupItems.value.isNotEmpty
                          ? ListView.builder(
                              padding: theme.channelsListViewPadding.add(MediaQuery.of(context).padding),
                              itemCount: _groupItems.value.length,
                              itemBuilder: (context, index) {
                                final Channel item = _groupItems.value.elementAt(index);
                                final bool selected =
                                    _activeIndex.value != null && item == widget.items[_activeIndex.value!];
                                return ListTile(
                                  leading: item.image != null
                                      ? AsyncImage(item.image!, width: 40, showErrorWidget: false)
                                      : null,
                                  selected: selected,
                                  title: Text(item.title ?? ''),
                                  trailing: selected ? const PlayingIcon() : Text('${item.links.length}'),
                                  onTap: () {
                                    final int index = widget.items.indexOf(item);
                                    _activeIndex.value = index;
                                    widget.onTap(index);
                                    _updateEpg(item.id);
                                  },
                                );
                              },
                            )
                          : const NoData();
                    },
                  ),
                ),
                if (widget.showEpg) const VerticalDivider(width: 1, indent: 0, endIndent: 0),
                if (widget.showEpg)
                  Flexible(
                    flex: 3,
                    child: GestureDetector(
                      behavior: .translucent,
                      onTap: () => Navigator.of(context).pop(),
                      child: ListenableBuilder(
                        listenable: _epg,
                        builder: (context, child) {
                          return _epg.value == null
                              ? child!
                              : _epg.value!.isNotEmpty
                              ? ListView.builder(
                                  padding: theme.channelsListViewPadding.copyWith(
                                    top: MediaQuery.of(context).padding.top,
                                  ),
                                  itemCount: _epg.value!.length,
                                  itemBuilder: (context, index) {
                                    final ChannelEpgItem item = _epg.value![index];
                                    final bool isPlaying = _isPlaying(item);
                                    return ListTile(
                                      selected: isPlaying,
                                      title: Text(item.title),
                                      subtitle: Text(_epgTimeFormat(item)),
                                      trailing: isPlaying
                                          ? PlayingIcon(color: Theme.of(context).colorScheme.inversePrimary)
                                          : null,
                                      onTap: () {},
                                    );
                                  },
                                )
                              : const NoData();
                        },
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
              ],
            ),
          );
  }

  Future<void> _updateEpg(int id) async {
    _epg.value = null;
    _epg.value = await Api.epgQueryByChannelId(id);
  }

  bool _isPlaying(ChannelEpgItem item) {
    final now = DateTime.now();
    return item.start != null && item.stop != null && now >= item.start! && now <= item.stop!;
  }

  String _epgTimeFormat(ChannelEpgItem item) {
    if (item.start != null && item.stop != null) {
      return '${formatDate(item.start!, [HH, ':', nn])}-${formatDate(item.stop!, [HH, ':', nn])}';
    } else {
      return '';
    }
  }
}
