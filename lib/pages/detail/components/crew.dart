import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../components/image_card.dart';
import '../../media/search.dart';

class CrewSection extends StatelessWidget {
  const CrewSection({super.key, required this.crew, required this.type});

  final List<MediaCrew> crew;
  final MediaType type;

  @override
  Widget build(BuildContext context) {
    return crew.isNotEmpty
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                spacing: 4,
                children: [
                  Text(AppLocalizations.of(context)!.titleCrew, style: Theme.of(context).textTheme.titleMedium),
                  Text('(${crew.length})', style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
            SizedBox(
              height: 210,
              child: ListView.separated(
                itemCount: crew.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) {
                  final cr = crew[index];
                  return ImageCard(
                    cr.profile,
                    width: 100,
                    height: 150,
                    noImageIcon: cr.gender == 1 ? Icons.person_2 : Icons.person,
                    title: Text(cr.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cr.department != null) Text(cr.department!),
                        Text.rich(
                          TextSpan(
                            children: [
                              if (cr.job != null) TextSpan(text: '${cr.job}'),
                              if (cr.episodeCount != null) const WidgetSpan(child: SizedBox(width: 4)),
                              if (cr.episodeCount != null)
                                TextSpan(text: '(${AppLocalizations.of(context)!.episodeCount(cr.episodeCount!)})'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap:
                        () => navigateTo(
                          context,
                          SearchPage(activeTab: type == MediaType.movie ? 1 : 0, selectedCrew: [cr]),
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
