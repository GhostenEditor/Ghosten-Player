import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../menus/series.dart';
import '../../../previews/previews.dart';
import '../../../view_models/view_models.dart';
import 'components/components.dart';
import 'titles/series.dart';

class SeriesPage extends StatelessWidget {
  const SeriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer<SeriesViewModel, TVSeries>(
      useScaffold: true,
      builder: (context, item, _) => FilledButtonTheme(
        data: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            textStyle: Theme.of(context).textTheme.labelSmall,
            tapTargetSize: .shrinkWrap,
          ),
        ),
        child: DetailScaffold(
          onRefresh: () async => context.read<SeriesViewModel>().load(),
          themeColor: item.themeColor,
          image: item.backdrop != null ? AsyncImage(item.backdrop!) : null,
          menus: SeriesMenu(item),
          slivers: [
            LogoSection(logo: item.logo),
            TopButtons(item: item, type: .series),
            SeriesTitle(item: item),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            OverviewSection(text: item.overview, poster: item.poster, trimLines: 8),
            NextToPlaySection(item: item.nextToPlay),
            StudiosSection(type: MediaType.series, studios: item.studios),
            GenresSection(type: MediaType.series, genres: item.genres),
            KeywordsSection(type: MediaType.series, keywords: item.keywords),
            SeasonsSection(seasons: item.seasons),
            CastSection(type: MediaType.series, cast: item.mediaCast),
            CrewSection(type: MediaType.series, crew: item.mediaCrew),
            const SliverSafeArea(top: false, sliver: SliverToBoxAdapter()),
          ],
        ),
      ),
    );
  }
}

@AppPreview(group: 'Series Page (Mobile)', name: 'Normal', size: Size(400, 800))
Widget seriesPagePreview() {
  return const SeriesPage();
}
