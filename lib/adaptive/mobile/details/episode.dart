import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../menus/episode.dart';
import '../../../view_models/view_models.dart';
import 'components/components.dart';
import 'titles/episode.dart';

class EpisodePage extends StatelessWidget {
  const EpisodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer<EpisodeViewModel, TVEpisode>(
      builder: (context, item, _) => DetailScaffold(
        onRefresh: () async => context.read<EpisodeViewModel>(),
        themeColor: item.themeColor,
        imageAspectRatio: 16 / 10,
        menus: EpisodeMenu(item),
        slivers: [
          SliverSafeArea(
            sliver: SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
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
          ),
          EpisodeTitle(item: item),
          TopButtons(item: item, type: .episode),
          OverviewSection(text: item.overview),
          CastSection(type: MediaType.movie, cast: item.mediaCast),
          CastSection(type: MediaType.movie, cast: item.guestStars),
          CrewSection(type: MediaType.movie, crew: item.mediaCrew),
          if (item.fileId != null) FileInfoSection(fileId: item.fileId!),
        ],
      ),
    );
  }
}
