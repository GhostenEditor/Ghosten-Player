import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:video_player/player.dart';

import '../../components/async_image.dart';
import '../../components/error_message.dart';
import '../../components/placeholder.dart';
import '../../components/playing_icon.dart';
import '../../l10n/app_localizations.dart';
import '../../models/models.dart';
import '../../pages/detail/components/genres.dart';
import '../../pages/detail/components/keywords.dart';
import '../../pages/detail/components/studios.dart';
import '../../pages/detail/dialogs/movie_metadata.dart';
import '../../pages/detail/utils/tmdb_uri.dart';
import '../../providers/user_config.dart';
import '../../utils/utils.dart';
import '../components/image_card.dart';
import '../components/theme_builder.dart';
import '../player/player_controls_lite.dart';
import '../utils/notification.dart';
import 'components/cast.dart';
import 'components/crew.dart';
import 'components/file_info.dart';
import 'components/overview.dart';
import 'components/player_backdrop.dart';
import 'components/player_scaffold.dart';
import 'components/playlist.dart';
import 'dialogs/scraper.dart';
import 'dialogs/subtitle.dart';
import 'mixins/action.dart';
import 'placeholders/movie.dart';

class MovieDetail extends StatefulWidget {
  const MovieDetail(this.id, {super.key, this.initialData});

  final dynamic id;
  final Movie? initialData;

