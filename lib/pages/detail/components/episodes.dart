import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/scrollbar.dart';
import '../../../utils/utils.dart';
import 'episode_card.dart';

class EpisodesSection extends StatelessWidget {
  final int season;
  final List<TVEpisode> episodes;
  final void Function(TVEpisode)? onTap;

  const EpisodesSection({super.key, required this.episodes, required this.season, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text('${AppLocalizations.of(context)!.titleMoreFrom} ${AppLocalizations.of(context)!.seasonNumber(season)}',
              style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 250,
          child: ScrollbarListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                return SizedBox(
                  width: 286,
                  child: EpisodeCard(
                    image: episode.poster,
                    text: '${episode.episode}.  ${episode.title}',
                    subText: episode.airDate?.format(),
                    onTap: onTap == null ? null : () => onTap!(episode),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
