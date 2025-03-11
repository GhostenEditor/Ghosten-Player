import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/no_data.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../components/filled_button.dart';
import '../components/future_builder_handler.dart';
import '../detail/series.dart';
import '../mixins/update.dart';
import '../settings/settings_library.dart';
import '../utils/player.dart';
import '../utils/utils.dart';
import 'components/carousel.dart';
import 'components/media_grid_item.dart';
import 'mixins/channel.dart';

class TVListPage extends StatefulWidget {
  const TVListPage({super.key, required this.endDrawerNavigatorKey});

  final GlobalKey<NavigatorState> endDrawerNavigatorKey;

  @override
  State<TVListPage> createState() => _TVListPageState();
}

class _TVListPageState extends State<TVListPage> with NeedUpdateMixin, ChannelMixin {
  final _backdrop = ValueNotifier<String?>(null);
  final _carouselIndex = ValueNotifier<int?>(null);
  final _showBlur = ValueNotifier(false);
  final _controller = ScrollController();

  @override
  void initState() {
    _controller.addListener(() {
      final halfHeight = MediaQuery.of(context).size.height / 2;
      _showBlur.value = _controller.offset > halfHeight;
    });
    super.initState();
  }

  @override
  void dispose() {
    _backdrop.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: ListenableBuilder(listenable: _backdrop, builder: (context, _) => CarouselBackground(src: _backdrop.value)),
        ),
        AspectRatio(
          aspectRatio: 2,
          child: ListenableBuilder(
              listenable: _showBlur,
              builder: (context, _) => AnimatedOpacity(
                    opacity: _showBlur.value ? 0.54 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: Container(
                      width: 200,
                      height: 200,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  )),
        ),
        CustomScrollView(
          controller: _controller,
          slivers: [
            FutureBuilderSliverHandler(
              future: Api.tvRecommendation(),
              builder: (context, snapshot) {
                Future.microtask(() {
                  if (snapshot.requireData.isNotEmpty) {
                    _backdrop.value = snapshot.requireData[0].backdrop;
                  } else {
                    _backdrop.value = null;
                  }
                });
                return SliverToBoxAdapter(
                  child: AspectRatio(
                    aspectRatio: snapshot.requireData.isNotEmpty ? 32 / 15 : 1.8,
                    child: snapshot.requireData.isNotEmpty
                        ? ListenableBuilder(
                            listenable: _carouselIndex,
                            builder: (context, _) {
                              final item = snapshot.requireData.elementAtOrNull(_carouselIndex.value ?? 0) ?? snapshot.requireData.first;
                              return Carousel(
                                key: ValueKey(snapshot.requireData.length),
                                index: _carouselIndex.value ?? 0,
                                len: snapshot.requireData.length,
                                onFocusChange: (f) {
                                  if (f) {
                                    _controller.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
                                  }
                                },
                                onChange: (index) {
                                  _backdrop.value = snapshot.requireData[index].backdrop;
                                  _carouselIndex.value = index;
                                },
                                child: CarouselItem(
                                  key: ValueKey(item.id),
                                  item: item,
                                  onPressed: () async {
                                    final series = await Api.tvSeriesQueryById(item.id);
                                    final season = await Api.tvSeasonQueryById(series.nextToPlay!.seasonId);
                                    final playlist = season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList();
                                    if (!context.mounted) return;
                                    await toPlayer(
                                      context,
                                      playlist,
                                      index: season.episodes.indexWhere((episode) => episode.id == series.nextToPlay!.id),
                                      theme: item.themeColor,
                                    );
                                    setState(() {});
                                  },
                                ),
                              );
                            })
                        : Center(
                            child: NoData(
                            action: TVFilledButton(
                              autofocus: true,
                              child: Text(AppLocalizations.of(context)!.settingsItemTV),
                              onPressed: () async {
                                Scaffold.of(context).openEndDrawer();
                                await Future.delayed(const Duration(milliseconds: 100));
                                if (context.mounted) {
                                  navigateToSlideLeft(widget.endDrawerNavigatorKey.currentContext!,
                                      LibraryManage(title: AppLocalizations.of(context)!.settingsItemTV, type: LibraryType.tv));
                                }
                              },
                            ),
                          )),
                  ),
                );
              },
            ),
            buildChannel(
              context,
              label: AppLocalizations.of(context)!.watchNow,
              future: Api.tvSeriesNextToPlayQueryAll(),
              height: 240,
              builder: (context, item) => Stack(
                children: [
                  MediaGridItem(
                      imageWidth: 240,
                      imageHeight: 240 / 1.78,
                      title: Text(item.displayRecentTitle()),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (item.lastPlayedTime != null)
                            Text(AppLocalizations.of(context)!.timeAgo(item.lastPlayedTime!.fromNow().fromNowFormat(context)),
                                style: Theme.of(context).textTheme.labelSmall)
                          else
                            const Spacer(),
                          if (item.duration != null && item.lastPlayedTime != null)
                            Text('${(item.lastPlayedPosition!.inSeconds / item.duration!.inSeconds * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                      imageUrl: item.poster,
                      onTap: () async {
                        final season = await Api.tvSeasonQueryById(item.seasonId);
                        final playlist = season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList();
                        if (!context.mounted) return;
                        await toPlayer(
                          context,
                          playlist,
                          index: season.episodes.indexWhere((episode) => episode.id == item.id),
                          theme: item.themeColor,
                        );
                        setState(() {});
                      }),
                  if (item.duration != null && item.lastPlayedTime != null)
                    SizedBox(
                      width: 240,
                      child: Align(
                        alignment: const Alignment(0, 0.2),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: LinearProgressIndicator(
                            value: item.lastPlayedPosition!.inSeconds / item.duration!.inSeconds,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            minHeight: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            buildChannel(
              context,
              label: AppLocalizations.of(context)!.tagNewAdd,
              future: Api.tvSeriesQueryAll(
                  const MediaSearchQuery(sort: SortConfig(type: SortType.createAt, direction: SortDirection.desc, filter: FilterType.all), limit: 8)),
              height: 340,
              builder: (context, item) => MediaGridItem(
                  imageWidth: 160,
                  imageHeight: 160 / 0.67,
                  title: Text(item.displayRecentTitle()),
                  subtitle: Text(item.airDate?.format() ?? ''),
                  imageUrl: item.poster,
                  onTap: () => _onMediaTap(item)),
            ),
            buildChannel(
              context,
              label: AppLocalizations.of(context)!.tagNewRelease,
              future: Api.tvSeriesQueryAll(
                  const MediaSearchQuery(sort: SortConfig(type: SortType.airDate, direction: SortDirection.desc, filter: FilterType.all), limit: 8)),
              height: 340,
              builder: (context, item) => MediaGridItem(
                  imageWidth: 160,
                  imageHeight: 160 / 0.67,
                  title: Text(item.displayRecentTitle()),
                  subtitle: Text(item.airDate?.format() ?? ''),
                  imageUrl: item.poster,
                  onTap: () => _onMediaTap(item)),
            ),
            buildGridChannel(
              context,
              label: AppLocalizations.of(context)!.tagAll,
              future:
                  Api.tvSeriesQueryAll(const MediaSearchQuery(sort: SortConfig(type: SortType.title, direction: SortDirection.asc, filter: FilterType.all))),
              builder: (context, item) => MediaGridItem(
                imageWidth: 160,
                imageHeight: 160 / 0.67,
                imageUrl: item.poster,
                title: Text(item.displayTitle()),
                subtitle: Text(item.airDate?.format() ?? ''),
                onTap: () => _onMediaTap(item),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onMediaTap(TVSeries item) async {
    final flag = await navigateTo<bool>(context, TVDetail(initialData: item));
    if ((flag ?? false) && mounted) setState(() {});
  }
}
