import 'package:api/api.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:video_player/player.dart';

import '../../components/async_image.dart';
import '../../components/no_data.dart';
import '../../components/playing_icon.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../components/image_card.dart';
import '../components/loading.dart';
import '../player/player_controls_lite.dart';
import '../utils/notification.dart';
import 'dialogs/live_edit.dart';

class LiveListPage extends StatefulWidget {
  const LiveListPage({super.key});

  @override
  State<LiveListPage> createState() => _LiveListPageState();
}

class _LiveListPageState extends State<LiveListPage> {
  final _controller = PlayerController<Channel>(Api.log);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Column(
              children: [
                PlayerControlsLite(_controller, artwork: Container(color: Colors.black)),
                Expanded(
                  child: Scaffold(
                    primary: false,
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      primary: false,
                      title: Text(AppLocalizations.of(context)!.homeTabLive),
                      actions: [IconButton(onPressed: () => _addPlaylist(context), icon: const Icon(Icons.add))],
                    ),
                    body: BlocBuilder<IptvCubit, List<Playlist>?>(
                      builder: (context, items) {
                        return items == null
                            ? const Loading()
                            : items.isEmpty
                            ? const NoData()
                            : LayoutBuilder(
                              builder: (context, constraints) {
                                return ListView.builder(
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    return Material(
                                      clipBehavior: Clip.hardEdge,
                                      child: Slidable(
                                        endActionPane: ActionPane(
                                          extentRatio: (48 * 3) / constraints.maxWidth,
                                          motion: const BehindMotion(),
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                final resp = await showNotification(
                                                  context,
                                                  Api.playlistRefreshById(item.id),
                                                );
                                                if (resp?.error == null && context.mounted) {
                                                  context.read<IptvCubit>().update();
                                                }
                                              },
                                              icon: const Icon(Icons.refresh),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                final flag = await showDialog(
                                                  context: context,
                                                  builder: (context) => LiveEditPage(item: item),
                                                );
                                                if (flag == true && context.mounted) {
                                                  context.read<IptvCubit>().update();
                                                }
                                              },
                                              icon: const Icon(Icons.edit),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                final confirm = await showConfirm(
                                                  context,
                                                  AppLocalizations.of(context)!.deleteConfirmText,
                                                );
                                                if (confirm != true) return;
                                                if (!context.mounted) return;
                                                final resp = await showNotification(
                                                  context,
                                                  Api.playlistDeleteById(item.id),
                                                );
                                                if (resp?.error != null) return;
                                                if (!context.mounted) return;
                                                context.read<IptvCubit>().update();
                                              },
                                              icon: const Icon(Icons.delete_outline),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          title:
                                              item.title == null
                                                  ? null
                                                  : Text(item.title!, overflow: TextOverflow.ellipsis),
                                          subtitle: Text(item.url, overflow: TextOverflow.ellipsis),
                                          trailing: const Icon(Icons.chevron_right),
                                          onTap: () async {
                                            if (MediaQuery.of(context).size.aspectRatio <= 1) {
                                              final playlist = await Api.playlistChannelsQueryById(item.id);
                                              _controller.setPlaylist(playlist.map(FromMedia.fromChannel).toList());
                                              _controller.play();
                                              if (context.mounted) {
                                                _showBottomSheet(
                                                  context: context,
                                                  builder:
                                                      (context) => _ChannelListGrouped(
                                                        controller: _controller,
                                                        activeIndex: _controller.index.value,
                                                        onTap: (index) async {
                                                          await _controller.next(index);
                                                          await _controller.play();
                                                        },
                                                      ),
                                                );
                                              }
                                            } else {
                                              final playlist = await Api.playlistChannelsQueryById(item.id);
                                              _controller.setPlaylist(playlist.map(FromMedia.fromChannel).toList());
                                              _controller.play();
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.aspectRatio > 1)
            Flexible(
              flex: 2,
              child: ListenableBuilder(
                listenable: Listenable.merge([_controller.index, _controller.playlist]),
                builder:
                    (context, _) => _ChannelList(
                      playlist: _controller.playlist.value,
                      activeIndex: _controller.index.value,
                      onTap: (index) async {
                        await _controller.next(index);
                        await _controller.play();
                      },
                    ),
              ),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }

  Future<void> _addPlaylist(BuildContext context) async {
    final flag = await showDialog(context: context, builder: (context) => const LiveEditPage());
    if (flag == true && context.mounted) context.read<IptvCubit>().update();
  }

  void _showBottomSheet<T>({required BuildContext context, required WidgetBuilder builder}) {
    final constraints = BoxConstraints(
      maxHeight: (Scaffold.of(context).context.findRenderObject()! as RenderBox).size.height + 104,
    );
    showBottomSheet(
      context: context,
      constraints: constraints,
      enableDrag: true,
      showDragHandle: true,
      builder: builder,
    );
  }
}

class _ChannelList extends StatefulWidget {
  const _ChannelList({required this.playlist, required this.onTap, this.activeIndex});

  final List<PlaylistItemDisplay<Channel>> playlist;
  final int? activeIndex;
  final Function(int) onTap;

  @override
  State<_ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<_ChannelList> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant _ChannelList oldWidget) {
    if (widget.playlist != oldWidget.playlist) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          widget.playlist.isEmpty
              ? const NoData()
              : Scrollbar(
                interactive: true,
                controller: _scrollController,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverSafeArea(
                      sliver: SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid.builder(
                          itemCount: widget.playlist.length,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 120,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 16,
                          ),
                          itemBuilder: (context, index) {
                            final item = widget.playlist[index].source;
                            return ImageCard(
                              item.image,
                              fit: BoxFit.contain,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              title: item.title != null ? Text(item.title!) : null,
                              subtitle: item.category != null ? Text(item.category!) : null,
                              floating:
                                  widget.activeIndex == index
                                      ? ColoredBox(
                                        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(0x66),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: PlayingIcon(color: Theme.of(context).colorScheme.primary),
                                        ),
                                      )
                                      : null,
                              onTap: () => widget.onTap(index),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _ChannelListGrouped extends StatefulWidget {
  const _ChannelListGrouped({required this.controller, required this.onTap, this.activeIndex});

  final PlayerController<Channel> controller;
  final int? activeIndex;
  final Function(int) onTap;

  @override
  State<_ChannelListGrouped> createState() => _ChannelListGroupedState();
}

class _ChannelListGroupedState extends State<_ChannelListGrouped> {
  late final _groupedPlaylist = widget.controller.playlist.value.groupListsBy((channel) => channel.source.category);
  late final _playlist = ValueNotifier<List<PlaylistItemDisplay<Channel>>>([]);
  final _groupName = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _groupName.dispose();
    _playlist.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Flexible(
            flex: 2,
            child: ListenableBuilder(
              listenable: _groupName,
              builder: (context, _) {
                return ListView.builder(
                  itemCount: _groupedPlaylist.keys.length,
                  itemBuilder: (context, index) {
                    final name = _groupedPlaylist.keys.elementAt(index);
                    return ListTile(
                      dense: true,
                      selected: _groupName.value == name,
                      selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                      title: Text(name ?? AppLocalizations.of(context)!.tagUnknown),
                      onTap: () {
                        _groupName.value = name;
                        _playlist.value = _groupedPlaylist[name]!;
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
              listenable: Listenable.merge([_playlist, widget.controller.index]),
              builder: (context, _) {
                return _playlist.value.isNotEmpty
                    ? ListView.builder(
                      itemCount: _playlist.value.length,
                      itemBuilder: (context, index) {
                        final item = _playlist.value.elementAt(index);
                        return ListTile(
                          dense: true,
                          leading:
                              item.poster != null ? AsyncImage(item.poster!, width: 40, showErrorWidget: false) : null,
                          trailing:
                              item == widget.controller.currentItem
                                  ? PlayingIcon(color: Theme.of(context).colorScheme.primary)
                                  : null,
                          selected: item == widget.controller.currentItem,
                          selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                          title: Text(item.title ?? ''),
                          onTap: () => widget.onTap(widget.controller.playlist.value.indexOf(item)),
                        );
                      },
                    )
                    : const NoData();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class IptvCubit extends Cubit<List<Playlist>?> {
  IptvCubit([super.initialState]) {
    update();
  }

  static bool refreshed = false;

  Future<void> update() async {
    final playlists = await Api.playlistQueryAll();
    emit(playlists);
  }
}
