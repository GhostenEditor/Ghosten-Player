import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/async_image.dart';
import '../../utils/utils.dart';
import '../components/theme_builder.dart';
import '../utils/notification.dart';
import 'components/cast.dart';
import 'components/crew.dart';
import 'components/file_info.dart';
import 'components/overview.dart';
import 'dialogs/episode_metadata.dart';
import 'dialogs/subtitle.dart';
import 'mixins/action.dart';
import 'utils/tmdb_uri.dart';

class EpisodeDetail extends StatefulWidget {
  const EpisodeDetail({super.key, required this.tvEpisodeId, required this.scrapper, this.initialData});

  final dynamic tvEpisodeId;
  final Scrapper scrapper;
  final TVEpisode? initialData;

  @override
  State<EpisodeDetail> createState() => _EpisodeDetailState();
}

class _EpisodeDetailState extends State<EpisodeDetail> with ActionMixin<EpisodeDetail>, RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TVEpisodeCubit(widget.tvEpisodeId, widget.initialData),
      child: BlocSelector<TVEpisodeCubit, TVEpisode?, int?>(
          selector: (episode) => episode?.themeColor,
          builder: (context, themeColor) {
            return ThemeBuilder(themeColor, builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  title: BlocBuilder<TVEpisodeCubit, TVEpisode?>(builder: (context, item) {
                    return item != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.episode}. ${item.displayTitle()}', style: Theme.of(context).textTheme.titleMedium),
                              DefaultTextStyle(
                                style: Theme.of(context).textTheme.labelSmall!,
                                overflow: TextOverflow.ellipsis,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: item.seriesTitle),
                                      const WidgetSpan(child: SizedBox(width: 6)),
                                      TextSpan(text: AppLocalizations.of(context)!.seasonNumber(item.season)),
                                      const WidgetSpan(child: SizedBox(width: 10)),
                                      if (item.airDate != null) TextSpan(text: item.airDate?.format() ?? AppLocalizations.of(context)!.tagUnknown),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        : const SizedBox();
                  }),
                  actions: [
                    ListTileTheme(
                        dense: true,
                        child: BlocBuilder<TVEpisodeCubit, TVEpisode?>(builder: (context, item) {
                          return item != null
                              ? PopupMenuButton(
                                  offset: const Offset(double.maxFinite, 0),
                                  itemBuilder: (context) => <PopupMenuEntry<Never>>[
                                        buildWatchedAction<TVEpisodeCubit, TVEpisode>(context, item, MediaType.episode),
                                        buildFavoriteAction<TVEpisodeCubit, TVEpisode>(context, item, MediaType.episode),
                                        const PopupMenuDivider(),
                                        buildSkipFromStartAction<TVEpisodeCubit, TVEpisode>(context, item, MediaType.episode, item.skipIntro),
                                        buildSkipFromEndAction<TVEpisodeCubit, TVEpisode>(context, item, MediaType.episode, item.skipEnding),
                                        const PopupMenuDivider(),
                                        buildEditMetadataAction(context, () async {
                                          final res = await showDialog<bool>(context: context, builder: (context) => EpisodeMetadata(episode: item));
                                          if ((res ?? false) && context.mounted) context.read<TVEpisodeCubit>().update();
                                        }),
                                        PopupMenuItem(
                                          padding: EdgeInsets.zero,
                                          onTap: () async {
                                            // final subtitle = await showDialog<SubtitleData>(context: context, builder: (context) => const SubtitleDialog());
                                            // if (subtitle != null && context.mounted) {
                                            //   await showNotification(context, Api.tvEpisodeSubtitleUpdateById(id: item.id, subtitle: subtitle));
                                            // }
                                            navigateTo(context, SubtitleManager(fileId: item.fileId!));
                                          },
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                            title: Text(AppLocalizations.of(context)!.buttonSubtitle),
                                            leading: const Icon(Icons.subtitles_outlined),
                                          ),
                                        ),
                                        PopupMenuItem(
                                          padding: EdgeInsets.zero,
                                          enabled: !item.downloaded,
                                          onTap: item.downloaded
                                              ? null
                                              : () => showNotification(context, Api.downloadTaskCreate(item.fileId),
                                                  successText: AppLocalizations.of(context)!.tipsForDownload),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                            title: Text(item.downloaded
                                                ? AppLocalizations.of(context)!.downloaderLabelDownloaded
                                                : AppLocalizations.of(context)!.buttonDownload),
                                            leading: const Icon(Icons.download_outlined),
                                          ),
                                        ),
                                        if (widget.scrapper.id != null)
                                          buildHomeAction(
                                              context, ImdbUri(MediaType.episode, widget.scrapper.id!, season: item.season, episode: item.episode).toUri()),
                                        const PopupMenuDivider(),
                                        buildDeleteAction(context, () => Api.tvEpisodeDeleteById(item.id)),
                                      ])
                              : const IconButton(onPressed: null, icon: Icon(null));
                        })),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                body: CustomScrollView(
                  slivers: [
                    SliverSafeArea(
                      sliver: SliverList.list(children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocSelector<TVEpisodeCubit, TVEpisode?, String?>(
                                  selector: (movie) => movie?.poster,
                                  builder: (context, poster) => poster != null
                                      ? Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: AsyncImage(poster, width: 160, radius: BorderRadius.circular(4), viewable: true),
                                        )
                                      : const SizedBox()),
                              BlocBuilder<TVEpisodeCubit, TVEpisode?>(builder: (context, item) {
                                return item != null
                                    ? Expanded(
                                        child: OverviewSection(text: item.overview, trimLines: 6),
                                      )
                                    : const SizedBox();
                              }),
                            ],
                          ),
                        ),
                        BlocSelector<TVEpisodeCubit, TVEpisode?, List<MediaCast>?>(
                            selector: (episode) => episode?.mediaCast ?? [],
                            builder: (context, cast) =>
                                (cast != null && cast.isNotEmpty) ? CastSection(type: MediaType.episode, cast: cast) : const SizedBox()),
                        BlocSelector<TVEpisodeCubit, TVEpisode?, List<MediaCast>?>(
                            selector: (episode) => episode?.guestStars ?? [],
                            builder: (context, cast) =>
                                (cast != null && cast.isNotEmpty) ? CastSection(type: MediaType.episode, cast: cast) : const SizedBox()),
                        BlocSelector<TVEpisodeCubit, TVEpisode?, List<MediaCrew>?>(
                            selector: (episode) => episode?.mediaCrew ?? [],
                            builder: (context, crew) =>
                                (crew != null && crew.isNotEmpty) ? CrewSection(type: MediaType.episode, crew: crew) : const SizedBox()),
                        BlocSelector<TVEpisodeCubit, TVEpisode?, String?>(
                            selector: (episode) => episode?.fileId,
                            builder: (context, fileId) {
                              return fileId != null ? FileInfoSection(fileId: fileId) : const SizedBox();
                            }),
                      ]),
                    ),
                  ],
                ),
              );
            });
          }),
    );
  }
}

class TVEpisodeCubit extends MediaCubit<TVEpisode> {
  TVEpisodeCubit(this.id, super.initialState) {
    update();
  }

  final dynamic id;

  @override
  Future<void> update() async {
    final episode = await Api.tvEpisodeQueryById(id);
    emit(episode);
  }
}
