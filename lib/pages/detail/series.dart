import 'dart:math';

import 'package:api/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:video_player/player.dart';

import '../../components/async_image.dart';
import '../../components/playing_icon.dart';
import '../../models/models.dart';
import '../../providers/user_config.dart';
import '../../utils/utils.dart';
import '../components/image_card.dart';
import '../components/theme_builder.dart';
import '../player/player_controls_lite.dart';
import '../utils/notification.dart';
import 'components/cast.dart';
import 'components/crew.dart';
import 'components/genres.dart';
import 'components/keywords.dart';
import 'components/overview.dart';
import 'components/player_backdrop.dart';
import 'components/player_scaffold.dart';
import 'components/playlist.dart';
import 'components/seasons.dart';
import 'components/studios.dart';
import 'dialogs/scraper.dart';
import 'dialogs/series_metadata.dart';
import 'mixins/action.dart';
import 'mixins/searchable.dart';
import 'season.dart';
import 'utils/tmdb_uri.dart';

class TVDetail extends StatefulWidget {
  const TVDetail(this.id, {super.key, this.initialData, this.playingId});

  final dynamic id;
  final dynamic playingId;
  final TVSeries? initialData;

  @override
  State<TVDetail> createState() => _TVDetailState();
}

class _TVDetailState extends State<TVDetail> with ActionMixin<TVDetail>, SearchableMixin {
  late final _controller = PlayerController<TVEpisode>(
    Api.log,
    onGetPlayBackInfo: _onGetPlayBackInfo,
    onPlaybackStatusUpdate: _onPlaybackStatusUpdate,
  );
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _modalBottomSheetHistory = <BuildContext>[];
  late final _autoPlay = Provider.of<UserConfig>(context, listen: false).autoPlay;

  Future<PlaylistItem> _onGetPlayBackInfo(PlaylistItemDisplay<TVEpisode> item) async {
    final data = await Api.playbackInfo(item.fileId);
    return PlaylistItem(
      title: item.title,
      description: item.description,
      poster: item.poster,
      start: item.start,
      end: item.end,
      url: Uri.parse(data.url).normalize(),
      subtitles: data.subtitles.map((d) => d.toSubtitle()).toList(),
      others: data.others,
    );
  }

  Future<void> _onPlaybackStatusUpdate(PlaylistItem item, PlaybackStatusEvent eventType, Duration position, Duration duration) {
    return Api.updatePlayedStatus(
      LibraryType.tv,
      _controller.currentItem!.source.id,
      position: position,
      duration: duration,
      eventType: eventType.name,
      others: item.others,
    );
  }

