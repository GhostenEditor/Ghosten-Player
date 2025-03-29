import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../components/logo.dart';
import '../../components/scrollbar.dart';
import '../../const.dart';
import '../../utils/utils.dart';
import '../account/account.dart';
import '../components/appbar_progress.dart';
import '../library.dart';
import '../utils/utils.dart';
import 'settings_diagnotics.dart';
import 'settings_downloader.dart';
import 'settings_log.dart';
import 'settings_other.dart';
import 'settings_player_history.dart';
import 'settings_server.dart';
import 'settings_sponsor.dart';
import 'settings_updater.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settingsTitle),
          bottom: const AppbarProgressIndicator(),
          leading: isMobile(context) ? const Padding(padding: EdgeInsets.all(12), child: Logo()) : null,
        ),
        body: ScrollbarListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            _buildItem(
              AppLocalizations.of(context)!.settingsItemAccount,
              Icons.account_box_outlined,
              onTap: () => navigateTo(context, const AccountManage()),
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemTV,
              Icons.tv,
              onTap: () => navigateTo(context, const LibraryManage(type: LibraryType.tv)),
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemMovie,
              Icons.movie_creation_outlined,
              onTap: () => navigateTo(context, const LibraryManage(type: LibraryType.movie)),
            ),
            const Divider(),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemPlayerHistory,
              Icons.history_rounded,
              onTap: () => navigateTo(context, const SystemSettingsPlayerHistory()),
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemDownload,
              Icons.download_outlined,
              onTap: () => navigateTo(context, const SystemSettingsDownloader()),
            ),
            const Divider(),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemServer,
              Icons.storage_outlined,
              trailing: const Badge(label: Text('Beta')),
              onTap: () => navigateTo(context, const SystemSettingsServer()),
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemNetworkDiagnotics,
              Icons.rule_rounded,
              onTap: () => navigateTo(context, const SettingsDiagnotics()),
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemLog,
              Icons.article_outlined,
              onTap: () => navigateTo(context, const SettingsLogPage()),
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemOthers,
              Icons.more_horiz_rounded,
              onTap: () => navigateTo(context, const SystemSettingsOther()),
            ),
            const Divider(),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemFeedback,
              Icons.feedback_outlined,
              onTap: () {
                launchUrlString('https://github.com/$repoAuthor/$repoName/issues', browserConfiguration: const BrowserConfiguration(showTitle: true));
              },
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemSponsor,
              Icons.card_giftcard_rounded,
              onTap: () => navigateTo(context, const SettingsSponsor()),
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemInfo,
              Icons.info_outline,
              onTap: () => navigateTo(context, const SystemSettingsUpdater()),
            ),
          ],
        ));
  }

  Widget _buildItem(String title, IconData icon, {Widget? trailing, GestureTapCallback? onTap}) {
    return ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title)),
            if (trailing != null) trailing,
          ],
        ),
        leading: Icon(icon),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
        onTap: onTap);
  }
}
