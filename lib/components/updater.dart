import 'package:api/api.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:install_plugin/install_plugin.dart';

import '../const.dart';
import '../utils/utils.dart';
import 'gap.dart';
import 'logo.dart';

class UpdateBottomSheet extends StatefulWidget {
  final UpdateResp data;
  final String url;

  const UpdateBottomSheet(this.data, {super.key, required this.url});

  @override
  State<UpdateBottomSheet> createState() => _UpdateBottomSheetState();
}

class _UpdateBottomSheetState extends State<UpdateBottomSheet> {
  static Map<String, _DownloadTask> downloading = {};
  bool failed = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Logo(size: 36),
                Gap.hMD,
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
                        TextSpan(text: widget.data.tagName.toString(), style: const TextStyle(fontSize: 10)),
                      ],
                    ))
                  ],
                ),
              ],
            ),
            Gap.vMD,
            Expanded(child: Markdown(data: widget.data.comment)),
            Gap.vMD,
            FilledButton(
                onPressed: downloading.containsKey(widget.url) ? null : download,
                child: downloading.containsKey(widget.url)
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(AppLocalizations.of(context)!.updating),
                        Gap.hMD,
                        SizedBox(
                            width: 10,
                            height: 10,
                            child: ListenableBuilder(
                                listenable: downloading[widget.url]!.progress,
                                builder: (context, _) {
                                  return CircularProgressIndicator(
                                      strokeWidth: 2,
                                      value: downloading[widget.url]!.progress.value,
                                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest);
                                })),
                      ])
                    : failed
                        ? Text(AppLocalizations.of(context)!.updateFailed)
                        : Text(AppLocalizations.of(context)!.updateNow)),
          ],
        ),
      ),
    );
  }

  download() async {
    await Api.requestStoragePermission();
    final url = widget.url;
    final task = _DownloadTask(url);
    setState(() {
      downloading[url] = task;
      failed = false;
    });
    final cachePath = '${(await FilePicker.cachePath)!}/$appName-${DateTime.now().millisecondsSinceEpoch}.apk';
    await Dio().download(
      url,
      cachePath,
      onReceiveProgress: (count, total) {
        if (total <= 0) return;
        if (mounted) task.progress.value = count / total;
      },
    ).catchError((error) {
      if (mounted) {
        setState(() {
          downloading.remove(url);
          task.dispose();
          failed = true;
        });
      }
      throw error;
    }, test: (e) => true);
    if (mounted) {
      setState(() {
        downloading.remove(url);
        task.dispose();
      });
    }
    await InstallPlugin.install(cachePath);
  }
}

class _DownloadTask {
  final String url;
  final ValueNotifier<double?> progress = ValueNotifier(null);

  _DownloadTask(this.url);

  dispose() {
    progress.dispose();
  }
}
