import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rxdart/rxdart.dart';

import '../../components/appbar_progress.dart';
import '../../components/future_builder_handler.dart';
import '../../components/gap.dart';
import '../../components/logo.dart';
import '../../components/no_data.dart';
import '../../components/stream_builder_handler.dart';
import '../../mixins/update.dart';
import '../../models/models.dart';
import '../../utils/player.dart';
import '../../utils/utils.dart';
import '../detail/series.dart';
import '../library.dart';
import 'components/media_card.dart';
import 'mixins/media_list.dart';

class TVListPage extends StatefulWidget {
  const TVListPage({super.key});

  @override
  State<TVListPage> createState() => _TVListPageState();
}

class _TVListPageState extends State<TVListPage> with MediaListMixin, NeedUpdateMixin {
  final _controller = ScrollController();

  @override
  LibraryType get mediaType => LibraryType.tv;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.all(12), child: Logo()),
        title: Text(AppLocalizations.of(context)!.homeTabTV),
        actions: [
          buildSearchBox(),
          buildActionButton(),
        ],
        bottom: const AppbarProgressIndicator(),
        systemOverlayStyle: getSystemUiOverlayStyle(context),
      ),
      body: Scrollbar(
          controller: _controller,
          child: CustomScrollView(
            controller: _controller,
            slivers: [
              FutureBuilderSliverHandler<List<TVEpisode>>(
                  initialData: const [],
                  future: Api.tvSeriesNextToPlayQueryAll(),
                  builder: (context, snapshot) {
                    final items = snapshot.requireData;
                    return snapshot.requireData.isNotEmpty
                        ? SliverList.list(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0, left: 20),
                                child: Row(
                                  children: [
                                    const Icon(Icons.history_rounded, size: 18),
                                    const SizedBox(width: 4),
                                    Text(AppLocalizations.of(context)!.recentWatched, style: Theme.of(context).textTheme.titleSmall),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 240,
                                child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final item = items[index];
                                      return RecentMediaCard(
                                          item: item,
                                          onTap: () async {
                                            final season = await Api.tvSeasonQueryById(item.seasonId);
                                            final playlist = season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList();
                                            if (!context.mounted) return;
                                            await toPlayer(context, playlist, id: item.id, theme: item.themeColor, playerType: PlayerType.tv);
                                            setState(() {});
                                          });
                                    },
                                    separatorBuilder: (context, index) => Gap.hSM),
                              ),
                              const Divider()
                            ],
                          )
                        : const SliverToBoxAdapter();
                  }),
              StreamBuilderSliverHandler<List<TVSeries>>(
                stream: categoryStream.stream.switchMap((data) => Stream.fromFuture(Api.tvSeriesQueryAll(data))),
                builder: (context, snapshot) {
                  final items = snapshot.requireData;
                  return items.isNotEmpty
                      ? SliverPadding(
                          padding: const EdgeInsets.only(left: 16, top: 4, right: 16, bottom: 16),
                          sliver: SliverGrid.builder(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, childAspectRatio: 0.56),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return MediaCard(
                                  key: ValueKey('${item.id}${item.title}${item.airDate}'),
                                  item: item,
                                  onTap: () async {
                                    final flag = await navigateTo<bool>(context, TVDetail(tvSeriesId: item.id, initialData: item));
                                    if (flag == true) setState(() {});
                                  },
                                );
                              }),
                        )
                      : SliverFillRemaining(
                          child: NoData(
                            action: FilledButton(
                              autofocus: true,
                              child: Text(AppLocalizations.of(context)!.settingsItemTV),
                              onPressed: () async {
                                final refresh =
                                    await navigateTo<bool>(context, LibraryManage(title: AppLocalizations.of(context)!.settingsItemTV, type: mediaType));
                                if (refresh == true) {
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                        );
                },
              ),
            ],
          )),
    );
  }
}
