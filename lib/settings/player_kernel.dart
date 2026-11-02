import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide RadioListTile;
import 'package:flutter_archive/flutter_archive.dart';
import 'package:provider/provider.dart';
import 'package:video_player/player.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../platform_api.dart';
import '../../utils/check_update.dart';
import '../../utils/utils.dart';
import '../adaptive/adaptive.dart';
import '../components/components.dart';
import '../providers/player.dart';

class SettingsPlayerKernel extends StatefulWidget {
  const SettingsPlayerKernel({super.key});

  @override
  State<SettingsPlayerKernel> createState() => _SettingsPlayerKernelState();
}

class _SettingsPlayerKernelState extends State<SettingsPlayerKernel> {
  List<_MpvLib> _localMpvLibs = [];
  List<_MpvLib>? _remoteMpvLibs;
  late final PlayerConfig _playerConfig = Provider.of<PlayerConfig>(context);
  static final Map<String, CancelToken> _downloadTasks = {};

  @override
  void initState() {
    super.initState();
    _getLocalMpvLibs();
  }

  @override
  Widget build(BuildContext context) {
    final String? mpvVersion = _playerConfig.mpvVersion;
    return SettingPage(
      title: Text(AppLocalizations.of(context)!.settingsItemPlayerKernel),
      child: RadioGroup(
        onChanged: (value) {
          if (value == .media3) {
            _playerConfig.setPlayerType(.media3);
            _playerConfig.setMpvVersion(null);
            setState(() {});
          }
        },
        groupValue: _playerConfig.playerType,
        child: ListView(
          padding: SettingPageTheme.of(context).contentPadding,
          children: [
            RadioListTile(
              value: PlayerType.media3,
              title: Text(AppLocalizations.of(context)!.playerType(PlayerType.media3.name)),
            ),
            RadioGroup(
              groupValue: mpvVersion,
              onChanged: _setMpvLib,
              child: ExpansionTile(
                leading: const SizedBox(width: 40, child: Radio(value: PlayerType.mpv, enabled: false)),
                childrenPadding: SettingPageTheme.of(context).contentPadding,
                title: Badge(
                  label: const Text('Alpha'),
                  offset: const Offset(-10, 4),
                  child: Text(AppLocalizations.of(context)!.playerType(PlayerType.mpv.name)),
                ),
                onExpansionChanged: (expanded) {
                  if (expanded) {
                    _getRemoteMpvLibs();
                  }
                },
                children: [
                  ..._localMpvLibs.map((lib) => _buildMpvListTile(lib, mpvVersion)),
                  if (_remoteMpvLibs != null) ..._remoteMpvLibs!.map((lib) => _buildMpvListTile(lib, mpvVersion)),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton.filledTonal(
                        onPressed: _remoteMpvLibs != null
                            ? () {
                                _remoteMpvLibs = null;
                                _getLocalMpvLibs();
                                _getRemoteMpvLibs();
                              }
                            : null,
                        icon: _remoteMpvLibs == null
                            ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator())
                            : const Icon(Icons.refresh),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMpvListTile(_MpvLib lib, String? mpvVersion) {
    final RadioListTile<String> child = RadioListTile(
      value: lib.version,
      title: Row(
        children: [
          Text(lib.version),
          const Spacer(),
          if (lib.downloaded) const Icon(Icons.download),
          if (lib.downloading)
            SizedBox.square(dimension: 16, child: CircularProgressIndicator(value: lib.downloadProgress)),
        ],
      ),
    );
    if (lib.downloaded && lib.version != mpvVersion) {
      return Dismissible(
        key: ValueKey(lib.version),
        confirmDismiss: (_) async {
          final bool confirmed = await showConfirm(context, AppLocalizations.of(context)!.deleteConfirmText) ?? false;
          if (confirmed) {
            await _deleteMpvLib(lib.version);
          }
          return confirmed;
        },
        onDismissed: (_) {
          _localMpvLibs.remove(lib);
          _remoteMpvLibs?.where((it) => it == lib).forEach((it) {
            it.downloaded = false;
          });
          setState(() {});
        },
        child: child,
      );
    } else {
      return child;
    }
  }

  Future<void> _getRemoteMpvLibs() async {
    if (_remoteMpvLibs != null) {
      return;
    }
    setState(() {});
    final String? arch = await PlatformApi.arch();
    final Response<dynamic> resp = await cacheHttpClient.get(libmpvUrl);
    if (!mounted) {
      return;
    }
    final List<UpdateResp> data = (resp.data as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(UpdateResp.fromJson)
        .toList();
    _remoteMpvLibs = data
        .map((it) {
          final UpdateRespAsset? item = it.assets.firstWhereOrNull((item) => item.name == '$arch.zip');
          if (item != null) {
            return _MpvLib(version: it.tagName, downloadUrl: item.url, digest: item.digest, name: item.name);
          } else {
            return null;
          }
        })
        .nonNulls
        .where((it) => _localMpvLibs.firstWhereOrNull((i) => i.version == it.version) == null)
        .toList();
    setState(() {});
  }

  Future<void> _getLocalMpvLibs() async {
    final dir = Directory('${(await FilePicker.filePath)!}/mpv');
    if (!dir.existsSync()) {
      return;
    }
    final List<FileSystemEntity> subs = await dir.list().toList();
    if (!mounted) {
      return;
    }
    _localMpvLibs = subs.map((it) => _MpvLib(version: it.path.split('/').last, downloaded: true)).toList();
    setState(() {});
  }

  Future<void> _downloadMpvLib(_MpvLib lib) async {
    if (_downloadTasks.containsKey(lib.version)) {
      final CancelToken? cancelToken = _downloadTasks[lib.version];
      cancelToken!.cancel();
      _downloadTasks.remove(lib.version);
      lib.downloadProgress = null;
      lib.downloading = false;
      lib.downloaded = false;
      setState(() {});
      return;
    }
    lib.downloading = true;
    final cancelToken = CancelToken();
    setState(() {});
    _downloadTasks.putIfAbsent(lib.version, () => cancelToken);
    final String directory = (await FilePicker.cachePath)!;
    final File? file = await download(
      digest: lib.digest!,
      url: lib.downloadUrl!,
      directory: directory,
      filename: '${lib.version}-${lib.name}',
      cancelToken: cancelToken,
      onProgress: (progress) {
        lib.downloadProgress = progress;
        setState(() {});
      },
      onError: (error) {
        _downloadTasks.remove(lib.version);
        lib.downloadProgress = null;
        lib.downloading = false;
        lib.downloaded = false;
        if (mounted) {
          setState(() {});
          if (error.type == .cancel) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('下载已取消'), behavior: SnackBarBehavior.floating, width: 200));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.downloaderLabelDownloadFailed),
                behavior: SnackBarBehavior.floating,
                width: 200,
              ),
            );
          }
        }
      },
    );
    setState(() {});

    _downloadTasks.remove(lib.version);
    if (file != null) {
      final destinationDir = Directory('${(await FilePicker.filePath)!}/mpv/${lib.version}');
      try {
        await ZipFile.extractToDirectory(zipFile: file, destinationDir: destinationDir);
      } catch (e) {
        await file.delete();
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
      lib.downloadProgress = null;
      lib.downloading = false;
      lib.downloaded = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _deleteMpvLib(String version) async {
    final dir = Directory('${(await FilePicker.filePath)!}/mpv/$version');
    await dir.delete(recursive: true);
  }

  Future<void> _setMpvLib(String? version) async {
    final _MpvLib lib = [..._localMpvLibs, ...?_remoteMpvLibs].firstWhere((lib) => lib.version == version);
    if (!lib.downloaded) {
      await _downloadMpvLib(lib);
    }
    if (!lib.downloaded) {
      return;
    }
    _playerConfig.setPlayerType(PlayerType.mpv);
    _playerConfig.setMpvVersion(version);
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}

class _MpvLib {
  _MpvLib({required this.version, this.downloadUrl, this.downloaded = false, this.digest, this.name});

  final String? name;
  final String version;
  final String? downloadUrl;
  final String? digest;
  bool downloaded;
  bool downloading = false;
  double? downloadProgress;
}
