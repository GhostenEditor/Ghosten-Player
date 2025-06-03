import 'package:flutter/material.dart';

import '../../components/error_message.dart';
import '../../components/gap.dart';
import '../../l10n/app_localizations.dart';

const _errorIcon = Icon(Icons.error_outline, size: 60, color: Colors.red);
const _successIcon = Icon(Icons.check_circle_outline, size: 60, color: Colors.green);

class NotificationResponse<T> {
  const NotificationResponse({this.data, this.error});

  final T? data;
  final Object? error;
}

class _NotificationLayout<T> extends StatelessWidget {
  const _NotificationLayout({
    super.key,
    required this.snapshot,
    this.loadingText,
    this.errorText,
    this.successText,
    this.showSuccess,
  });

  final AsyncSnapshot<T> snapshot;
  final String? loadingText;
  final String? errorText;
  final String? successText;
  final bool? showSuccess;

  @override
  Widget build(BuildContext context) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
      case ConnectionState.active:
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.all(17), child: CircularProgressIndicator()),
            Text(loadingText ?? AppLocalizations.of(context)!.modalNotificationLoadingText),
          ],
        );
      case ConnectionState.done:
      case ConnectionState.none:
        if (snapshot.hasError) {
          return ErrorMessage(error: snapshot.error, leading: _errorIcon);
        } else {
          if (showSuccess ?? true) {
            _pop(context, const Duration(seconds: 1), snapshot.data, snapshot.error);
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _successIcon,
                Gap.vMD,
                Text(successText ?? AppLocalizations.of(context)!.modalNotificationSuccessText),
              ],
            );
          } else {
            _pop(context, Duration.zero, snapshot.data, snapshot.error);
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(padding: EdgeInsets.all(17), child: CircularProgressIndicator()),
                Text(loadingText ?? AppLocalizations.of(context)!.modalNotificationLoadingText),
              ],
            );
          }
        }
    }
  }

  void _pop(BuildContext context, Duration delay, T? data, Object? error) {
    Future.delayed(delay).then((value) {
      if (context.mounted) {
        Navigator.of(context).pop(NotificationResponse(data: data, error: error));
      }
    });
  }
}

Future<NotificationResponse<T?>?> showNotification<T>(
  BuildContext context,
  Future<T> future, {
  String? loadingText,
  String? errorText,
  String? successText,
  bool? showSuccess,
}) async {
  return showDialog<NotificationResponse<T?>>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.modalTitleNotification),
          content: FutureBuilder<T?>(
            future: future,
            builder:
                (context, snapshot) => PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, _) {
                    if (!didPop && !snapshot.connectionState.isLoading()) {
                      Navigator.of(context).pop(NotificationResponse(data: snapshot.data, error: snapshot.error));
                    }
                  },
                  child: _NotificationLayout<T?>(
                    snapshot: snapshot,
                    loadingText: loadingText,
                    errorText: errorText,
                    successText: successText,
                    showSuccess: showSuccess,
                  ),
                ),
          ),
        ),
  );
}

Future<bool?> showConfirm(BuildContext context, String confirmText) async {
  return showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.modalTitleConfirm),
          content: Text(confirmText),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.buttonConfirm),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.buttonCancel),
            ),
          ],
        ),
  );
}

extension on ConnectionState {
  bool isLoading() {
    return this == ConnectionState.waiting || this == ConnectionState.active;
  }
}
