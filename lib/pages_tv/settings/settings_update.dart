import 'package:api/api.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:provider/provider.dart';

import '../../components/error_message.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_config.dart';
import '../../utils/utils.dart';

class SettingsUpdate extends StatefulWidget {
  const SettingsUpdate({super.key});

  @override
  State<SettingsUpdate> createState() => _SettingsUpdateState();
}

class _SettingsUpdateState extends State<SettingsUpdate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: FutureBuilder(
          future: _checkUpdate(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Row(
                  children: [
                    Flexible(
                      child: Align(
                        alignment: const Alignment(0, -0.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.checkingUpdates,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 12),
                            const LinearProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Align(
                        alignment: const Alignment(-0.6, -0.2),
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 64),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          child: Text(AppLocalizations.of(context)!.checkForUpdates),
                        ),
                      ),
                    ),
                  ],
                );
              case ConnectionState.none:
              case ConnectionState.done:
                if (snapshot.hasData) {
                  return _SettingsUpdating(data: snapshot.requireData!);
                } else if (snapshot.hasError) {
                  return Row(
                    children: [
                      Flexible(
                        child: Align(
                          alignment: const Alignment(0, -0.2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.updateFailed,
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const SizedBox(height: 12),
                              const LinearProgressIndicator(value: 1, color: Colors.redAccent),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ErrorMessage(error: snapshot.error),
                              ElevatedButton(
                                autofocus: true,
                                onPressed: () => setState(() {}),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 64),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                ),
                                child: Text(AppLocalizations.of(context)!.checkForUpdates),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Flexible(
                        child: Align(
                          alignment: const Alignment(0, -0.2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.isLatestVersion,
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(value: 1, color: Theme.of(context).colorScheme.surfaceContainer),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.lastCheckedUpdatesTime(DateTime.now().formatFullWithoutSec()),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Align(
                          alignment: const Alignment(-0.6, -0.2),
                          child: ElevatedButton(
                            autofocus: true,
                            onPressed: () => setState(() {}),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 64),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: Text(AppLocalizations.of(context)!.checkForUpdates),
                          ),
                        ),
                      ),
                    ],
                  );
                }
            }
          },
        ),
      ),
    );
  }

  Future<UpdateData?> _checkUpdate(BuildContext context) {
    final userConfig = context.read<UserConfig>();
    return Api.checkUpdate(
      '${userConfig.githubProxy}$updateUrl',
      userConfig.updatePrerelease,
      Version.fromString(appVersion),
    );
  }
}

class _SettingsUpdating extends StatefulWidget {
  const _SettingsUpdating({required this.data});

  final UpdateData data;

  @override
  State<_SettingsUpdating> createState() => _SettingsUpdatingState();
}

class _SettingsUpdatingState extends State<_SettingsUpdating> {
  static final Map<String, _DownloadTask> _downloading = {};
  final _controller = ScrollController();
  double _cachedOffset = 0;
  bool _failed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Align(
            alignment: const Alignment(0, -0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.latestVersion(widget.data.tagName),
                      style: Theme.of(context).textTheme.displaySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(widget.data.createAt?.format() ?? '', style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
                const SizedBox(height: 12),
                if (_downloading.containsKey(widget.data.url))
                  ListenableBuilder(
                    listenable: _downloading[widget.data.url]!.progress,
                    builder:
                        (context, _) => LinearProgressIndicator(value: _downloading[widget.data.url]!.progress.value),
                  )
                else
                  const LinearProgressIndicator(value: 1, color: Colors.greenAccent),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Focus(
                    autofocus: true,
                    onKeyEvent: (FocusNode node, KeyEvent event) {
                      if (event is KeyDownEvent || event is KeyRepeatEvent) {
                        switch (event.logicalKey) {
                          case LogicalKeyboardKey.arrowUp:
                            _cachedOffset = (_cachedOffset - 100).clamp(
                              _controller.position.minScrollExtent,
                              _controller.position.maxScrollExtent,
                            );
                            if (_cachedOffset != _controller.offset) {
                              _controller.animateTo(
                                _cachedOffset,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              );
                              return KeyEventResult.handled;
                            }
                          case LogicalKeyboardKey.arrowDown:
                            _cachedOffset = (_cachedOffset + 100).clamp(
                              _controller.position.minScrollExtent,
                              _controller.position.maxScrollExtent,
                            );
                            if (_cachedOffset != _controller.offset) {
                              _controller.animateTo(
                                _cachedOffset,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              );
                              return KeyEventResult.handled;
                            }
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Scrollbar(
                      controller: _controller,
                      child: Markdown(data: widget.data.comment, controller: _controller),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _downloading.containsKey(widget.data.url) ? null : _download,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    _downloading.containsKey(widget.data.url)
                        ? AppLocalizations.of(context)!.updating
                        : AppLocalizations.of(context)!.updateNow,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _download() async {
    final proxy = context.read<UserConfig>().githubProxy;
    await Api.requestStoragePermission();
    final url = widget.data.url;
    final task = _DownloadTask(url);
    setState(() {
      _downloading[url] = task;
      _failed = false;
    });
    final cachePath = '${(await FilePicker.cachePath)!}/$appName-${DateTime.now().millisecondsSinceEpoch}.apk';
    await Dio()
        .download(
          '$proxy$url',
          cachePath,
          onReceiveProgress: (count, total) {
            if (total <= 0) return;
            if (mounted) task.progress.value = count / total;
          },
        )
        .catchError((error) {
          if (mounted) {
            setState(() {
              _downloading.remove(url);
              task.dispose();
              _failed = true;
            });
          }
          throw error;
        }, test: (e) => true);
    if (mounted) {
      setState(() {
        _downloading.remove(url);
        task.dispose();
      });
    }
    await InstallPlugin.install(cachePath);
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
