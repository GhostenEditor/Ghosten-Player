import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../adaptive/adaptive.dart';

class SystemSettingsDownloader extends StatefulWidget {
  const SystemSettingsDownloader({super.key});

  @override
  State<SystemSettingsDownloader> createState() => _SystemSettingsDownloaderState();
}

class _SystemSettingsDownloaderState extends State<SystemSettingsDownloader> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(vsync: this, length: 2);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingPage(
      title: Text(AppLocalizations.of(context)!.settingsItemDownload),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.downloaderLabelDownloading),
              Tab(text: AppLocalizations.of(context)!.downloaderLabelDownloaded),
            ],
          ),
        ],
      ),
    );
  }
}
