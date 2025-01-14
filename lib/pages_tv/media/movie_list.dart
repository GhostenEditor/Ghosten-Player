import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/no_data.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../components/filled_button.dart';
import '../components/future_builder_handler.dart';
import '../detail/movie.dart';
import '../media/components/carousel.dart';
import '../mixins/update.dart';
import '../settings/settings_library.dart';
import '../utils/player.dart';
import '../utils/utils.dart';
import 'components/media_grid_item.dart';
import 'mixins/channel.dart';

class MovieListPage extends StatefulWidget {
  final GlobalKey<NavigatorState> endDrawerNavigatorKey;

  const MovieListPage({super.key, required this.endDrawerNavigatorKey});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> with NeedUpdateMixin, ChannelMixin {
  final backdrop = ValueNotifier<String?>(null);
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
    backdrop.dispose();
    _carouselIndex.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: 2,
          child: ListenableBuilder(listenable: backdrop, builder: (context, _) => CarouselBackground(src: backdrop.value)),
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
                      color: Colors.black,
                    ),
                  )),
        ),
        CustomScrollView(
          controller: _controller,
          slivers: [
            FutureBuilderSliverHandler(
                future: Api.movieRecommendation(),
                builder: (context, snapshot) {
                  Future.microtask(() {
                    if (snapshot.requireData.isNotEmpty) {
                      backdrop.value = snapshot.requireData[0].backdrop;
                    } else {
                      backdrop.value = null;
                    }
                  });
                  return SliverToBoxAdapter(
                    child: AspectRatio(
                      aspectRatio: 32 / 15,
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
                                    backdrop.value = snapshot.requireData[index].backdrop;
                                    _carouselIndex.value = index;
                                  },
                                  child: CarouselItem(
                                    key: ValueKey(item.id),
                                    item: item,
                                    onPressed: () async {
                                      final movie = await Api.movieQueryById(item.id);
                                      if (!context.mounted) return;
                                      await toPlayer(
                                        context,
                                        [FromMedia.fromMovie(movie)],
                                        theme: item.themeColor,
                                        playerType: PlayerType.movie,
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
                                child: Text(AppLocalizations.of(context)!.settingsItemMovie),
                                onPressed: () async {
                                  Scaffold.of(context).openEndDrawer();
                                  await Future.delayed(const Duration(milliseconds: 100));
                                  if (context.mounted) {
                                    navigateToSlideLeft(widget.endDrawerNavigatorKey.currentContext!,
                                        LibraryManage(title: AppLocalizations.of(context)!.settingsItemMovie, type: LibraryType.movie));
                                  }
                                },
                              ),
                            )),
                    ),
                  );
                }),
            buildChannel(
              context,
              label: AppLocalizations.of(context)!.recentWatched,
              future: Api.movieNextToPlayQueryAll(),
              height: 340,
              builder: (context, item) => Stack(
                children: [
                  MediaGridItem(
                    imageWidth: 160,
                    imageHeight: 160 / 0.67,
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
                      final movie = await Api.movieQueryById(item.id);
                      if (!context.mounted) return;
                      await toPlayer(
                        context,
                        [FromMedia.fromMovie(movie)],
                        id: item.id,
                        theme: item.themeColor,
                        playerType: PlayerType.movie,
                      );
                      setState(() {});
                    },
                  ),
                  if (item.duration != null && item.lastPlayedTime != null)
                    SizedBox(
                      width: 160,
                      child: Align(
                        alignment: const Alignment(0, 0.48),
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
              future: Api.movieQueryAll(
                  const MediaSearchQuery(sort: SortConfig(type: SortType.createAt, direction: SortDirection.desc, filter: FilterType.all), limit: 8)),
              height: 340,
              builder: (context, item) => MediaGridItem(
                imageWidth: 160,
                imageHeight: 160 / 0.67,
                title: Text(item.displayTitle()),
                subtitle: Text(item.airDate?.format() ?? ''),
                imageUrl: item.poster,
                onTap: () => onMediaTap(item),
              ),
            ),
            buildChannel(
              context,
              label: AppLocalizations.of(context)!.tagNewRelease,
              future: Api.movieQueryAll(
                  const MediaSearchQuery(sort: SortConfig(type: SortType.airDate, direction: SortDirection.desc, filter: FilterType.all), limit: 8)),
              height: 340,
              builder: (context, item) => MediaGridItem(
                imageWidth: 160,
                imageHeight: 160 / 0.67,
                title: Text(item.displayTitle()),
                subtitle: Text(item.airDate?.format() ?? ''),
                imageUrl: item.poster,
                onTap: () => onMediaTap(item),
              ),
            ),
            buildGridChannel(
              context,
              label: AppLocalizations.of(context)!.tagAll,
              future: Api.movieQueryAll(const MediaSearchQuery(sort: SortConfig(type: SortType.title, direction: SortDirection.asc, filter: FilterType.all))),
              builder: (context, item) => MediaGridItem(
                imageWidth: 160,
                imageHeight: 160 / 0.67,
                imageUrl: item.poster,
                title: Text(item.displayTitle()),
                subtitle: Text(item.airDate?.format() ?? ''),
                onTap: () => onMediaTap(item),
              ),
            ),
          ],
        ),
      ],
    );
  }

  onMediaTap(Movie item) async {
    final flag = await navigateTo<bool>(context, MovieDetail(initialData: item));
    if (flag == true && mounted) {
      setState(() {});
    }
  }
}
