import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_config.dart';
import '../components/future_builder_handler.dart';
import '../components/setting.dart';

class SettingsSponsor extends StatelessWidget {
  const SettingsSponsor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          spacing: 32,
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 36,
                children: [
                  Material(
                    elevation: 24,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/common/images/sponsor_code.webp', width: 240, height: 240),
                  ),
                  Text(
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
                ],
              ),
            ),
            const VerticalDivider(indent: 60, endIndent: 60),
            Flexible(
              fit: FlexFit.tight,
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: Focus(child: SizedBox())),
                  SliverToBoxAdapter(
                    child: SafeArea(
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
                  FutureBuilderSliverHandler(
                    future: _getSponsorList(context),
                    builder: (context, snapshot) {
                      return SliverList.builder(
                        itemCount: snapshot.requireData.length,
                        itemBuilder:
                            (context, index) =>
                                ButtonSettingItem(dense: true, title: Text(snapshot.requireData[index]), onTap: () {}),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _getSponsorList(BuildContext context) async {
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
