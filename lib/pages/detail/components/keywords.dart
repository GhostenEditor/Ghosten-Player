import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../media/search.dart';

class KeywordsSection extends StatelessWidget {
  const KeywordsSection({super.key, required this.keywords, required this.type});

  final MediaType type;
  final List<Keyword> keywords;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(AppLocalizations.of(context)!.titleKeyword, style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 20,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 4),
            itemCount: keywords.length,
            itemBuilder:
                (BuildContext context, int index) => TextButton(
                  style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6))),
                  onPressed:
                      () => navigateTo(
                        context,
                        SearchPage(activeTab: type == MediaType.movie ? 1 : 0, selectedKeyword: [keywords[index]]),
                      ),
                  child: Text(keywords[index].name, style: Theme.of(context).textTheme.labelSmall),
                ),
          ),
        ),
      ],
    );
  }
}
