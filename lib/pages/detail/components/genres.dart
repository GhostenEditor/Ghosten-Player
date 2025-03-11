import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/utils.dart';
import '../../media/filter.dart';

class GenresSection extends StatelessWidget {
  const GenresSection({super.key, required this.genres});

  final List<Genre> genres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppLocalizations.of(context)!.titleType, style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 30,
          child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
              itemCount: genres.length,
              itemBuilder: (BuildContext context, int index) => FilledButton.tonal(
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: Size.zero, textStyle: Theme.of(context).textTheme.labelMedium),
                  onPressed: () => navigateTo(context, FilterPage(id: genres[index].id)),
                  child: Text(genres[index].name))),
        ),
      ],
    );
  }
}
