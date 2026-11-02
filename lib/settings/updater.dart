import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../adaptive/adaptive.dart' hide Scrollbar;
import '../components/components.dart ';
import '../l10n/app_localizations.dart';
import '../providers/user_config.dart';
import '../utils/check_update.dart';
import '../utils/utils.dart';
import '../viewers/markdown_viewer.dart';

class SettingsUpdater extends StatefulWidget {
  const SettingsUpdater({super.key});

  @override
  State<SettingsUpdater> createState() => _SettingsUpdaterState();
}

class _SettingsUpdaterState extends State<SettingsUpdater> {
  static final Map<String, _DownloadTask> _downloading = {};

  @override
  Widget build(BuildContext context) {
    return ElevatedButtonTheme(
      data: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ).merge(Theme.of(context).elevatedButtonTheme.style),
      ),
      child: FutureBuilder(
        future: checkUpdate(context.read<UserConfig>().updatePrerelease),
        builder: (context, snapshot) {
          late final Widget? section1;
          Widget? section2;
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              section1 = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  Text(AppLocalizations.of(context)!.checkingUpdates, style: Theme.of(context).textTheme.displaySmall),
                  const LinearProgressIndicator(),
                  ElevatedButton(onPressed: null, child: Text(AppLocalizations.of(context)!.checkForUpdates)),
                ],
              );
            case ConnectionState.none:
            case ConnectionState.done:
              if (snapshot.hasData) {
                section1 = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.latestVersion(snapshot.requireData!.version),
                          style: Theme.of(context).textTheme.displaySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          snapshot.requireData!.createAt?.format() ?? '',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                    if (_downloading.containsKey(snapshot.requireData!.url))
                      ListenableBuilder(
                        listenable: _downloading[snapshot.requireData!.url]!.progress,
                        builder: (context, _) =>
                            LinearProgressIndicator(value: _downloading[snapshot.requireData!.url]!.progress.value),
                      )
                    else
                      const LinearProgressIndicator(value: 1, color: Colors.greenAccent),
                    ElevatedButton(
                      onPressed: _downloading.containsKey(snapshot.requireData!.url)
                          ? null
                          : () => _download(snapshot.requireData!),
                      child: Text(
                        _downloading.containsKey(snapshot.requireData!.url)
                            ? AppLocalizations.of(context)!.updating
                            : AppLocalizations.of(context)!.updateNow,
                      ),
                    ),
                  ],
                );
                section2 = SliverMarkdownViewer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  data: snapshot.requireData!.comment,
                );
              } else if (snapshot.hasError) {
                section1 = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    Text(AppLocalizations.of(context)!.updateFailed, style: Theme.of(context).textTheme.displaySmall),
                    const LinearProgressIndicator(value: 1, color: Colors.redAccent),
                    ElevatedButton(
                      autofocus: true,
                      onPressed: () => setState(() {}),
                      child: Text(AppLocalizations.of(context)!.checkForUpdates),
                    ),
                  ],
                );
                section2 = SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  sliver: SliverToBoxAdapter(child: ErrorMessage(error: snapshot.error)),
                );
              } else {
                section1 = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.isLatestVersion,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    LinearProgressIndicator(value: 1, color: Theme.of(context).colorScheme.surfaceContainer),
                    Text(
                      AppLocalizations.of(context)!.lastCheckedUpdatesTime(DateTime.now().formatFullWithoutSec()),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    ElevatedButton(
                      autofocus: true,
                      onPressed: () => setState(() {}),
                      child: Text(AppLocalizations.of(context)!.checkForUpdates),
                    ),
                  ],
                );
              }
          }

          return OrientationPage(
            autoScroll: true,
            section1: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(padding: const EdgeInsets.only(bottom: 64), child: section1),
                ),
              ),
            ),
            section2: section2,
          );
        },
      ),
    );
  }

  Future<void> _download(UpdateData data) async {
    if (!await FilePicker.requestInstallPermission()) {
      return;
    }
    if (_downloading.containsKey(data.url)) {
      return;
    }
    if (data.digest == null && mounted) {
      await showNotification(context, Future.error(Exception('版本过旧，无法下载')));
      return;
    }
    final task = _DownloadTask(data.url);
    setState(() => _downloading.putIfAbsent(data.url, () => task));
    final String directory = (await FilePicker.cachePath)!;

    final File? file = await download(
      digest: data.digest!,
      url: data.url,
      filename: '${data.version}-${data.name}',
      directory: directory,
      onProgress: (progress) => task.progress.value = progress,
      onError: (error) => showNotification(context, Future.error(error)),
    );
    _downloading.remove(data.url);
    task.dispose();
    if (mounted) {
      setState(() {});
    }
    if (file != null) {
      await FilePicker.install(file.path);
    }
  }
}

class _DownloadTask {
  _DownloadTask(this.url);

  final String url;
  final ValueNotifier<double?> progress = ValueNotifier(null);

  void dispose() {
    progress.dispose();
  }
}
