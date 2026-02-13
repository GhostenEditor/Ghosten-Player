import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:provider/provider.dart';
import 'package:video_player/player.dart';

import '../../const.dart';
import '../../l10n/app_localizations.dart';
import '../../platform_api.dart';
import '../../providers/user_config.dart';
import '../../utils/check_update.dart';
import '../components/icon_button.dart';
import '../components/loading.dart';
import '../components/setting.dart';

class SettingsPlayerKernel extends StatefulWidget {
  const SettingsPlayerKernel({super.key});

  @override
  State<SettingsPlayerKernel> createState() => _SettingsPlayerKernelState();
}

class _SettingsPlayerKernelState extends State<SettingsPlayerKernel> {
  List<_MpvLib> _localMpvLibs = [];
  List<_MpvLib>? _remoteMpvLibs;
  late final userConfig = Provider.of<UserConfig>(context);
  static final Map<String, CancelToken> _downloadTasks = {};

  @override
  void initState() {
    super.initState();
    _getLocalMpvLibs();
  }

  @override
  Widget build(BuildContext context) {
    final mpvVersion = userConfig.mpvVersion;
    return SettingPage(
      title: AppLocalizations.of(context)!.settingsItemPlayerKernel,
      child: ListView(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 32),
        children: [
          RadioSettingItem(
            value: PlayerType.media3,
            groupValue: userConfig.playerType,
            title: Text(AppLocalizations.of(context)!.playerType(PlayerType.media3.name)),
            onChanged: (e) {
              if (e != null) {
                userConfig.setPlayerType(e);
                userConfig.setMpvVersion(null);
                setState(() {});
              }
            },
          ),
          ExpansionTile(
            leading: SizedBox(
              width: 40,
              child: Radio(value: PlayerType.mpv, groupValue: userConfig.playerType, onChanged: (e) {}),
            ),
            title: Badge(
              label: const Text('Alpha'),
              offset: const Offset(-10, 4),
              child: Text(AppLocalizations.of(context)!.playerType(PlayerType.mpv.name)),
            ),
            childrenPadding: const EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 12),
            onExpansionChanged: (expanded) {
              if (expanded) {
                _getRemoteMpvLibs();
              }
            },
            children: [
              ..._localMpvLibs.map((lib) => _buildMpvListTile(lib, mpvVersion)),
              if (_remoteMpvLibs == null)
                const Padding(padding: EdgeInsets.all(8.0), child: Loading())
              else
                ..._remoteMpvLibs!.map((lib) => _buildMpvListTile(lib, mpvVersion)),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButtonSettingItem(
                    onPressed: () {
                      _remoteMpvLibs = null;
                      _getLocalMpvLibs();
                      _getRemoteMpvLibs();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMpvListTile(_MpvLib lib, String? mpvVersion) {
    if (lib.downloaded && lib.version != mpvVersion) {
      return SlidableSettingItem(
        leading: Radio(value: lib.version, groupValue: mpvVersion, onChanged: (_) {}),
        title: Text(lib.version),
        actions: [
          TVIconButton(onPressed: () => _deleteMpvLib(lib.version), icon: const Icon(Icons.delete_outline_rounded)),
        ],
        onTap: () => _setMpvLib(lib.version),
      );
    } else {
      return RadioSettingItem(
        value: lib.version,
        groupValue: mpvVersion,
        title: Row(
          children: [
            Text(lib.version),
            const Spacer(),
            if (lib.downloaded) const Icon(Icons.download),
            if (lib.downloading)
              SizedBox.square(dimension: 16, child: CircularProgressIndicator(value: lib.downloadProgress)),
          ],
        ),
        onChanged: _setMpvLib,
      );
    }
  }

  Future<void> _getRemoteMpvLibs() async {
    if (_remoteMpvLibs != null) return;
    setState(() {});
    final arch = await PlatformApi.arch();
    final resp = await Dio(BaseOptions(connectTimeout: const Duration(seconds: 30))).get(libmpvUrl);
    if (!mounted) return;
    final data = (resp.data as List<dynamic>).cast<Map<String, dynamic>>().map(UpdateResp.fromJson).toList();
    _remoteMpvLibs =
        data
            .map(
              (it) => _MpvLib(
                version: it.tagName,
                downloadUrl: it.assets.firstWhereOrNull((item) => item.name == '$arch.zip')?.url,
              ),
            )
            .where((it) => _localMpvLibs.firstWhereOrNull((i) => i.version == it.version) == null)
            .toList();
    setState(() {});
  }

  Future<void> _getLocalMpvLibs() async {
    final dir = Directory('${(await FilePicker.filePath)!}/mpv');
    if (!dir.existsSync()) return;
    final subs = await dir.list().toList();
    if (!mounted) return;
    _localMpvLibs = subs.map((it) => _MpvLib(version: it.path.split('/').last, downloaded: true)).toList();
    setState(() {});
  }

  Future<void> _downloadMpvLib(_MpvLib lib) async {
    if (_downloadTasks.containsKey(lib.version)) {
      return;
    }
    lib.downloading = true;
    setState(() {});
    final cachedFilePath = '${(await FilePicker.cachePath)!}/${lib.version}.zip';
    final cancelToken = CancelToken();
    _downloadTasks.putIfAbsent(lib.version, () => cancelToken);
    try {
      await Dio().download(
        lib.downloadUrl!,
        cachedFilePath,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          if (total > 0 && mounted) {
            lib.downloadProgress = count.toDouble() / total.toDouble();
            setState(() {});
          }
        },
      );
    } catch (e) {
      _downloadTasks.remove(lib.version);
      lib.downloadProgress = null;
      lib.downloading = false;
      lib.downloaded = false;
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.downloaderLabelDownloadFailed),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            width: 200,
          ),
        );
      }
      return;
    }
    _downloadTasks.remove(lib.version);
    final zipFile = File(cachedFilePath);
    final destinationDir = Directory('${(await FilePicker.filePath)!}/mpv/${lib.version}');
    try {
      await ZipFile.extractToDirectory(zipFile: zipFile, destinationDir: destinationDir);
    } catch (e) {
      await zipFile.delete();
      lib.downloadProgress = null;
      lib.downloading = false;
      lib.downloaded = false;
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.downloaderLabelDownloadFailed),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            width: 200,
          ),
        );
      }
      return;
    }
    if (zipFile.existsSync()) {
      await zipFile.delete();
    }
    lib.downloadProgress = null;
    lib.downloading = false;
    lib.downloaded = true;
    if (mounted) setState(() {});
  }

  Future<void> _deleteMpvLib(String version) async {
    final dir = Directory('${(await FilePicker.filePath)!}/mpv/$version');
    await dir.delete(recursive: true);
    _getLocalMpvLibs();
  }

  Future<void> _setMpvLib(String? version) async {
    final lib = [..._localMpvLibs, ...?_remoteMpvLibs].firstWhere((lib) => lib.version == version);
    if (!lib.downloaded) {
      await _downloadMpvLib(lib);
    }
    if (!lib.downloaded) return;
    userConfig.setPlayerType(PlayerType.mpv);
    userConfig.setMpvVersion(version);
    if (!mounted) return;
    setState(() {});
  }
}

class _MpvLib {
  _MpvLib({required this.version, this.downloadUrl, this.downloaded = false});

  final String version;
  final String? downloadUrl;
  bool downloaded;
  bool downloading = false;
  double? downloadProgress;
}
