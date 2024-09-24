import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/utils.dart';
import '../../media/filter.dart';

class GenresSection extends StatelessWidget {
  final List<Genre> genres;

  const GenresSection({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(AppLocalizations.of(context)!.titleType, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 30,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
              itemCount: genres.length,
              itemBuilder: (BuildContext context, int index) => FilledButton.tonal(
                  onPressed: () => navigateTo(context, FilterPage(queryType: QueryType.genre, id: genres[index].id)), child: Text(genres[index].name))),
        ),
      ],
    );
  }
}
