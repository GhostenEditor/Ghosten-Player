import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../const.dart';
import '../platform_api.dart';
import 'gap.dart';
import 'stream_builder_handler.dart';

class ConnectButton extends StatefulWidget {
  final Function(String) onData;

  const ConnectButton({super.key, required this.onData});

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton> {
  bool connected = false;

  @override
  Widget build(BuildContext context) {
    return PlatformApi.isAndroidTV() ? IconButton(onPressed: _showQrCode, icon: const Icon(Icons.switch_left)) : const SizedBox();
  }

  _showQrCode() async {
    connected = false;
    final session = await Api.sessionCreate();
    if (mounted) await showDialog(context: context, builder: (context) => _buildDialog(context, session.uri, _scanStream(session.id, session.uri)));
  }

  Widget _buildDialog(BuildContext context, Uri link, Stream<_SessionData> stream) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.titleScan),
      content: StreamBuilderHandler<_SessionData>(
        initialData: _SessionData(uri: link, tip: AppLocalizations.of(context)!.sessionStatusCreated),
        stream: stream,
        builder: (context, snapshot) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: kQrSize,
              height: kQrSize,
              child: QrImageView(
                backgroundColor: Colors.white,
                data: snapshot.requireData.uri.toString(),
                version: QrVersions.auto,
                size: kQrSize,
              ),
            ),
            Gap.vSM,
            SizedBox(
              width: kQrSize,
              child: Text(
                snapshot.requireData.tip,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<_SessionData> _scanStream<T>(String sessionId, Uri sessionUrl) async* {
    while (true) {
      final session = await Api.sessionStatus(sessionId);
      if (!mounted) return;
      switch (session.status) {
        case SessionStatus.created:
          yield _SessionData(uri: sessionUrl, tip: AppLocalizations.of(context)!.sessionStatusCreated);
        case SessionStatus.data:
          yield _SessionData(uri: sessionUrl, tip: AppLocalizations.of(context)!.sessionStatusConnected);
          _dataStream(sessionId).listen(widget.onData);
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.of(context).pop(true);
          return;
        case SessionStatus.finished:
          yield _SessionData(uri: sessionUrl, tip: AppLocalizations.of(context)!.sessionStatusFinished);
          return;
        case SessionStatus.failed:
          yield _SessionData(uri: sessionUrl, tip: AppLocalizations.of(context)!.sessionStatusFailed(session.data));
          return;
        case SessionStatus.progressing:
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Stream<String> _dataStream(String sessionId) async* {
    connected = true;
    while (mounted && connected) {
      final session = await Api.sessionStatus(sessionId);
      if (session.data is String) {
        yield session.data;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}

class _SessionData {
  final Uri uri;
  final String tip;

  const _SessionData({required this.uri, required this.tip});
}
