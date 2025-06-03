import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/async_image.dart';
import '../../../components/gap.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../media/search.dart';

class StudiosSection extends StatelessWidget {
  const StudiosSection({super.key, required this.studios, required this.type});

  final List<Studio> studios;
  final MediaType type;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppLocalizations.of(context)!.titleStudios, style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 30,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (BuildContext context, int index) => Gap.hSM,
            itemCount: studios.length,
            itemBuilder:
                (BuildContext context, int index) => FilledButton.tonal(
                  onPressed:
                      () => navigateTo(
                        context,
                        SearchPage(activeTab: type == MediaType.movie ? 1 : 0, selectedStudio: [studios[index]]),
                      ),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                  child:
                      studios[index].logo != null
                          ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: AsyncImage(studios[index].logo!, errorIconSize: 12),
                          )
                          : Text(studios[index].name),
                ),
          ),
        ),
      ],
    );
  }
}
