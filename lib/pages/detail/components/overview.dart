import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../components/async_image.dart';
import '../../../components/blurred_background.dart';
import '../../../components/gap.dart';
import '../../../utils/utils.dart';

class OverviewSection<T extends MediaBase> extends StatelessWidget {
  final T item;
  final Widget? description;

  const OverviewSection({super.key, required this.item, this.description});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showFull(context),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(item.overview ?? AppLocalizations.of(context)!.noOverview, textAlign: TextAlign.justify, maxLines: 5, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  showFull(BuildContext context) {
    navigateToSlideUp(context, Overview(item: item, description: description));
  }
}

class Overview<T extends MediaBase> extends StatelessWidget {
  final T item;
  final Widget? description;

  const Overview({super.key, required this.item, this.description});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: item.themeColor != null ? Color(item.themeColor!) : Colors.blue, brightness: Theme.of(context).brightness)),
      child: Builder(builder: (context) {
        return DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.surface,
            ],
          )),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (item.poster != null)
                BlurredBackground(
                  defaultColor: item.themeColor != null ? Color(item.themeColor!) : null,
                  background: item.poster!,
                ),
              if (item.poster != null)
                Container(
                  color: Theme.of(context).colorScheme.surface.withAlpha(0x66),
                ),
              Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  systemOverlayStyle: getSystemUiOverlayStyle(context),
                ),
                backgroundColor: Colors.transparent,
                body: ListView(
                  padding: const EdgeInsets.only(top: 8, left: 32, right: 32, bottom: 32),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (item.poster != null) AsyncImage(item.poster!, width: 160, radius: const BorderRadius.all(Radius.circular(8))),
                        if (item.poster != null) Gap.hLG,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (item.title != null)
                                Text(item.title!, style: Theme.of(context).textTheme.titleLarge!.copyWith(height: 2, fontWeight: FontWeight.bold)),
                              if (item.airDate != null)
                                Text(item.airDate!.format(), style: Theme.of(context).textTheme.labelSmall!.copyWith(height: 2, fontWeight: FontWeight.bold)),
                              if (description != null) description!,
                            ],
                          ),
                        ),
                      ],
                    ),
                    Gap.vLG,
                    const Divider(),
                    Gap.vLG,
                    if (item.overview != null)
                      SelectableText(
                        item.overview!,
                        textAlign: TextAlign.justify,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.5),
                      ),
                    const SafeArea(child: SizedBox()),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