  @override
  void initState() {
    _updatePlaylist(context);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => TVSeriesCubit(widget.id, widget.initialData),
        child: BlocSelector<TVSeriesCubit, TVSeries?, int?>(
            selector: (series) => series?.themeColor,
            builder: (context, themeColor) {
              return ThemeBuilder(themeColor, builder: (context) {
                return PlayerScaffold(
                  playerControls: PlayerControlsLite(
                    _controller,
                    theme: themeColor,
                    artwork: BlocSelector<TVSeriesCubit, TVSeries?, (String?, String?)>(
                        selector: (movie) => (movie?.backdrop, movie?.logo), builder: (context, item) => PlayerBackdrop(backdrop: item.$1, logo: item.$2)),
                    initialized: () {
                      if (_controller.index.value == null) {
                        final index = _controller.playlist.value.indexWhere((el) => el.source.id == widget.playingId);
                        _controller.next(max(index, 0));
                      }
                    },
                  ),
                  sidebar: Navigator(
                    key: _navigatorKey,
                    requestFocus: false,
                    onGenerateRoute: (settings) => MaterialPageRoute(
                        builder: (context) => Material(
                              child: ListenableBuilder(
                                  listenable: Listenable.merge([_controller.index, _controller.playlist]),
                                  builder: (context, _) => _PlaylistSidebar(
                                        themeColor: themeColor,
                                        playlist: _controller.playlist.value,
                                        activeIndex: _controller.index.value,
                                        onTap: (it) => _controller.next(it),
                                      )),
                            ),
                        settings: settings),
                  ),
                  child: Scaffold(
                    key: _scaffoldKey,
                    body: CustomScrollView(
                      slivers: [
                        _buildAppbar(context),
                        SliverSafeArea(
                          top: false,
                          sliver: SliverList.list(children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BlocSelector<TVSeriesCubit, TVSeries?, String?>(
                                      selector: (movie) => movie?.poster,
                                      builder: (context, poster) => poster != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(right: 16),
                                              child: AsyncImage(poster, width: 100, height: 150, radius: BorderRadius.circular(4), viewable: true),
                                            )
                                          : const SizedBox()),
                                  BlocSelector<TVSeriesCubit, TVSeries?, String?>(
                                    selector: (movie) => movie?.overview,
                                    builder: (context, overview) => Expanded(child: OverviewSection(text: overview, trimLines: 7)),
                                  ),
                                ],
                              ),
                            ),
                            if (MediaQuery.of(context).size.aspectRatio > 1)
                              const SizedBox()
                            else
                              ListenableBuilder(
                                  listenable: Listenable.merge([_controller.index, _controller.playlist]),
                                  builder: (context, _) => PlaylistSection(
                                        imageWidth: 160,
                                        imageHeight: 90,
                                        playlist: _controller.playlist.value,
                                        activeIndex: _controller.index.value,
                                        onTap: (it) async {
                                          await _controller.next(it);
                                          await _controller.play();
                                        },
                                      )),
                            BlocSelector<TVSeriesCubit, TVSeries?, List<Studio>?>(
                                selector: (movie) => movie?.studios ?? [],
                                builder: (context, studios) =>
                                    (studios != null && studios.isNotEmpty) ? StudiosSection(type: MediaType.series, studios: studios) : const SizedBox()),
                            BlocSelector<TVSeriesCubit, TVSeries?, List<Genre>?>(
                                selector: (movie) => movie?.genres ?? [],
                                builder: (context, genres) =>
                                    (genres != null && genres.isNotEmpty) ? GenresSection(type: MediaType.series, genres: genres) : const SizedBox()),
                            BlocSelector<TVSeriesCubit, TVSeries?, List<Keyword>?>(
                                selector: (movie) => movie?.keywords ?? [],
                                builder: (context, keywords) =>
                                    (keywords != null && keywords.isNotEmpty) ? KeywordsSection(type: MediaType.series, keywords: keywords) : const SizedBox()),
                            BlocBuilder<TVSeriesCubit, TVSeries?>(builder: (context, item) {
                              return (item != null && item.seasons.isNotEmpty)
                                  ? SeasonsSection(
                                      seasons: item.seasons,
                                      onTap: (season) async {
                                        await _showModalBottomSheet(
                                          context: context,
                                          builder: (context) => SeasonDetail(
                                            id: season.id,
                                            scrapper: item.scrapper,
                                            themeColor: season.themeColor,
                                            controller: _controller,
                                          ),
                                        );
                                        if (context.mounted) context.read<TVSeriesCubit>().update();
                                      },
                                    )
                                  : const SizedBox();
                            }),
                            BlocSelector<TVSeriesCubit, TVSeries?, List<MediaCast>?>(
                                selector: (tvSeries) => tvSeries?.mediaCast ?? [],
                                builder: (context, cast) =>
                                    (cast != null && cast.isNotEmpty) ? CastSection(type: MediaType.series, cast: cast) : const SizedBox()),
                            BlocSelector<TVSeriesCubit, TVSeries?, List<MediaCrew>?>(
                                selector: (tvSeries) => tvSeries?.mediaCrew ?? [],
                                builder: (context, crew) =>
                                    (crew != null && crew.isNotEmpty) ? CrewSection(type: MediaType.series, crew: crew) : const SizedBox()),
                          ]),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }));
  }

  Widget _buildAppbar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      primary: false,
      automaticallyImplyLeading: false,
      title: BlocBuilder<TVSeriesCubit, TVSeries?>(
          builder: (context, item) => item != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitle(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.labelSmall!,
                      overflow: TextOverflow.ellipsis,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: item.firstAirDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                            const WidgetSpan(child: SizedBox(width: 20)),
                            const WidgetSpan(child: Icon(Icons.star, color: Colors.orangeAccent, size: 14)),
                            TextSpan(text: item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown),
                            const WidgetSpan(child: SizedBox(width: 20)),
                            TextSpan(text: AppLocalizations.of(context)!.seriesStatus(item.status.name)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox()),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      ListTileTheme(
        dense: true,
        child: BlocBuilder<TVSeriesCubit, TVSeries?>(builder: (context, item) {
          return item == null
              ? const SizedBox()
              : PopupMenuButton(
                  itemBuilder: (context) => <PopupMenuEntry<Never>>[
                    buildWatchedAction<TVSeriesCubit, TVSeries>(context, item, MediaType.series),
                    buildFavoriteAction<TVSeriesCubit, TVSeries>(context, item, MediaType.series),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      padding: EdgeInsets.zero,
                      onTap: () async {
                        final res = await showNotification(context, Api.tvSeriesSyncById(item.id));
                        if (res?.error is DioException) {
                          if ((res!.error! as DioException).response?.statusCode == 404) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          }
                        } else if (context.mounted) {
                          context.read<TVSeriesCubit>().update();
                          await _updatePlaylist(context);
                        }
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(AppLocalizations.of(context)!.buttonSyncLibrary),
                        leading: const Icon(Icons.video_library_outlined),
                      ),
                    ),
                    PopupMenuItem(
                      padding: EdgeInsets.zero,
                      enabled: false,
                      onTap: () => showNotification(context, Api.tvSeriesRenameById(item.id)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(AppLocalizations.of(context)!.buttonSaveMediaInfoToDriver),
                        leading: const Icon(Icons.save_outlined),
                      ),
                    ),
                    const PopupMenuDivider(),
                    buildScraperAction<TVSeriesCubit, TVSeries>(context, () => _scraperSeries(context, item)),
                    const PopupMenuDivider(),
                    buildSkipFromStartAction<TVSeriesCubit, TVSeries>(context, item, MediaType.series, item.skipIntro),
                    buildSkipFromEndAction<TVSeriesCubit, TVSeries>(context, item, MediaType.series, item.skipEnding),
                    const PopupMenuDivider(),
                    buildEditMetadataAction(context, () async {
                      final res = await showDialog<bool>(context: context, builder: (context) => SeriesMetadata(series: item));
                      if ((res ?? false) && context.mounted) context.read<TVSeriesCubit>().update();
                    }),
                    if (item.scrapper.id != null) buildHomeAction(context, ImdbUri(MediaType.series, item.scrapper.id!).toUri()),
                    const PopupMenuDivider(),
                    buildDeleteAction(context, () => Api.tvSeriesDeleteById(item.id)),
                  ],
                  tooltip: '',
                );
        }),
      ),
    ];
  }

  Future<bool> _scraperSeries(BuildContext context, TVSeries item) async {
    final data = await showDialog<(String, String, String?)>(context: context, builder: (context) => ScraperDialog(item: item));
    if (data != null && context.mounted) {
      final resp = await showNotification(context, Api.tvSeriesScraperById(item.id, data.$1, data.$2, data.$3));
      if (resp?.error == null) {
        return true;
      }
    }
    return false;
  }

  Future<T?> _showModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    final constraints = MediaQuery.of(context).size.aspectRatio > 1
        ? null
        : BoxConstraints(maxHeight: (_scaffoldKey.currentContext!.findRenderObject()! as RenderBox).size.height);
    if (_modalBottomSheetHistory.isNotEmpty) {
      for (final ctx in _modalBottomSheetHistory) {
        if (ctx.mounted) Navigator.pop(ctx);
      }
      _modalBottomSheetHistory.clear();
    }
    return showModalBottomSheet<T>(
      context: MediaQuery.of(context).size.aspectRatio > 1 ? _navigatorKey.currentContext! : context,
      barrierColor: Colors.transparent,
      constraints: constraints,
      isScrollControlled: true,
      builder: (context) {
        _modalBottomSheetHistory.add(context);
        return builder(context);
      },
    );
  }

  Future<void> _updatePlaylist(BuildContext context) async {
    if (widget.playingId != null) {
      final episode = await Api.tvEpisodeQueryById(widget.playingId);
      final season = await Api.tvSeasonQueryById(episode.seasonId);
      final playlist = season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList();
      _controller.setPlaylist(playlist);
      await _controller.next(playlist.indexWhere((el) => el.source.id == widget.playingId));
      if (_autoPlay) _controller.play();
    } else {
      final item = await Api.tvSeriesQueryById(widget.id);
      final res = item.nextToPlay;
      if (res != null) {
        final season = await Api.tvSeasonQueryById(res.seasonId);
        final playlist = season.episodes.map((episode) => FromMedia.fromEpisode(episode)).toList();
        _controller.setPlaylist(playlist);
        await _controller.next(playlist.indexWhere((el) => el.source.id == res.id));
        if (_autoPlay) _controller.play();
      }
    }
  }
}

