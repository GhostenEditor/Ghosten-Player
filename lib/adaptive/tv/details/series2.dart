import 'package:api/api.dart';
import 'package:flutter/material.dart' hide ListTile;

import '../../../l10n/app_localizations.dart';
import '../../../menus/season.dart';
import '../../../subtitles/season.dart';
import '../../../utils/utils.dart';
import '../../../view_models/view_models.dart';
import '../components/list_tile.dart';
import 'components/scaffold.dart';

class Series2Page extends StatefulWidget {
  const Series2Page({super.key});

  @override
  State<Series2Page> createState() => _Series2PageState();
}

class _Series2PageState extends State<Series2Page> {
  final currentSeason = ValueNotifier<TVSeason?>(null);
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    currentSeason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer<Series2ViewModel, TVSeries>(
      useScaffold: true,
      builder: (context, item, _) {
        if (item.seasons.isNotEmpty) {
          _switchSeason(
            item.seasons.firstWhere((it) => currentSeason.value == null || it.id == currentSeason.value?.id),
          );
        }
        return DetailScaffold(
          item: item,
          navigatorKey: _navigatorKey,
          menus: currentSeason.value != null ? SeasonMenu(currentSeason.value!) : null,
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.displayTitle(),
                style: Theme.of(context).textTheme.displaySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: AppLocalizations.of(context)!.seasonCount(item.seasons.length)),
                    const TextSpan(text: ' ・ '),
                    TextSpan(text: item.firstAirDate?.format()),
                  ],
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    ListenableBuilder(
                      listenable: currentSeason,
                      builder: (context, _) => SliverMainAxisGroup(
                        slivers: item.seasons.asMap().entries.map((entry) {
                          final TVSeason item = entry.value;
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: ListTile(
                                autofocus: entry.key == 0,
                                selected: currentSeason.value?.id == entry.value.id,
                                title: Text(
                                  AppLocalizations.of(context)!.seasonNumber(item.season),
                                  overflow: .ellipsis,
                                ),
                                subtitle: (item.title != null || item.airDate != null)
                                    ? SeasonSubtitle(item: item, iconSize: 14)
                                    : null,
                                onTap: () => _switchSeason(item),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ListTile(
                          leading: const Icon(Icons.more_horiz_rounded),
                          title: Text(AppLocalizations.of(context)!.buttonMore),
                          onTap: () {
                            if (currentSeason.value != null) {
                              Scaffold.of(context).openEndDrawer();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _switchSeason(TVSeason item) {
    if (currentSeason.value == item) {
      return;
    }
    currentSeason.value = item;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(_navigatorKey.currentContext!).pushAndRemoveUntil(
        FadeInPageRoute(
          builder: (context) => SeasonViewModel(context, id: item.id, data: item).build(),
        ),
        (_) => false,
      );
    });
  }
}
