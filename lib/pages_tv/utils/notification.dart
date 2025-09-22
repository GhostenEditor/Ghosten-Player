import 'dart:async';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../components/error_message.dart';
import '../../l10n/app_localizations.dart';
import '../components/filled_button.dart';
import '../components/loading.dart';
import '../components/text_button.dart';

class NotificationResponse<T> {
  const NotificationResponse({this.data, this.error});

  final T? data;
  final Object? error;
}

Future<NotificationResponse<T?>?> showNotification<T>(
  BuildContext context,
  Future<T> future, {
  String? loadingText,
  String? errorText,
  String? successText,
  bool? showSuccess,
}) async {
  final snapshot = await showModal<AsyncSnapshot<T>>(
    context: context,
    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    builder:
        (context) => FutureBuilder(
          future: future,
          builder:
              (context, snapshot) => PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop && !snapshot.connectionState.isLoading()) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: _NotificationLayout(snapshot: snapshot),
              ),
        ),
  );
  if ((snapshot?.hasError ?? false) && context.mounted) {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(content: ErrorMessage(error: snapshot?.error)),
    );
  }
  return NotificationResponse(data: snapshot?.data, error: snapshot?.error);
}

class _NotificationLayout<T> extends StatelessWidget {
  const _NotificationLayout({super.key, required this.snapshot});

  final AsyncSnapshot<T> snapshot;

  @override
  Widget build(BuildContext context) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
      case ConnectionState.active:
        return const Loading();
      case ConnectionState.done:
      case ConnectionState.none:
        Navigator.of(context).pop(snapshot);
        return const SizedBox();
    }
  }
}

extension on ConnectionState {
  bool isLoading() {
    return this == ConnectionState.waiting || this == ConnectionState.active;
  }
}

Future<bool?> showConfirm(BuildContext context, String confirmText, [String? subText]) async {
  return showDialog(
    context: context,
    builder:
        (context) => Dialog.fullscreen(
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(switch (Theme.of(context).brightness) {
                      Brightness.dark => 'assets/tv/images/bg-stripe.png',
                      Brightness.light => 'assets/tv/images/bg-stripe-light.png',
                    }),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: switch (Theme.of(context).brightness) {
                      Brightness.dark => [Colors.black38, Colors.black],
                      Brightness.light => [Colors.white60, Colors.white],
                    },
                    stops: const [0.2, 1],
                    radius: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(confirmText, style: Theme.of(context).textTheme.displaySmall!.copyWith(height: 2)),
                      if (subText != null)
                        Text(
                          subText,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TVFilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(AppLocalizations.of(context)!.buttonConfirm),
                          ),
                          const SizedBox(width: 12),
                          TVTextButton(
                            autofocus: true,
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(AppLocalizations.of(context)!.buttonCancel),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
  );
}
