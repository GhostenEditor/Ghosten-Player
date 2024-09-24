import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/utils.dart';
import 'episode_card.dart';

class NextToPlaySection extends StatelessWidget {
  final TVEpisode? nextToPlay;
  final GestureTapCallback? onTap;

  const NextToPlaySection({super.key, this.nextToPlay, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(AppLocalizations.of(context)!.titleNext, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 250,
          child: Align(
            alignment: Alignment.topLeft,
            child: EpisodeCard(
              image: nextToPlay!.poster,
              text: '${nextToPlay!.episode}. ${nextToPlay!.displayTitle()}',
              subText: nextToPlay!.airDate?.format(),
              onTap: onTap,
            ),
          ),
        ),
      ],
    );
  }
}
