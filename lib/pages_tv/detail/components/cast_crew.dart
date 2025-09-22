import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/utils.dart';
import '../../components/focusable_image.dart';
import '../../media/search.dart';

class CastCrewInner extends StatelessWidget {
  const CastCrewInner({super.key, required this.mediaCast, required this.mediaCrew, required this.type});

  final List<MediaCast> mediaCast;
  final List<MediaCrew> mediaCrew;
  final MediaType type;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 160,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: max(mediaCast.length, mediaCrew.length) * 2,
      itemBuilder: (context, index) {
        final int i = (index / 2).floor();
        if (index.isEven) {
          return i < mediaCast.length
              ? _CastListTile(
                mediaCast: mediaCast[i],
                autofocus: index == 0,
                onTap: () {
                  navigateTo(
                    navigatorKey.currentContext!,
                    SearchPage(activeTab: type == MediaType.movie ? 1 : 0, selectedCast: [mediaCast[i]]),
                  );
                },
              )
              : const SizedBox();
        } else {
          return i < mediaCrew.length
              ? _CrewListTile(
                mediaCrew: mediaCrew[i],
                onTap: () {
                  navigateTo(
                    navigatorKey.currentContext!,
                    SearchPage(activeTab: type == MediaType.movie ? 1 : 0, selectedCrew: [mediaCrew[i]]),
                  );
                },
              )
              : const SizedBox();
        }
      },
    );
  }
}

class CastCrewTitle extends StatelessWidget {
  const CastCrewTitle({super.key, required this.mediaCast, required this.mediaCrew});

  final List<MediaCast> mediaCast;
  final List<MediaCrew> mediaCrew;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
      child: SliverCrossAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: mediaCast.isNotEmpty ? Text(AppLocalizations.of(context)!.titleCast) : null,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: mediaCrew.isNotEmpty ? Text(AppLocalizations.of(context)!.titleCrew) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class CastCrewSection extends StatelessWidget {
  const CastCrewSection({super.key, required this.mediaCast, required this.mediaCrew, required this.type});

  final List<MediaCast> mediaCast;
  final List<MediaCrew> mediaCrew;
  final MediaType type;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
        CastCrewTitle(mediaCast: mediaCast, mediaCrew: mediaCrew),
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: CastCrewInner(mediaCast: mediaCast, mediaCrew: mediaCrew, type: type),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _CastListTile extends StatelessWidget {
  const _CastListTile({required this.mediaCast, this.autofocus = false, this.onTap});

  final MediaCast mediaCast;
  final bool autofocus;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: FocusableImage(
              autofocus: autofocus,
              poster: mediaCast.profile,
              placeholderIcon: Icons.account_circle_outlined,
              onTap: onTap,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  mediaCast.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                if (mediaCast.role != null)
                  Text(
                    '${AppLocalizations.of(context)!.actAs} ${mediaCast.role}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                Text(AppLocalizations.of(context)!.gender(mediaCast.gender.toString())),
                if (mediaCast.episodeCount != null && mediaCast.episodeCount! > 0) Text('${mediaCast.episodeCount}集'),
                if (mediaCast.scrapper.type == 'tmdb') const _IMDBTag() else const _NfoTag(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CrewListTile extends StatelessWidget {
  const _CrewListTile({required this.mediaCrew, this.onTap});

  final MediaCrew mediaCrew;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Row(
        spacing: 16,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: FocusableImage(
              poster: mediaCrew.profile,
              placeholderIcon: Icons.account_circle_outlined,
              onTap: onTap,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  mediaCrew.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                if (mediaCrew.department != null)
                  Text(mediaCrew.department!, style: Theme.of(context).textTheme.bodySmall),
                if (mediaCrew.job != null) Text(mediaCrew.job!, style: Theme.of(context).textTheme.bodySmall),
                Text(AppLocalizations.of(context)!.gender(mediaCrew.gender.toString())),
                if (mediaCrew.episodeCount != null && mediaCrew.episodeCount! > 0) Text('${mediaCrew.episodeCount}集'),
                if (mediaCrew.scrapper.type == 'tmdb') const _IMDBTag() else const _NfoTag(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IMDBTag extends StatelessWidget {
  const _IMDBTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff86caa5)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(2),
      child: const Text('TMDB', style: TextStyle(fontSize: 8, color: Color(0xff86caa5))),
    );
  }
}

class _NfoTag extends StatelessWidget {
  const _NfoTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff86caa5)),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(2),
      child: const Text('NFO', style: TextStyle(fontSize: 8, color: Color(0xff86caa5))),
    );
  }
}
