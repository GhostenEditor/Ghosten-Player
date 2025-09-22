import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../components/image_card.dart';

class SeasonsSection extends StatelessWidget {
  const SeasonsSection({super.key, required this.seasons, required this.onTap});

  final List<TVSeason> seasons;
  final void Function(TVSeason) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppLocalizations.of(context)!.titleSeasons, style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 230,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: seasons.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              final item = seasons[index];
              return ImageCard(
                item.poster,
                width: 120,
                height: 180,
                onTap: () => onTap(item),
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: item.title ?? AppLocalizations.of(context)!.seasonNumber(item.season),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (item.episodeCount != null)
                        TextSpan(
                          text: ' / ${AppLocalizations.of(context)!.episodeCount(item.episodeCount!)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
