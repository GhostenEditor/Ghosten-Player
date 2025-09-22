import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/gap.dart';
import '../../components/logo.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_config.dart';
import '../components/updater.dart';

class SystemSettingsUpdater extends StatefulWidget {
  const SystemSettingsUpdater({super.key});

  @override
  State<SystemSettingsUpdater> createState() => SystemSettingsUpdaterState();
}

class SystemSettingsUpdaterState extends State<SystemSettingsUpdater> {
  late final _userConfig = Provider.of<UserConfig>(context);
  bool _loading = false;
  bool _updated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Logo(size: 100),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Badge(
                          label: Text(appVersion),
                          offset: Offset(16, -4),
                          child: Text(appName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                        Text(buildDate, style: Theme.of(context).textTheme.labelLarge),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PopupMenuButton(
                    offset: const Offset(1, 0),
                    tooltip: '',
                    onSelected: (value) => setState(() => _userConfig.setAutoUpdate(value)),
                    itemBuilder:
                        (context) =>
                            AutoUpdateFrequency.values
                                .map(
                                  (e) => CheckedPopupMenuItem(
                                    value: e,
                                    checked: e == _userConfig.autoUpdateFrequency,
                                    child: Text(AppLocalizations.of(context)!.autoUpdateFrequency(e.name)),
                                  ),
                                )
                                .toList(),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.autoCheckForUpdates),
                          Gap.hMD,
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.autoUpdateFrequency(_userConfig.autoUpdateFrequency.name),
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SwitchListTile(
                    value: _userConfig.updatePrerelease,
                    onChanged: (value) {
                      _userConfig.setUpdatePrerelease(value);
                      setState(() {});
                    },
                    title: Text(AppLocalizations.of(context)!.updatePrerelease),
                  ),
                  PopupMenuButton(
                    offset: const Offset(1, 0),
                    tooltip: '',
                    onSelected: (value) => setState(() => _userConfig.setGithubProxy(value)),
                    itemBuilder:
                        (context) =>
                            ['', 'https://gh-proxy.com/']
                                .map(
                                  (value) => CheckedPopupMenuItem(
                                    value: value,
                                    checked: value == _userConfig.githubProxy,
                                    child: Text(value.isNotEmpty ? value : AppLocalizations.of(context)!.none),
                                  ),
                                )
                                .toList(),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.githubProxy),
                          Gap.hMD,
                          Expanded(
                            child: Text(
                              _userConfig.githubProxy.isNotEmpty
                                  ? _userConfig.githubProxy
                                  : AppLocalizations.of(context)!.none,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed:
                  _loading || _updated
                      ? null
                      : () async {
                        setState(() => _loading = true);
                        final data = await Api.checkUpdate(
                          '${_userConfig.githubProxy}$updateUrl',
                          false,
                          Version.fromString(appVersion),
                        );
                        if (data != null && context.mounted) {
                          await showModalBottomSheet(
                            context: context,
                            constraints: const BoxConstraints(minWidth: double.infinity),
                            builder: (context) => UpdateBottomSheet(data),
                          );
                          _updated = true;
                        } else {
                          _updated = false;
                        }
                        setState(() => _loading = false);
                      },
              child:
                  _loading
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 12,
                        children: [
                          Text(AppLocalizations.of(context)!.checkForUpdates),
                          const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      )
                      : _updated
                      ? Text(AppLocalizations.of(context)!.isLatestVersion)
                      : Text(AppLocalizations.of(context)!.checkForUpdates),
            ),
            Gap.vMD,
          ],
        ),
      ),
    );
  }
}
