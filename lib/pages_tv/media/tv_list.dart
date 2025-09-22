import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../components/no_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../components/filled_button.dart';
import '../components/future_builder_handler.dart';
import '../detail/series.dart';
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

class _TVListPageState extends State<TVListPage> {
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
          child: ListenableBuilder(
            listenable: _backdrop,
            builder: (context, _) => CarouselBackground(src: _backdrop.value),
          ),
        ),
        AspectRatio(
          aspectRatio: 2,
          child: ListenableBuilder(
            listenable: _showBlur,
            builder:
                (context, _) => AnimatedOpacity(
                  opacity: _showBlur.value ? 0.54 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: Container(width: 200, height: 200, color: Theme.of(context).scaffoldBackgroundColor),
                ),
          ),
        ),
        CustomScrollView(
          controller: _controller,
          slivers: [
            FutureBuilderSliverHandler(
              future: Api.tvRecommendation(),
              loadingBuilder: (context, _) => const AspectRatio(aspectRatio: 32 / 15, child: CarouselPlaceholder()),
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
                    child:
                        snapshot.requireData.isNotEmpty
                            ? ListenableBuilder(
                              listenable: _carouselIndex,
                              builder: (context, _) {
                                final item =
                                    snapshot.requireData.elementAtOrNull(_carouselIndex.value ?? 0) ??
                                    snapshot.requireData.first;
                                return Carousel(
                                  key: ValueKey(snapshot.requireData.length),
                                  index: _carouselIndex.value ?? 0,
                                  len: snapshot.requireData.length,
                                  onFocusChange: (f) {
                                    if (f) {
                                      _controller.animateTo(
                                        0,
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeOut,
                                      );
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
                                      if (!context.mounted) return;
                                      await toPlayer(
                                        context,
                                        Future.microtask(() async {
                                          final series = await Api.tvSeriesQueryById(item.id);
                                          final season = await Api.tvSeasonQueryById(series.nextToPlay!.seasonId);
                                          final playlist =
                                              season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList();
                                          return (
                                            playlist,
                                            season.episodes.indexWhere(
                                              (episode) => episode.id == series.nextToPlay!.id,
                                            ),
                                          );
                                        }),
                                        theme: item.themeColor,
                                      );
                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                            )
                            : Center(
                              child: NoData(
                                action: TVFilledButton(
                                  autofocus: true,
                                  child: Text(AppLocalizations.of(context)!.settingsItemTV),
                                  onPressed: () async {
                                    Scaffold.of(context).openEndDrawer();
                                    await Future.delayed(const Duration(milliseconds: 100));
                                    if (context.mounted) {
                                      navigateToSlideLeft(
                                        widget.endDrawerNavigatorKey.currentContext!,
                                        LibraryManage(
                                          title: AppLocalizations.of(context)!.settingsItemTV,
                                          type: LibraryType.tv,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                  ),
                );
              },
            ),
            MediaChannel(
              label: AppLocalizations.of(context)!.watchNow,
              future: Api.tvSeriesNextToPlayQueryAll(),
              height: 240,
              builder: (context, item) => _buildRecentMediaItem(context, item, width: 240, height: 240 / 1.78),
              loadingBuilder:
                  (context) => MediaGridItem(
                    imageWidth: 240,
                    imageHeight: 240 / 1.78,
                    title: Container(
                      width: 100,
                      height: 18,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                        Container(
                          width: 20,
                          height: 12,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
            ),
            MediaChannel(
              label: AppLocalizations.of(context)!.tagFavorite,
              future: Api.tvSeriesQueryAll(
                const MediaSearchQuery(
                  sort: SortConfig(type: SortType.createAt, direction: SortDirection.desc, filter: FilterType.favorite),
                  limit: 8,
                ),
              ).then((data) => data.data),
              height: 340,
              builder: (context, item) => _buildMediaItem(context, item, width: 160, height: 160 / 0.67),
            ),
            MediaChannel(
              label: AppLocalizations.of(context)!.tagNewAdd,
              future: Api.tvSeriesQueryAll(
                const MediaSearchQuery(
                  sort: SortConfig(type: SortType.createAt, direction: SortDirection.desc),
                  limit: 8,
                ),
              ).then((data) => data.data),
              height: 340,
              builder: (context, item) => _buildMediaItem(context, item, width: 160, height: 160 / 0.67),
            ),
            MediaChannel(
              label: AppLocalizations.of(context)!.tagNewRelease,
              future: Api.tvSeriesQueryAll(
                const MediaSearchQuery(
                  sort: SortConfig(type: SortType.airDate, direction: SortDirection.desc),
                  limit: 8,
                ),
              ).then((data) => data.data),
              height: 340,
              builder: (context, item) => _buildMediaItem(context, item, width: 160, height: 160 / 0.67),
            ),
            MediaGridChannel(
              label: AppLocalizations.of(context)!.tagAll,
              onQuery:
                  (index) => Api.tvSeriesQueryAll(
                    MediaSearchQuery(
                      limit: 30,
                      offset: 30 * index,
                      sort: const SortConfig(type: SortType.title, direction: SortDirection.asc),
                    ),
                  ),
              itemBuilder: (context, item, index) => _buildMediaItem(context, item, width: 160, height: 160 / 0.67),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentMediaItem(BuildContext context, TVEpisode item, {double? width, double? height}) {
    return MediaGridItem(
      imageWidth: width,
      imageHeight: height,
      title: Text(item.displayRecentTitle()),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (item.lastPlayedTime != null)
            Text(
              AppLocalizations.of(context)!.timeAgo(item.lastPlayedTime!.fromNow().fromNowFormat(context)),
              style: Theme.of(context).textTheme.labelSmall,
            )
          else
            const Spacer(),
          if (item.duration != null && item.lastPlayedTime != null)
            Text('${(item.lastPlayedPosition!.inSeconds / item.duration!.inSeconds * 100).toStringAsFixed(1)}%'),
        ],
      ),
      imageUrl: item.poster,
      floating:
          item.duration != null && item.duration != Duration.zero && item.lastPlayedTime != null
              ? SizedBox(
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
              )
              : null,
      onTap: () async {
        await toPlayer(
          context,
          Future.microtask(() async {
            final season = await Api.tvSeasonQueryById(item.seasonId);
            final playlist = season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList();
            return (playlist, season.episodes.indexWhere((episode) => episode.id == item.id));
          }),
          theme: item.themeColor,
        );
        setState(() {});
      },
    );
  }

  Widget _buildMediaItem(BuildContext context, TVSeries item, {double? width, double? height}) {
    return MediaGridItem(
      imageWidth: width,
      imageHeight: height,
      imageUrl: item.poster,
      title: Text(item.displayTitle()),
      subtitle: Text(item.firstAirDate?.format() ?? ''),
      onTap: () => _onMediaTap(item),
    );
  }

  Future<void> _onMediaTap(TVSeries item) async {
    final flag = await navigateTo<bool>(context, TVDetail(initialData: item));
    if ((flag ?? false) && mounted) setState(() {});
  }
}
