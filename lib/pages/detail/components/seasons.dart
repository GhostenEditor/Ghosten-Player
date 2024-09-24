import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/image_card.dart';
import '../../../components/scrollbar.dart';

class SeasonsSection extends StatelessWidget {
  final List<TVSeason> seasons;
  final void Function(TVSeason) onTap;

  const SeasonsSection({super.key, required this.seasons, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(AppLocalizations.of(context)!.titleSeasons, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 300,
          child: ScrollbarListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            itemCount: seasons.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              final item = seasons[index];
              return ImageCard(
                scale: 1.05,
                width: 170,
                image: item.poster,
                onTap: () => onTap(item),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(text: item.title ?? AppLocalizations.of(context)!.seasonNumber(item.season), style: Theme.of(context).textTheme.titleSmall),
                    if (item.episodeCount != null)
                      TextSpan(text: ' / ${AppLocalizations.of(context)!.episodeCount(item.episodeCount!)}', style: Theme.of(context).textTheme.labelMedium),
                  ]),
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
