import 'package:api/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PopupMenuItem;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../components/appbar_progress.dart';
import '../../components/logo.dart';
import '../../components/popup_menu.dart';
import '../../components/scrollbar.dart';
import '../../const.dart';
import '../../providers/user_config.dart';
import '../../utils/notification.dart';
import '../../utils/utils.dart';
import '../account/account.dart';
import '../library.dart';
import 'settings_dns.dart';
import 'settings_downloader.dart';
import 'settings_player.dart';
import 'settings_player_history.dart';
import 'settings_server.dart';
import 'settings_sync.dart';
import 'settings_updater.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userConfig = Provider.of<UserConfig>(context, listen: true);
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settingsTitle),
          bottom: const AppbarProgressIndicator(),
          leading: const Padding(padding: EdgeInsets.all(12), child: Logo()),
          systemOverlayStyle: getSystemUiOverlayStyle(context),
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
              onTap: () => navigateTo(context, LibraryManage(title: AppLocalizations.of(context)!.settingsItemTV, type: LibraryType.tv)),
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemMovie,
              Icons.movie_creation_outlined,
              onTap: () => navigateTo(context, LibraryManage(title: AppLocalizations.of(context)!.settingsItemMovie, type: LibraryType.movie)),
            ),
            const Divider(),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemPlayerHistory,
              Icons.history_rounded,
              onTap: () => navigateTo(context, const SystemSettingsPlayerHistory()),
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemPlayerSettings,
              Icons.play_circle_outline,
              onTap: () => navigateTo(context, const SystemSettingsPlayer()),
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemDownload,
              Icons.download_outlined,
              trailing: const Badge(label: Text('Beta')),
              onTap: () => navigateTo(context, const SystemSettingsDownloader()),
            ),
            const Divider(),
            _buildPopupMenuItem(
              title: AppLocalizations.of(context)!.settingsItemLanguage,
              icon: Icons.language,
              trailing: AppLocalizations.of(context)!.systemLanguage(userConfig.language.name),
              onSelected: userConfig.setLanguage,
              itemBuilder: (BuildContext context) => SystemLanguage.values
                  .map((language) => PopupMenuItem(
                        value: language,
                        autofocus: kIsAndroidTV && userConfig.language == language,
                        trailing: Icon(userConfig.language == language ? Icons.done : null),
                        title: Text(AppLocalizations.of(context)!.systemLanguage(language.name)),
                      ))
                  .toList(),
            ),
            _buildPopupMenuItem(
              title: AppLocalizations.of(context)!.settingsItemTheme,
              icon: Icons.light_mode_outlined,
              trailing: AppLocalizations.of(context)!.systemTheme(userConfig.themeMode.name),
              onSelected: userConfig.setTheme,
              itemBuilder: (BuildContext context) => ThemeMode.values
                  .map((theme) => PopupMenuItem(
                        autofocus: kIsAndroidTV && userConfig.themeMode == theme,
                        value: theme,
                        trailing: Icon(userConfig.themeMode == theme ? Icons.done : null),
                        title: Text(AppLocalizations.of(context)!.systemTheme(theme.name).padRight(8, ' ')),
                      ))
                  .toList(),
            ),
            const Divider(),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemDNS,
              Icons.dns_outlined,
              onTap: () => navigateTo(context, const SystemSettingsDNS()),
            ),
            if (alphaVersion)
              _buildItem(
                AppLocalizations.of(context)!.settingsItemServer,
                Icons.storage_outlined,
                trailing: const Badge(label: Text('Alpha')),
                onTap: () => navigateTo(context, const SystemSettingsServer()),
              ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemDataSync,
              Icons.sync,
              onTap: () => navigateTo(context, const SettingsSyncPage()),
            ),
            _buildItem(
              AppLocalizations.of(context)!.settingsItemDataReset,
              Icons.restart_alt,
              onTap: () async {
                final confirmed = await showConfirm(context, AppLocalizations.of(context)!.confirmTextResetData);
                if (confirmed == true && context.mounted) {
                  await showNotification(context, Api.resetData(), successText: AppLocalizations.of(context)!.modalNotificationResetSuccessText);
                }
              },
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
            Text(title),
            if (trailing != null) trailing,
          ],
        ),
        leading: Icon(icon),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
        onTap: onTap);
  }

  Widget _buildPopupMenuItem<T>({
    required String title,
    required String trailing,
    IconData? icon,
    PopupMenuItemSelected<T>? onSelected,
    required PopupMenuItemBuilder<T> itemBuilder,
  }) {
    return PopupMenuButton<T>(
      offset: const Offset(1, 0),
      tooltip: '',
      onSelected: onSelected,
      itemBuilder: itemBuilder,
      child: ListTile(
        leading: Icon(icon),
        trailing: Text(trailing),
        title: Text(title),
      ),
    );
  }
}