  @override
  State<MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> with ActionMixin<MovieDetail> {
  late final _controller = PlayerController<Movie>(
    Api.log,
    onGetPlayBackInfo: _onGetPlayBackInfo,
    onPlaybackStatusUpdate: _onPlaybackStatusUpdate,
  );
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final _autoPlay = Provider.of<UserConfig>(context, listen: false).autoPlay;

  Future<PlaylistItem> _onGetPlayBackInfo(PlaylistItemDisplay<Movie> item) async {
    final data = await Api.playbackInfo(item.fileId);
    return PlaylistItem(
      title: item.title,
      description: item.description,
      poster: item.poster,
      start: item.start,
      end: item.end,
      url: Uri.parse(data.url).normalize(),
      subtitles: data.subtitles.map((d) => d.toSubtitle()).nonNulls.toList(),
      others: data.others,
    );
  }

  Future<void> _onPlaybackStatusUpdate(
    PlaylistItem item,
    PlaybackStatusEvent eventType,
    Duration position,
    Duration duration,
  ) {
    return Api.updatePlayedStatus(
      LibraryType.movie,
      _controller.currentItem!.source.id,
      position: position,
      duration: duration,
      eventType: eventType.name,
      others: item.others,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => MovieCubit(
            widget.id,
            widget.initialData != null
                ? AsyncSnapshot.withData(ConnectionState.waiting, widget.initialData!)
                : const AsyncSnapshot.waiting(),
          ),
      child: BlocBuilder<MovieCubit, AsyncSnapshot<Movie>?>(
        builder: (context, item) {
          if (item?.connectionState == ConnectionState.done && (item?.hasData ?? false)) {
            return BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, int?>(
              selector: (movie) => movie?.data?.themeColor,
              builder: (context, themeColor) {
                return ThemeBuilder(
                  themeColor,
                  builder: (context) {
                    return PlayerScaffold(
                      playerControls: PlayerControlsLite(
                        _controller,
                        theme: themeColor,
                        artwork: BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, (String?, String?)>(
                          selector: (movie) => (movie?.data?.backdrop, movie?.data?.logo),
                          builder: (context, item) => PlayerBackdrop(backdrop: item.$1, logo: item.$2),
                        ),
                        initialized: () async {
                          if (!mounted) return;
                          final item = await Api.movieQueryById(widget.id);
                          _controller.setPlaylist([FromMedia.fromMovie(item)]);
                          await _controller.next(0);
                          if (_autoPlay) await _controller.play();
                        },
                      ),
                      sidebar: Navigator(
                        key: _navigatorKey,
                        requestFocus: false,
                        onGenerateRoute:
                            (settings) => MaterialPageRoute(
                              builder:
                                  (context) => Material(
                                    child: ListenableBuilder(
                                      listenable: Listenable.merge([
                                        _controller.index,
                                        _controller.playlist,
                                        _controller.playlistError,
                                      ]),
                                      builder:
                                          (context, _) =>
                                              _controller.playlistError.value == null
                                                  ? _PlaylistSidebar(
                                                    themeColor: themeColor,
                                                    playlist: _controller.playlist.value,
                                                    activeIndex: _controller.index.value,
                                                    onTap: (index) => _controller.next(index),
                                                  )
                                                  : ErrorMessage(error: _controller.playlistError.value),
                                    ),
                                  ),
                              settings: settings,
                            ),
                      ),
                      child: Scaffold(
                        key: _scaffoldKey,
                        body: CustomScrollView(
                          slivers: [
                            _buildAppbar(context),
                            SliverSafeArea(
                              top: false,
                              sliver: SliverList.list(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, String?>(
                                          selector: (movie) => movie?.data?.poster,
                                          builder:
                                              (context, poster) =>
                                                  poster != null
                                                      ? Padding(
                                                        padding: const EdgeInsets.only(right: 16),
                                                        child: AsyncImage(
                                                          poster,
                                                          width: 100,
                                                          height: 150,
                                                          radius: BorderRadius.circular(4),
                                                          viewable: true,
                                                        ),
                                                      )
                                                      : const SizedBox(),
                                        ),
                                        BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, String?>(
                                          selector: (movie) => movie?.data?.overview,
                                          builder:
                                              (context, overview) =>
                                                  Expanded(child: OverviewSection(text: overview, trimLines: 7)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (MediaQuery.of(context).size.aspectRatio <= 1)
                                    ListenableBuilder(
                                      listenable: Listenable.merge([_controller.index, _controller.playlist]),
                                      builder:
                                          (context, _) => PlaylistSection(
                                            imageWidth: 120,
                                            imageHeight: 180,
                                            placeholderCount: 1,
                                            playlist: _controller.playlist.value,
                                            activeIndex: _controller.index.value,
                                            onTap: (it) => _controller.next(it),
                                          ),
                                    ),
                                  BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, List<Studio>?>(
                                    selector: (movie) => movie?.data?.studios ?? [],
                                    builder:
                                        (context, studios) =>
                                            (studios != null && studios.isNotEmpty)
                                                ? StudiosSection(type: MediaType.movie, studios: studios)
                                                : const SizedBox(),
                                  ),
                                  BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, List<Genre>?>(
                                    selector: (movie) => movie?.data?.genres ?? [],
                                    builder:
                                        (context, genres) =>
                                            (genres != null && genres.isNotEmpty)
                                                ? GenresSection(type: MediaType.movie, genres: genres)
                                                : const SizedBox(),
                                  ),
                                  BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, List<Keyword>?>(
                                    selector: (movie) => movie?.data?.keywords ?? [],
                                    builder:
                                        (context, keywords) =>
                                            (keywords != null && keywords.isNotEmpty)
                                                ? KeywordsSection(type: MediaType.movie, keywords: keywords)
                                                : const SizedBox(),
                                  ),
                                  BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, List<MediaCast>?>(
                                    selector: (movie) => movie?.data?.mediaCast ?? [],
                                    builder:
                                        (context, cast) =>
                                            (cast != null && cast.isNotEmpty)
                                                ? CastSection(type: MediaType.movie, cast: cast)
                                                : const SizedBox(),
                                  ),
                                  BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, List<MediaCrew>?>(
                                    selector: (movie) => movie?.data?.mediaCrew ?? [],
                                    builder:
                                        (context, crew) =>
                                            (crew != null && crew.isNotEmpty)
                                                ? CrewSection(type: MediaType.movie, crew: crew)
                                                : const SizedBox(),
                                  ),
                                  BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, String?>(
                                    selector: (movie) => movie?.data?.fileId,
                                    builder: (context, fileId) {
                                      return fileId != null ? FileInfoSection(fileId: fileId) : const SizedBox();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else if (item?.connectionState == ConnectionState.waiting) {
            return MoviePlaceholder(item: item?.data);
          } else {
            return ErrorMessage(error: item?.error);
          }
        },
      ),
    );
  }

  Widget _buildAppbar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      primary: false,
      automaticallyImplyLeading: false,
      title: BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, Movie>(
        selector: (state) => state!.requireData,
        builder:
            (context, item) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.displayTitle(), style: Theme.of(context).textTheme.titleMedium),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.labelSmall,
                    children: [
                      TextSpan(text: item.releaseDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                      const WidgetSpan(child: SizedBox(width: 20)),
                      const WidgetSpan(child: Icon(Icons.star, color: Colors.orangeAccent, size: 14)),
                      TextSpan(text: item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown),
                      const WidgetSpan(child: SizedBox(width: 20)),
                      TextSpan(text: AppLocalizations.of(context)!.seriesStatus(item.status.name)),
                    ],
                  ),
                ),
              ],
            ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      ListTileTheme(
        dense: true,
        child: BlocSelector<MovieCubit, AsyncSnapshot<Movie>?, Movie>(
          selector: (state) => state!.requireData,
          builder: (context, item) {
            return PopupMenuButton(
              itemBuilder: (context) {
                return <PopupMenuEntry<Never>>[
                  buildWatchedAction<MovieCubit, Movie>(context, item, MediaType.movie),
                  buildFavoriteAction<MovieCubit, Movie>(context, item, MediaType.movie),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    padding: EdgeInsets.zero,
                    enabled: false,
                    onTap: () => showNotification(context, Api.movieRenameById(widget.id)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(AppLocalizations.of(context)!.buttonSaveMediaInfoToDriver),
                      leading: const Icon(Icons.save_outlined),
                    ),
                  ),
                  const PopupMenuDivider(),
                  buildScraperAction<MovieCubit, Movie>(context, () => _refreshMovie(context, item)),
                  const PopupMenuDivider(),
                  buildEditMetadataAction(context, () async {
                    final res = await showDialog<bool>(
                      context: context,
                      builder: (context) => MovieMetadata(movie: item),
                    );
                    if ((res ?? false) && context.mounted) context.read<MovieCubit>().update();
                  }),
                  PopupMenuItem(
                    padding: EdgeInsets.zero,
                    onTap: () => navigateTo(context, SubtitleManager(fileId: item.fileId!)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(AppLocalizations.of(context)!.buttonSubtitle),
                      leading: const Icon(Icons.subtitles_outlined),
                    ),
                  ),
                  PopupMenuItem(
                    padding: EdgeInsets.zero,
                    enabled: !item.downloaded,
                    onTap:
                        item.downloaded
                            ? null
                            : () async {
                              final resp = await showNotification(
                                context,
                                Api.downloadTaskCreate(item.fileId),
                                successText: AppLocalizations.of(context)!.tipsForDownload,
                              );
                              if (resp?.error == null && context.mounted) context.read<MovieCubit>().update();
                            },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        item.downloaded
                            ? AppLocalizations.of(context)!.downloaderLabelDownloaded
                            : AppLocalizations.of(context)!.buttonDownload,
                      ),
                      leading: const Icon(Icons.download_outlined),
                    ),
                  ),
                  if (item.scrapper.id != null)
                    buildHomeAction(context, ImdbUri(MediaType.series, item.scrapper.id!).toUri()),
                  const PopupMenuDivider(),
                  buildDeleteAction(context, () => Api.movieDeleteById(widget.id)),
                ];
              },
              tooltip: '',
            );
          },
        ),
      ),
    ];
  }

  Future<bool> _refreshMovie(BuildContext context, Movie item) async {
    final data = await showDialog<(String, String, String?)>(
      context: context,
      builder: (context) => ScraperDialog(item: item),
    );
    if (data != null && context.mounted) {
      final resp = await showNotification(context, Api.movieScraperById(item.id, data.$1, data.$2, data.$3));
      if (resp?.error == null) {
        final movie = await Api.movieQueryById(item.id);
        _controller.setPlaylist([FromMedia.fromMovie(movie)]);
        return true;
      }
    }
    return false;
  }
}

class _PlaylistSidebar extends StatefulWidget {
  const _PlaylistSidebar({this.activeIndex, required this.playlist, this.onTap, this.themeColor});

  final int? activeIndex;
  final List<PlaylistItemDisplay<Movie>> playlist;
  final int? themeColor;

  final ValueChanged<int>? onTap;

  @override
  State<_PlaylistSidebar> createState() => _PlaylistSidebarState();
}

class _PlaylistSidebarState extends State<_PlaylistSidebar> {
  late final _controller = ScrollController();
  final imageWidth = 71.0;
  late final imageHeight = 107.0;

  @override
  void didUpdateWidget(covariant _PlaylistSidebar oldWidget) {
    final index = widget.activeIndex;
    if (index != oldWidget.activeIndex && index != null && index >= 0 && index < widget.playlist.length) {
      _controller.animateTo(
        index * (imageHeight + 12),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titlePlaylist, style: Theme.of(context).textTheme.titleMedium),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        primary: false,
      ),
      primary: false,
      body:
          widget.playlist.isNotEmpty
              ? ListView.separated(
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
                    subtitle: Text(item.airDate == null ? '' : ' - ${item.airDate?.format()}'),
                    description: Text(item.overview ?? ''),
                    floating:
                        widget.activeIndex == index
                            ? Material(
                              shape: RoundedRectangleBorder(
                                side:
                                    widget.activeIndex == index
                                        ? BorderSide(
                                          width: 6,
                                          color: Theme.of(context).colorScheme.primary,
                                          strokeAlign: BorderSide.strokeAlignCenter,
                                        )
                                        : BorderSide.none,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              color: Theme.of(context).scaffoldBackgroundColor.withAlpha(0x66),
                              child: SizedBox(
                                width: imageWidth,
                                height: imageHeight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    PlayingIcon(color: Theme.of(context).colorScheme.primary),
                                    if (item.duration != null)
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Badge(
                                          label: Text(item.duration!.toDisplay()),
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                            : item.duration != null
                            ? SizedBox(
                              width: imageWidth,
                              height: imageHeight,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Badge(
                                    label: Text(item.duration!.toDisplay()),
                                    backgroundColor:
                                        widget.activeIndex == index
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            )
                            : null,
                    onTap: widget.onTap == null ? null : () => widget.onTap!(index),
                  );
                },
              )
              : GPlaceholder(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return const ImageCardWidePlaceholder(width: 71, height: 107);
                  },
                ),
              ),
    );
  }
}

class MovieCubit extends MediaCubit<AsyncSnapshot<Movie>> {
  MovieCubit(this.id, super.initialState) {
    update();
  }

  final dynamic id;

  @override
  Future<void> update() async {
    try {
      final movie = await Api.movieQueryById(id);
      emit(AsyncSnapshot.withData(ConnectionState.done, movie));
    } catch (e) {
      emit(AsyncSnapshot.withError(ConnectionState.done, e));
    }
  }
}
