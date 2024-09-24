import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../const.dart';

class NoData extends StatelessWidget {
  final Widget? action;

  const NoData({super.key, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(assetsNoData, width: 200, height: 200, filterQuality: FilterQuality.medium),
          Padding(
            padding: action == null ? const EdgeInsets.only(bottom: 16) : EdgeInsets.zero,
            child: Text(AppLocalizations.of(context)!.noData),
          ),
          if (action != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: action,
            )
        ],
      ),
    );
  }
}
