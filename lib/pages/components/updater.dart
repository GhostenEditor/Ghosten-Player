import 'package:api/api.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:provider/provider.dart';

import '../../components/logo.dart';
import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_config.dart';
import '../../utils/utils.dart';

class UpdateBottomSheet extends StatefulWidget {
  const UpdateBottomSheet(this.data, {super.key});

  final UpdateData data;

  @override
  State<UpdateBottomSheet> createState() => _UpdateBottomSheetState();
}

class _UpdateBottomSheetState extends State<UpdateBottomSheet> {
  static final Map<String, _DownloadTask> _downloading = {};
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            const Logo(size: 36),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appName, style: Theme.of(context).textTheme.labelLarge),
                RichText(
                  text: TextSpan(
                    text: widget.data.createAt?.format() ?? '',
                    style: Theme.of(context).textTheme.labelSmall,
                    children: [
                      const TextSpan(text: ' '),
                      TextSpan(text: widget.data.version.toString(), style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FilledButton(
        style: FilledButton.styleFrom(elevation: 8),
        onPressed: _downloading.containsKey(widget.data.url) ? null : _download,
        child:
            _downloading.containsKey(widget.data.url)
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    Text(AppLocalizations.of(context)!.updating),
                    SizedBox(
                      width: 10,
                      height: 10,
                      child: ListenableBuilder(
                        listenable: _downloading[widget.data.url]!.progress,
                        builder: (context, _) {
                          return CircularProgressIndicator(
                            strokeWidth: 2,
                            value: _downloading[widget.data.url]!.progress.value,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          );
                        },
                      ),
                    ),
                  ],
                )
                : _failed
                ? Text(AppLocalizations.of(context)!.updateFailed)
                : Text(AppLocalizations.of(context)!.updateNow),
      ),
      body: Scrollbar(
        child: MarkdownWidget(
          padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 120),
          data: widget.data.comment,
          config: switch (Theme.of(context).brightness) {
            Brightness.dark => MarkdownConfig.darkConfig,
            Brightness.light => MarkdownConfig.defaultConfig,
          },
          markdownGenerator: MarkdownGenerator(),
        ),
      ),
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