class _PlaylistSidebar extends StatefulWidget {
  const _PlaylistSidebar({this.activeIndex, required this.playlist, this.onTap, this.themeColor});

  final int? activeIndex;
  final List<PlaylistItemDisplay<TVEpisode>> playlist;
  final int? themeColor;

  final ValueChanged<int>? onTap;

  @override
  State<_PlaylistSidebar> createState() => _PlaylistSidebarState();
}

class _PlaylistSidebarState extends State<_PlaylistSidebar> {
  late final _controller = ScrollController();
  final imageWidth = 190.0;
  late final imageHeight = imageWidth / 1.78;

  @override
  void didUpdateWidget(covariant _PlaylistSidebar oldWidget) {
    final index = widget.activeIndex;
    if (index != oldWidget.activeIndex && index != null && index >= 0 && index < widget.playlist.length) {
      _controller.animateTo(index * (imageHeight + 12), duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(widget.themeColor, builder: (context) {
      return Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.titlePlaylist, style: Theme.of(context).textTheme.titleMedium),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            primary: false,
          ),
          primary: false,
          body: ListView.separated(
            controller: _controller,
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: widget.playlist.length,
            itemBuilder: (context, index) {
              final item = widget.playlist[index].source;
              return ImageCardWide(
                item.poster,
                width: imageWidth,
                height: imageHeight,
                title: Text(item.displayTitle()),
                subtitle: Text('S${item.season} E${item.episode}${item.airDate == null ? '' : ' - ${item.airDate?.format()}'}'),
                description: Text(item.overview ?? ''),
                floating: widget.activeIndex == index
                    ? Container(
                        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(0x66),
                        width: imageWidth,
                        height: imageHeight,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: PlayingIcon(color: Theme.of(context).colorScheme.primary),
                        ),
                      )
                    : null,
                onTap: widget.onTap == null ? null : () => widget.onTap!(index),
              );
            },
          ),
        );
      });
    });
  }
}

class TVSeriesCubit extends MediaCubit<TVSeries> {
  TVSeriesCubit(this.id, super.initialState) {
    update();
  }

  final dynamic id;

  @override
  Future<void> update() async {
    final series = await Api.tvSeriesQueryById(id);
    emit(series);
  }
}
