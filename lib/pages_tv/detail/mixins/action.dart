import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../components/setting.dart';
import '../../components/time_picker.dart';
import '../../utils/notification.dart';
import '../../utils/utils.dart';

mixin ActionMixin<S extends StatefulWidget> on State<S> {
  bool refresh = false;

  Widget buildSkipIntroAction<T extends MediaBase>(BuildContext context, T item, MediaType type, Duration value) {
    return ButtonSettingItem(
      leading: const Icon(Icons.access_time),
      title: Text(AppLocalizations.of(context)!.buttonSkipFromStart),
      onTap: () async {
        final time = await Navigator.of(context).push(
          FadeInPageRoute<Duration>(
            builder:
                (context) => SettingPage(
                  title: AppLocalizations.of(context)!.buttonSkipFromStart,
                  child: TimePicker(value: value),
                ),
          ),
        );
        if (time != null) {
          Api.setSkipTime(SkipTimeType.intro, type, item.id, time);
          setState(() {});
        }
      },
    );
  }

  Widget buildSkipEndingAction<T extends MediaBase>(BuildContext context, T item, MediaType type, Duration value) {
    return ButtonSettingItem(
      leading: const Icon(Icons.access_time),
      title: Text(AppLocalizations.of(context)!.buttonSkipFromEnd),
      onTap: () async {
        final time = await Navigator.of(context).push(
          FadeInPageRoute<Duration>(
            builder:
                (context) => SettingPage(
                  title: AppLocalizations.of(context)!.buttonSkipFromEnd,
                  child: TimePicker(value: value),
                ),
          ),
        );
        if (time != null) {
          Api.setSkipTime(SkipTimeType.ending, type, item.id, time);
          setState(() {});
        }
      },
    );
  }

  Widget buildEditMetadataAction(BuildContext context, VoidCallback? onTap) {
    return ButtonSettingItem(
      leading: const Icon(Icons.edit_outlined),
      title: Text(AppLocalizations.of(context)!.buttonEditMetadata),
      onTap: onTap,
    );
  }

  Widget buildHomeAction(BuildContext context, Uri uri) {
    return ButtonSettingItem(
      leading: const Icon(Icons.home_outlined),
      title: Text(AppLocalizations.of(context)!.buttonHome),
      onTap:
          () => launchUrl(
            uri,
            mode: LaunchMode.inAppBrowserView,
            browserConfiguration: const BrowserConfiguration(showTitle: true),
          ),
    );
  }

  Widget buildDownloadAction(BuildContext context, dynamic fileId) {
    return ButtonSettingItem(
      title: Text(AppLocalizations.of(context)!.buttonDownload),
      leading: const Icon(Icons.download_outlined),
      onTap: () async {
        final resp = await showNotification(
          context,
          Api.downloadTaskCreate(fileId),
          successText: AppLocalizations.of(context)!.tipsForDownload,
        );
        if (resp?.error == null) setState(() => refresh = true);
      },
    );
  }

  Widget buildDeleteAction(BuildContext context, Future<void> Function() future) {
    return ButtonSettingItem(
      leading: const Icon(Icons.delete_outline),
      title: Text(AppLocalizations.of(context)!.buttonDelete),
      onTap: () async {
        final confirmed = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText);
        if (confirmed != true) return;
        await future();
        if (!context.mounted) return;
        refresh = true;
        Scaffold.of(context).closeEndDrawer();
        Navigator.of(navigatorKey.currentContext!).pop(refresh);
      },
    );
  }
}
