import 'dart:ui';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../l10n/app_localizations.dart';
import 'future_builder_handler.dart';

class InputAssistance extends StatelessWidget {
  const InputAssistance({super.key, required this.onData, this.disabled = false});

  final bool disabled;
  final Function(String) onData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilderHandler(
      future: Api.sessionCreate(),
      builder: (context, sn) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.symmetric(horizontal: 72),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: ImageFiltered(
                imageFilter: disabled ? ImageFilter.blur(sigmaX: 16, sigmaY: 16) : ImageFilter.blur(),
                child: QrImageView(
                  backgroundColor: Colors.white,
                  data: sn.requireData.uri.toString(),
                  padding: const EdgeInsets.all(16),
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Colors.black87),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.titleMedium!.copyWith(height: 3),
              child: StreamBuilder(
                initialData: ' ',
                stream: _scanStream(context, sn.requireData.id),
                builder: (context, snapshot) => Text(snapshot.requireData),
              ),
            ),
          ],
        );
      },
    );
  }

  Stream<String> _scanStream<T>(BuildContext context, String sessionId) async* {
    while (true) {
      final session = await Api.sessionStatus(sessionId);
      if (!context.mounted) return;
      switch (session.status) {
        case SessionStatus.created:
          yield AppLocalizations.of(context)!.sessionStatusCreated;
        case SessionStatus.data:
          if (session.data != null) onData(session.data);
          yield AppLocalizations.of(context)!.sessionStatusConnected;
        case SessionStatus.finished:
          yield AppLocalizations.of(context)!.sessionStatusFinished;
          return;
        case SessionStatus.failed:
          yield AppLocalizations.of(context)!.sessionStatusFailed(session.data);
          return;
        case SessionStatus.progressing:
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
