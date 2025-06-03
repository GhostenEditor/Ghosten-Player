import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../components/image_card.dart';
import '../../media/search.dart';

class CastSection extends StatelessWidget {
  const CastSection({super.key, required this.cast, required this.type});

  final List<MediaCast> cast;
  final MediaType type;

  @override
  Widget build(BuildContext context) {
    return cast.isNotEmpty
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                spacing: 4,
                children: [
                  Text(AppLocalizations.of(context)!.titleCast, style: Theme.of(context).textTheme.titleMedium),
                  Text('(${cast.length})', style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
            SizedBox(
              height: 210,
              child: ListView.separated(
                itemCount: cast.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) {
                  final ca = cast[index];
                  return ImageCard(
                    ca.profile,
                    width: 100,
                    height: 150,
                    noImageIcon: ca.gender == 1 ? Icons.person_2 : Icons.person,
                    title: Text(ca.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ca.role != null && ca.role!.isNotEmpty)
                          Text('${AppLocalizations.of(context)!.actAs} ${ca.role}'),
                        if (ca.episodeCount != null && ca.episodeCount! > 0) Text('${ca.episodeCount}集'),
                      ],
                    ),
                    onTap:
                        () => navigateTo(
                          context,
                          SearchPage(activeTab: type == MediaType.movie ? 1 : 0, selectedCast: [ca]),
                        ),
                  );
                },
              ),
            ),
          ],
        )
        : Container();
  }
}
