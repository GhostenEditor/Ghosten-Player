import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide ListTile;

import '../../components/components.dart';
import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';

class SettingsSponsor extends StatelessWidget {
  const SettingsSponsor({super.key});

  @override
  Widget build(BuildContext context) {
    final int cacheSize = (MediaQuery.of(context).devicePixelRatio * 240).round();
    return OrientationPage(
      section1: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 36,
          children: [
            Material(
              elevation: 24,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Builder(
                builder: (context) => Image.asset(
                  'assets/images/sponsor-code.webp',
                  width: 240,
                  height: 240,
                  cacheWidth: cacheSize,
                  cacheHeight: cacheSize,
                ),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.sponsorMessage,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF33281B),
                  brightness: Theme.of(context).brightness,
                ).onPrimaryContainer,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      section2: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: ListTile(
              title: Text(
                AppLocalizations.of(context)!.sponsorThanksMessage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(AppLocalizations.of(context)!.sponsorTipMessage),
            ),
          ),
          FutureBuilderSliverHandler(
            future: _getSponsorList(context),
            loadingBuilder: (context, _) =>
                const SliverFillRemaining(hasScrollBody: false, fillOverscroll: true, child: Loading()),
            builder: (context, snapshot) => SliverPadding(
              padding: const .only(bottom: 16),
              sliver: SliverList.builder(
                itemCount: snapshot.requireData.length,
                itemBuilder: (context, index) => ListTile(title: Text(snapshot.requireData[index]), onTap: () {}),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _getSponsorList(BuildContext context) async {
    try {
      final Response<String> resp = await cacheHttpClient.get<String>(sponsorUrl);
      return resp.data?.split('\n').where((s) => s.trim().isNotEmpty).toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }
}
