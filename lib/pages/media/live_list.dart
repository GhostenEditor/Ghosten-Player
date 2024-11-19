import 'package:api/api.dart';
import 'package:flutter/material.dart' hide PopupMenuItem;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:player_view/player.dart';

import '../../components/appbar_progress.dart';
import '../../components/async_image.dart';
import '../../components/focus_card.dart';
import '../../components/future_builder_handler.dart';
import '../../components/logo.dart';
import '../../components/no_data.dart';
import '../../components/pop_to_top.dart';
import '../../components/popup_menu.dart';
import '../../models/models.dart';
import '../../platform_api.dart';
import '../../theme.dart';
import '../../utils/notification.dart';
import '../../utils/player.dart';
import '../../utils/utils.dart';
import '../player/cast_adaptor.dart';
import 'live_edit.dart';

class LiveList extends StatefulWidget {
  const LiveList({super.key});

  @override
  State<LiveList> createState() => _LiveListState();
}

class _LiveListState extends State<LiveList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.all(12), child: Logo()),
        title: Text(AppLocalizations.of(context)!.homeTabLive),
        bottom: const AppbarProgressIndicator(),
        actions: [
          IconButton(onPressed: _addPlaylist, icon: const Icon(Icons.add)),
        ],
        systemOverlayStyle: getSystemUiOverlayStyle(context),
      ),
      body: FutureBuilderHandler<List<Playlist>>(
          future: Api.playlistQueryAll(),
          builder: (context, snapshot) {
            return snapshot.requireData.isEmpty
                ? NoData(
                    action: IconButton.filled(onPressed: _addPlaylist, autofocus: PlatformApi.isAndroidTV(), icon: const Icon(Icons.add)),
                  )
                : ListView.builder(
                    itemCount: snapshot.requireData.length,
                    itemBuilder: (context, index) {
                      final item = snapshot.requireData[index];
                      return ListTile(
                        autofocus: PlatformApi.isAndroidTV() && index == 0,
                        title: item.title == null ? null : Text(item.title!, overflow: TextOverflow.ellipsis),
                        subtitle: Text(item.url, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final flag = await navigateTo<bool>(context, _ChannelList(playlist: item));
                          if (flag == true) setState(() {});
                        },
                      );
                    });
          }),
    );
  }

  _addPlaylist() async {
    final flag = await navigateTo(context, const LiveEditPage());
    if (flag == true) setState(() {});
  }
}

class _ChannelList extends StatefulWidget {
  final Playlist playlist;

  const _ChannelList({required this.playlist});

  @override
  State<_ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<_ChannelList> {
  final _scrollController = ScrollController();
  late Playlist _playlist = widget.playlist;
  bool _refresh = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: darkTheme,
      child: Builder(builder: (context) {
        return PopToTop(
          controller: _scrollController,
          onPop: () => Navigator.of(context).pop(_refresh),
          child: Scaffold(
            appBar: AppBar(
              title: _playlist.title == null ? null : Text(_playlist.title!),
              actions: [
                if (!PlatformApi.isAndroidTV()) IconButton(onPressed: () => cast(context), icon: const Icon(Icons.airplay_rounded)),
                PopupMenuButton(
                    itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            autofocus: PlatformApi.isAndroidTV(),
                            title: Text(AppLocalizations.of(context)!.buttonRefresh),
                            leading: const Icon(Icons.refresh),
                            onTap: () async {
                              final resp = await showNotification(context, Api.playlistRefreshById(_playlist.id));
                              if (resp?.error == null) setState(() {});
                            },
                          ),
                          PopupMenuItem(
                            title: Text(AppLocalizations.of(context)!.buttonEdit),
                            leading: const Icon(Icons.edit),
                            onTap: () async {
                              final flag = await navigateTo(context, LiveEditPage(item: _playlist));
                              if (flag == true) {
                                _playlist = await Api.playlistQueryById(_playlist.id);
                                setState(() => _refresh = true);
                              }
                            },
                          ),
                          PopupMenuItem(
                            leading: const Icon(Icons.delete),
                            title: Text(AppLocalizations.of(context)!.buttonDelete),
                            onTap: () async {
                              final confirm = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText);
                              if (confirm != true) return;
                              if (!context.mounted) return;
                              final resp = await showNotification(context, Api.playlistDeleteById(_playlist.id));
                              if (resp?.error != null) return;
                              if (!context.mounted) return;
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ]),
              ],
              systemOverlayStyle: getSystemUiOverlayStyle(context, ThemeMode.dark),
            ),
            body: FutureBuilderHandler<List<Channel>>(
                future: Api.playlistChannelsQueryById(_playlist.id),
                builder: (context, snapshot) {
                  return snapshot.requireData.isEmpty
                      ? const NoData()
                      : Scrollbar(
                          controller: _scrollController,
                          child: GridView.builder(
                              controller: _scrollController,
                              itemCount: snapshot.requireData.length,
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 198, childAspectRatio: 1),
                              padding: const EdgeInsets.all(8),
                              itemBuilder: (context, index) {
                                final item = snapshot.requireData[index];
                                return FocusCard(
                                  autofocus: PlatformApi.isAndroidTV() && index == 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(36),
                                            child: item.image != null
                                                ? AsyncImage(item.image!, ink: true, fit: BoxFit.contain)
                                                : const Icon(Icons.image_not_supported_outlined, size: 48),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (item.title != null)
                                                Text(item.title!, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                                              if (item.category != null)
                                                Text(item.category!, style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () => toPlayer(
                                    context,
                                    snapshot.requireData.map(FromMedia.fromChannel).toList(),
                                    id: item.id,
                                    playerType: PlayerType.live,
                                  ),
                                );
                              }),
                        );
                }),
          ),
        );
      }),
    );
  }

  cast(BuildContext context) async {
    final device = await showModalBottomSheet<CastDevice>(
      context: context,
      builder: (context) => const PlayerCastSearcher(CastAdaptor()),
    );
    final playlist = await Api.playlistChannelsQueryById(_playlist.id);
    if (device != null && context.mounted) {
      await toPlayerCast(context, device, playlist.map(FromMedia.fromChannel).toList());
    }
  }
}
