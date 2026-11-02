import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../cards/cards.dart';
import '../../../components/components.dart';
import '../../../menus/season.dart';
import '../../../view_models/view_models.dart';
import 'components/components.dart';
import 'titles/season.dart';

class SeasonPage extends StatelessWidget {
  const SeasonPage({super.key});

  @override
  Widget build(BuildContext rootContext) {
    return ViewModelConsumer<SeasonViewModel, TVSeason>(
      useScaffold: true,
      builder: (context, item, _) => DetailScaffold(
        onRefresh: () async => context.read<SeasonViewModel>().load(),
        imageAspectRatio: 0.8,
        themeColor: item.themeColor,
        menus: SeasonMenu(item),
        slivers: [
          const SliverSafeArea(bottom: false, sliver: SliverToBoxAdapter()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: Card(
                      child: item.poster != null
                          ? AsyncImage(item.poster!, viewable: true)
                          : Icon(
                              Icons.image_outlined,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              size: 80,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SeasonTitle(item: item),
          TopButtons(item: item, type: .season),
          OverviewSection(text: item.overview),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final double childAspectRatio =
                    constraints.crossAxisExtent / (constraints.crossAxisExtent / 616).ceil() / 101;
                return SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 600,
                    childAspectRatio: childAspectRatio,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: item.episodes.length,
                  itemBuilder: (context, index) {
                    final TVEpisode episode = item.episodes[index];
                    return EpisodeCard(item: episode, size: const Size(178, 100));
                  },
                );
              },
            ),
          ),
          CastSection(type: MediaType.season, cast: item.mediaCast),
          CrewSection(type: MediaType.season, crew: item.mediaCrew),
          const SliverSafeArea(top: false, sliver: SliverToBoxAdapter()),
        ],
      ),
    );
  }
}
