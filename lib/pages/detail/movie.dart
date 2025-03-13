import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:video_player/player.dart';

import '../../components/async_image.dart';
import '../../components/playing_icon.dart';
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
import 'components/actors.dart';
import 'components/overview.dart';
import 'components/player_backdrop.dart';
import 'components/player_scaffold.dart';
import 'components/playlist.dart';
import 'dialogs/subtitle.dart';
import 'mixins/action.dart';
import 'mixins/searchable.dart';

class MovieDetail extends StatefulWidget {
  const MovieDetail(this.id, {super.key, this.initialData});

  final int id;
  final Movie? initialData;

  @override
  State<MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> with ActionMixin<MovieDetail>, SearchableMixin {
  final _controller = PlayerController<Movie>(Api.log);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final _autoPlay = Provider.of<UserConfig>(context, listen: false).autoPlay;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovieCubit(widget.id, widget.initialData),
      child: BlocSelector<MovieCubit, Movie?, int?>(
          selector: (movie) => movie?.themeColor,
          builder: (context, themeColor) {
            return ThemeBuilder(themeColor, builder: (context) {
              return PlayerScaffold(
                playerControls: PlayerControlsLite(
                  _controller,
                  theme: themeColor,
                  artwork: BlocSelector<MovieCubit, Movie?, (String?, String?)>(
                      selector: (movie) => (movie?.backdrop, movie?.logo), builder: (context, item) => PlayerBackdrop(backdrop: item.$1, logo: item.$2)),
                  initialized: () async {
                    if (!mounted) return;
                    final item = await Api.movieQueryById(widget.id);
                    _controller.setSources([FromMedia.fromMovie(item)], 0);
                    if (_autoPlay) _controller.play();
                  },
                  onMediaChange: (index, position, duration) {
                    final item = _controller.playlist.value[index];
                    Api.updatePlayedStatus(LibraryType.movie, item.source.id, position: position, duration: duration);
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
                                      onTap: (index) => _controller.next(index),
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
                              spacing: 16,
                              children: [
                                BlocSelector<MovieCubit, Movie?, String?>(
                                    selector: (movie) => movie?.poster,
                                    builder: (context, poster) =>
                                        poster != null ? AsyncImage(poster, width: 100, radius: BorderRadius.circular(4), viewable: true) : const SizedBox()),
                                BlocSelector<MovieCubit, Movie?, String?>(
                                  selector: (movie) => movie?.overview,
                                  builder: (context, overview) => Expanded(child: OverviewSection(text: overview, trimLines: 7)),
                                ),
                              ],
                            ),
                          ),
                          if (MediaQuery.of(context).size.aspectRatio <= 1)
                            ListenableBuilder(
                                listenable: Listenable.merge([_controller.index, _controller.playlist]),
                                builder: (context, _) => PlaylistSection(
                                      imageWidth: 120,
                                      imageHeight: 180,
                                      playlist: _controller.playlist.value,
                                      activeIndex: _controller.index.value,
                                      onTap: (it) => _controller.next(it),
                                    )),
                          BlocSelector<MovieCubit, Movie?, List<Studio>?>(
                              selector: (movie) => movie?.studios ?? [],
                              builder: (context, studios) => (studios != null && studios.isNotEmpty) ? StudiosSection(studios: studios) : const SizedBox()),
                          BlocSelector<MovieCubit, Movie?, List<Genre>?>(
                              selector: (movie) => movie?.genres ?? [],
                              builder: (context, genres) => (genres != null && genres.isNotEmpty) ? GenresSection(genres: genres) : const SizedBox()),
                          BlocSelector<MovieCubit, Movie?, List<Keyword>?>(
                              selector: (movie) => movie?.keywords ?? [],
                              builder: (context, keywords) =>
                                  (keywords != null && keywords.isNotEmpty) ? KeywordsSection(keywords: keywords) : const SizedBox()),
                          BlocSelector<MovieCubit, Movie?, List<Actor>?>(
                              selector: (movie) => movie?.actors ?? [],
                              builder: (context, actors) => (actors != null && actors.isNotEmpty) ? ActorsSection(actors: actors) : const SizedBox()),
                        ]),
                      ),
                    ],
                  ),
                ),
              );
            });
          }),
    );
  }

  Widget _buildAppbar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      primary: false,
      automaticallyImplyLeading: false,
      title: BlocBuilder<MovieCubit, Movie?>(
          builder: (context, item) => item != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitle(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.labelSmall,
                        children: [
                          TextSpan(text: item.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                          const WidgetSpan(child: SizedBox(width: 20)),
                          const WidgetSpan(child: Icon(Icons.star, color: Colors.orangeAccent, size: 14)),
                          TextSpan(text: item.voteAverage?.toStringAsFixed(1) ?? AppLocalizations.of(context)!.tagUnknown),
                          const WidgetSpan(child: SizedBox(width: 20)),
                          TextSpan(text: AppLocalizations.of(context)!.seriesStatus(item.status.name)),
                        ],
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
        child: BlocBuilder<MovieCubit, Movie?>(builder: (context, item) {
          return item == null
              ? const SizedBox()
              : PopupMenuButton(
                  itemBuilder: (context) {
                    return <PopupMenuEntry<Never>>[
                      buildWatchedAction<MovieCubit, Movie>(context, item, MediaType.movie),
                      buildFavoriteAction<MovieCubit, Movie>(context, item, MediaType.movie),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        padding: EdgeInsets.zero,
                        onTap: () => showNotification(context, Api.tvSeriesRenameById(widget.id)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          title: Text(AppLocalizations.of(context)!.buttonSaveMediaInfoToDriver),
                          leading: const Icon(Icons.save_outlined),
                        ),
                      ),
                      const PopupMenuDivider(),
                      buildRefreshInfoAction<MovieCubit, Movie>(context, () => _refreshMovie(context)),
                      const PopupMenuDivider(),
                      buildEditMetadataAction(context, () async {
                        final item = context.read<MovieCubit>().state!;
                        final res = await showDialog<(String, int?)>(context: context, builder: (context) => MovieMetadata(movie: item));
                        if (res != null) {
                          final (title, year) = res;
                          await Api.tvSeriesMetadataUpdateById(id: widget.id, title: title, airDate: year == null ? null : DateTime(year));
                          if (context.mounted) context.read<MovieCubit>().update();
                        }
                      }),
                      PopupMenuItem(
                        padding: EdgeInsets.zero,
                        onTap: () async {
                          final item = context.read<MovieCubit>().state!;
                          final subtitle =
                              await showDialog<SubtitleData>(context: context, builder: (context) => SubtitleDialog(subtitle: item.subtitles.firstOrNull));
                          if (subtitle != null && context.mounted) {
                            final resp = await showNotification(context, Api.movieSubtitleUpdateById(id: widget.id, subtitle: subtitle));
                            if (resp?.error == null && context.mounted) context.read<MovieCubit>().update();
                          }
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          title: Text(AppLocalizations.of(context)!.buttonSubtitle),
                          leading: const Icon(Icons.subtitles_outlined),
                        ),
                      ),
                      PopupMenuItem(
                        padding: EdgeInsets.zero,
                        onTap: item.downloaded
                            ? null
                            : () async {
                                final resp = await showNotification(context, Api.downloadTaskCreate(item.url.queryParameters['id']!),
                                    successText: AppLocalizations.of(context)!.tipsForDownload);
                                if (resp?.error == null && context.mounted) context.read<MovieCubit>().update();
                              },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          title: Text(AppLocalizations.of(context)!.buttonDownload),
                          leading: const Icon(Icons.download_outlined),
                        ),
                      ),
                      if (item.scrapper.id != null) buildHomeAction(context, ImdbUri(MediaType.series, item.scrapper.id!).toUri()),
                      const PopupMenuDivider(),
                      buildDeleteAction(context, () => Api.tvSeriesDeleteById(widget.id)),
                    ];
                  },
                  tooltip: '',
                );
        }),
      ),
    ];
  }

  Future<bool> _refreshMovie(BuildContext context) async {
    final item = context.read<MovieCubit>().state!;
    final done = await search(
      context,
      ({required String title, int? year, int? index}) => Api.movieUpdateById(
        item.id,
        title,
        Localizations.localeOf(context).languageCode,
        year: year.toString(),
        index: index,
      ),
      title: item.title ?? item.originalTitle ?? item.filename,
      year: item.airDate?.year,
    );
    if (done) {
      final movie = await Api.movieQueryById(item.id);
      _controller.setSources([FromMedia.fromMovie(movie)], 0);
    }
    return done;
  }
}

class _PlaylistSidebar extends StatefulWidget {
  const _PlaylistSidebar({this.activeIndex, required this.playlist, this.onTap, this.themeColor});

  final int? activeIndex;
  final List<PlaylistItem<Movie>> playlist;
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
              subtitle: Text(item.airDate == null ? '' : ' - ${item.airDate?.format()}'),
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
  }
}

class MovieCubit extends MediaCubit<Movie> {
  MovieCubit(this.id, super.initialState) {
    update();
  }

  final int id;

  @override
  Future<void> update() async {
    final movie = await Api.movieQueryById(id);
    emit(movie);
  }
}
