import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/async_image.dart';
import '../../../components/gap.dart';
import '../../../utils/utils.dart';
import '../../media/filter.dart';

class StudiosSection extends StatelessWidget {
  final List<Studio> studios;

  const StudiosSection({super.key, required this.studios});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(AppLocalizations.of(context)!.titleStudios, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 30,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) => Gap.hSM,
              itemCount: studios.length,
              itemBuilder: (BuildContext context, int index) => FilledButton.tonal(
                  onPressed: () => navigateTo(context, FilterPage(queryType: QueryType.studio, id: studios[index].id)),
                  child: studios[index].logo != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AsyncImage(studios[index].logo!, errorIconSize: 12),
                        )
                      : Text(studios[index].name))),
        ),
      ],
    );
  }
}
