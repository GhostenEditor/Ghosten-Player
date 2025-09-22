import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../components/async_image.dart';
import '../../../components/gap.dart';
import '../../../components/placeholder.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../components/image_card.dart';
import '../../components/theme_builder.dart';
import '../components/overview.dart';
import '../components/player_backdrop.dart';
import '../components/player_scaffold.dart';

const _aspectRatio = 16 / 9;

class MoviePlaceholder extends StatelessWidget {
  const MoviePlaceholder({super.key, this.item});

  final Movie? item;

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      item?.themeColor,
      builder:
          (context) => PlayerScaffold(
            playerControls: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxWidth / _aspectRatio + MediaQuery.paddingOf(context).top;
                return SizedBox(
                  height: height,
                  child: Theme(
                    data: ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: item?.themeColor != null ? Color(item!.themeColor!) : Colors.blue,
                        brightness: Brightness.dark,
                      ),
                      appBarTheme: const AppBarTheme(iconTheme: IconThemeData(size: 20)),
                    ),
                    child: Scaffold(
                      appBar: AppBar(backgroundColor: Colors.transparent),
                      resizeToAvoidBottomInset: false,
                      backgroundColor: Colors.transparent,
                      extendBodyBehindAppBar: true,
                      extendBody: true,
                      body: Stack(
                        children: [
                          PlayerBackdrop(backdrop: item?.backdrop, logo: item?.logo),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black54, Colors.transparent, Colors.transparent, Colors.black54],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            sidebar: Scaffold(
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.titlePlaylist,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                primary: false,
                automaticallyImplyLeading: false,
              ),
              primary: false,
              body: GPlaceholder(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return const ImageCardWidePlaceholder(width: 71, height: 107);
                  },
                ),
              ),
            ),
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    primary: false,
                    automaticallyImplyLeading: false,
                    title:
                        item != null
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item!.displayTitle(), style: Theme.of(context).textTheme.titleMedium),
                                DefaultTextStyle(
                                  style: Theme.of(context).textTheme.labelSmall!,
                                  overflow: TextOverflow.ellipsis,
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: item!.releaseDate?.format() ?? AppLocalizations.of(context)!.tagUnknown,
                                        ),
                                        const WidgetSpan(child: SizedBox(width: 20)),
                                        const WidgetSpan(child: Icon(Icons.star, color: Colors.orangeAccent, size: 14)),
                                        TextSpan(
                                          text:
                                              item!.voteAverage?.toStringAsFixed(1) ??
                                              AppLocalizations.of(context)!.tagUnknown,
                                        ),
                                        const WidgetSpan(child: SizedBox(width: 20)),
                                        TextSpan(text: AppLocalizations.of(context)!.seriesStatus(item!.status.name)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : const SizedBox(),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    actions: const [IconButton(onPressed: null, icon: Icon(Icons.more_vert_rounded))],
                  ),
                  SliverMainAxisGroup(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: Builder(
                            builder: (context) {
                              if (item != null) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item!.poster != null)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 16),
                                        child: AsyncImage(
                                          item!.poster!,
                                          width: 100,
                                          height: 150,
                                          radius: BorderRadius.circular(4),
                                          viewable: true,
                                        ),
                                      )
                                    else
                                      const SizedBox(),
                                    Expanded(child: OverviewSection(text: item!.overview, trimLines: 7)),
                                  ],
                                );
                              } else {
                                return GPlaceholder(
                                  child: IgnorePointer(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: Container(
                                            width: 100,
                                            height: 150,
                                            decoration: GPlaceholderDecoration.base,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            spacing: 7,
                                            children: List.generate(
                                              8,
                                              (index) => FractionallySizedBox(
                                                widthFactor: Random().nextDouble() * 0.2 + 0.7,
                                                child: Container(height: 12, decoration: GPlaceholderDecoration.base),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: GPlaceholder(
                      child: IgnorePointer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const GPlaceholderRect(width: 100, height: 24, padding: EdgeInsets.all(16)),
                            SizedBox(
                              height: 180 + 50,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                scrollDirection: Axis.horizontal,
                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  return const ImageCardPlaceholder(width: 120, height: 180);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: GPlaceholder(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const GPlaceholderRect(width: 100, height: 24, padding: EdgeInsets.all(16)),
                          SizedBox(
                            height: 30,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              separatorBuilder: (BuildContext context, int index) => Gap.hSM,
                              itemCount: 5,
                              itemBuilder:
                                  (BuildContext context, int index) => FilledButton.tonal(
                                    onPressed: () {},
                                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      child: SizedBox(),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: GPlaceholder(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const GPlaceholderRect(width: 100, height: 24, padding: EdgeInsets.all(16)),
                          SizedBox(
                            height: 30,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 10),
                              itemCount: 5,
                              itemBuilder:
                                  (BuildContext context, int index) => FilledButton.tonal(
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      minimumSize: Size.zero,
                                      textStyle: Theme.of(context).textTheme.labelMedium,
                                    ),
                                    onPressed: () {},
                                    child: const Text('          '),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: GPlaceholder(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const GPlaceholderRect(width: 100, height: 24, padding: EdgeInsets.all(16)),
                          SizedBox(
                            height: 20,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 4),
                              itemCount: 5,
                              itemBuilder:
                                  (BuildContext context, int index) => TextButton(
                                    style: const ButtonStyle(
                                      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 6)),
                                    ),
                                    onPressed: () {},
                                    child: Text('      ', style: Theme.of(context).textTheme.labelSmall),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverSafeArea(top: false, sliver: SliverToBoxAdapter()),
                ],
              ),
            ),
          ),
    );
  }
}
