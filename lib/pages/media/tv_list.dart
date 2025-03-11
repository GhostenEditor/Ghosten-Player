import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/utils.dart';
import '../components/image_card.dart';
import '../detail/series.dart';
import '../library.dart';
import 'components/carousel.dart';
import 'components/channel.dart';
import 'components/media_scaffold.dart';

class TVListPage extends StatefulWidget {
  const TVListPage({super.key});

  @override
  State<TVListPage> createState() => _TVListPageState();
}

class _TVListPageState extends State<TVListPage> {
  final _backdrop = ValueNotifier<String?>(null);
  StreamSubscription<double?>? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription = Api.needUpdate$.listen((event) => setState(() {}));
  }

  @override
  void dispose() {
    _backdrop.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TVListCubit(null),
      child: Builder(builder: (context) {
        return RefreshIndicator(
          onRefresh: () => context.read<TVListCubit>().update(),
          child: MediaScaffold(
            backdrop: _backdrop,
            slivers: [
              MediaCarousel<TVListCubit, TVListModel?>(
                onChanged: (index) {
                  _backdrop.value = context.read<TVListCubit>().state?.carousels[index].backdrop;
                },
                noDataBuilder: (context) => FilledButton(
                  autofocus: true,
                  child: Text(AppLocalizations.of(context)!.settingsItemTV),
                  onPressed: () async {
                    Scaffold.of(context).openEndDrawer();
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (context.mounted) {
                      navigateTo(context, const LibraryManage(type: LibraryType.tv));
                    }
                  },
                ),
                selector: (state) => state?.carousels.length,
                itemBuilder: (BuildContext context, int index) => BlocSelector<TVListCubit, TVListModel?, MediaRecommendation>(
                    selector: (state) => state!.carousels[index],
                    builder: (context, item) => CarouselItem(
                          item: item,
                          onPressed: () async {
                            final series = await Api.tvSeriesQueryById(item.id);
                            if (context.mounted) await _onMediaTap(context, series);
                          },
                        )),
              ),
              MediaChannel<TVListCubit, TVListModel?>(
                label: AppLocalizations.of(context)!.watchNow,
                height: 160,
                selector: (state) => state?.watchNow.length ?? 0,
                builder: _buildRecentMediaCard,
              ),
              MediaChannel<TVListCubit, TVListModel?>(
                label: AppLocalizations.of(context)!.tagNewAdd,
                selector: (state) => state?.newAdd.length ?? 0,
                height: 230,
                builder: (context, index) => _buildMediaCard(context, (state) => state!.newAdd[index], width: 120, height: 180),
              ),
              MediaChannel<TVListCubit, TVListModel?>(
                label: AppLocalizations.of(context)!.tagNewRelease,
                selector: (state) => state?.newRelease.length ?? 0,
                height: 230,
                builder: (context, index) => _buildMediaCard(context, (state) => state!.newRelease[index], width: 120, height: 180),
              ),
              MediaGridChannel<TVListCubit, TVListModel?>(
                label: AppLocalizations.of(context)!.tagAll,
                selector: (state) => state?.all.length ?? 0,
                builder: (context, index) => _buildMediaCard(context, (state) => state!.all[index]),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRecentMediaCard(BuildContext context, int index) {
    return BlocSelector<TVListCubit, TVListModel?, TVEpisode>(
        selector: (state) => state!.watchNow[index],
        builder: (context, item) {
          return ImageCard(
            item.poster,
            width: 180,
            height: 102,
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
            floating: item.duration != null && item.lastPlayedTime != null
                ? Align(
                    alignment: const Alignment(0, 0.9),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: LinearProgressIndicator(
                        value: item.lastPlayedPosition!.inSeconds / item.duration!.inSeconds,
                        color: Theme.of(context).colorScheme.onSurface,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(3),
                        minHeight: 3,
                      ),
                    ),
                  )
                : null,
            onTap: () async {
              final series = await Api.tvSeriesQueryById(item.seriesId);
              if (context.mounted) await _onMediaTap(context, series);
            },
          );
        });
  }

  Widget _buildMediaCard(BuildContext context, BlocWidgetSelector<TVListModel?, TVSeries> selector, {double? width, double? height}) {
    return BlocSelector<TVListCubit, TVListModel?, TVSeries>(
        selector: selector,
        builder: (context, item) {
          return ImageCard(
            item.poster,
            width: width,
            height: height,
            title: Text(item.displayRecentTitle()),
            subtitle: Text(item.airDate?.format() ?? ''),
            floating: MediaBadges(item: item),
            onTap: () => _onMediaTap(context, item),
          );
        });
  }

  Future<void> _onMediaTap(BuildContext context, TVSeries item) async {
    await navigateTo(context, TVDetail(item.id, initialData: item));
    if (context.mounted) context.read<TVListCubit>().update();
  }
}

class TVListModel {
  const TVListModel({
    required this.carousels,
    required this.watchNow,
    required this.newAdd,
    required this.newRelease,
    required this.all,
  });

  final List<MediaRecommendation> carousels;
  final List<TVEpisode> watchNow;
  final List<TVSeries> newAdd;
  final List<TVSeries> newRelease;
  final List<TVSeries> all;
}

class TVListCubit extends Cubit<TVListModel?> {
  TVListCubit(super.initialState) {
    update();
  }

  Future<void> update() async {
    final items = await Future.wait([
      Api.tvRecommendation(),
      Api.tvSeriesNextToPlayQueryAll(),
      Api.tvSeriesQueryAll(const MediaSearchQuery(sort: SortConfig(type: SortType.createAt, direction: SortDirection.desc, filter: FilterType.all), limit: 8)),
      Api.tvSeriesQueryAll(const MediaSearchQuery(sort: SortConfig(type: SortType.airDate, direction: SortDirection.desc, filter: FilterType.all), limit: 8)),
      Api.tvSeriesQueryAll(const MediaSearchQuery(sort: SortConfig(type: SortType.title, direction: SortDirection.asc, filter: FilterType.all)))
    ]);
    emit(TVListModel(
      carousels: items[0] as List<MediaRecommendation>,
      watchNow: items[1] as List<TVEpisode>,
      newAdd: items[2] as List<TVSeries>,
      newRelease: items[3] as List<TVSeries>,
      all: items[4] as List<TVSeries>,
    ));
  }
}
