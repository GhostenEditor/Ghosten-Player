import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../../l10n/app_localizations.dart';

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key, this.trimLines = 2, required this.text});

  final String? text;
  final int trimLines;

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      text ?? AppLocalizations.of(context)!.noOverview,
      trimLines: trimLines,
      trimMode: TrimMode.Line,
      trimExpandedText: AppLocalizations.of(context)!.tagShowLess,
      trimCollapsedText: AppLocalizations.of(context)!.tagShowMore,
    );
  }
}
