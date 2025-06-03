import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/future_builder_handler.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_config.dart';

class SettingsSponsor extends StatefulWidget {
  const SettingsSponsor({super.key});

  @override
  State<SettingsSponsor> createState() => _SettingsSponsorState();
}

class _SettingsSponsorState extends State<SettingsSponsor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsItemSponsor), centerTitle: true),
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Material(
                          elevation: 16,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset('assets/common/images/sponsor_code.webp'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      AppLocalizations.of(context)!.sponsorMessage,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color:
                            ColorScheme.fromSeed(
                              seedColor: const Color(0xFF33281B),
                              brightness: Theme.of(context).brightness,
                            ).onPrimaryContainer,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      AppLocalizations.of(context)!.sponsorThanksMessage,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(AppLocalizations.of(context)!.sponsorTipMessage),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Divider(height: 24)),
            SliverSafeArea(
              sliver: FutureBuilderSliverHandler(
                future: _getSponsorList(),
                builder: (context, snapshot) {
                  return SliverList.builder(
                    itemCount: snapshot.requireData.length,
                    itemBuilder:
                        (context, index) => Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
                            child: ListTile(dense: true, title: Text(snapshot.requireData[index]), minTileHeight: 24),
                          ),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _getSponsorList() async {
    final proxy = context.read<UserConfig>().githubProxy;
    try {
      final resp = await Dio().get(
        '${proxy}https://raw.githubusercontent.com/$repoAuthor/$repoName/main/sponsor_list.txt',
      );
      final data = resp.data as String;
      return data.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } catch (e) {
      rethrow;
    }
  }
}
